ActionController::Base.send(:include, KeteTrackableItems::ControllerHelpers)
ActionController::Base.send(:helper, TrackableItemsHelper)

config.to_prepare do
  # load our locales
  I18n.load_path += Dir[File.join(File.dirname(__FILE__), '../config/locales/*.{rb,yml}')]

  # override some controllers and helpers to be kete gets trollied aware
  exts = File.join(File.dirname(__FILE__), '../lib/kete_trackable_items/extensions/{controllers,helpers}/*')
  # use Kernel.load here so that changes to the extensions are reloaded on each request in development
  Dir[exts].each { |ext_path| Kernel.load(ext_path) }

  # models we extend
  Dir[File.join(File.dirname(__FILE__), '../lib/kete_trackable_items/extensions/models/*')].each do |ext_path|
    key = File.basename(ext_path, '.rb').to_sym
    Kete.add_code_to_extensions_for(key, Proc.new { Kernel.load(ext_path) })
  end

  # this is for site specific defined search scopes
  # i.e. you can place your own Kete site's extended fields set up dependent search definitions
  # in a config and have them available to kete_trackable_items code
  Kete.define_reader_method_as('trackable_item_scopes',
                               YAML.load(IO.read(File.join(Rails.root, 'config/trackable_item_scopes.yml'))))

  Kete.trackable_item_scopes.each do |key, options|
    klass = key.camelize.constantize
    key = key.to_sym

    if options['prerequisite_extensions'].present?
      options['prerequisite_extensions'].each do |code|
        extension = Proc.new do
          klass.class_eval do
            eval(code)
          end
        end

        Kete.add_code_to_extensions_for(key, extension)
      end
    end

    if options['search_scopes'].present?
      if options['search_scopes']['always_within_scopes'].present?
        options['search_scopes']['always_within_scopes'].each do |scope_key, scope_code|
          extension = Proc.new do
            klass.class_eval do
              named_scope(scope_key.to_sym, eval(scope_code))
            end
          end

          Kete.add_code_to_extensions_for(key, extension)
        end
      end

      if options['search_scopes']['text_searches'].present?
        options['search_scopes']['text_searches'].each do |search_specs|
          search_specs.each do |scope_key, scope_code|
            extension = Proc.new do
              klass.class_eval do
                named_scope(scope_key.to_sym, eval(scope_code))
              end
            end
            Kete.add_code_to_extensions_for(key, extension)
          end
        end
      end
    end
  end
end
