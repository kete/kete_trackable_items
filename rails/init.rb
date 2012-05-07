ActionController::Base.send(:helper, KeteTrackableItemsHelper)

config.to_prepare do
  # load our locales
  I18n.load_path += Dir[File.join(File.dirname(__FILE__), '../config/locales/*.{rb,yml}')]

  # override some controllers and helpers to be kete gets trollied aware
  exts = File.join(File.dirname(__FILE__), '../lib/kete_trackable_items/extensions/{controllers,helpers}/*')
  # use Kernel.load here so that changes to the extensions are reloaded on each request in development
  Dir[exts].each { |ext_path| Kernel.load(ext_path) }
  # models we extend
  Kete.extensions[:blocks] ||= Hash.new
  Dir[File.join(File.dirname(__FILE__), '../lib/kete_trackable_items/extensions/models/*')].each do |ext_path|
    key = File.basename(ext_path, '.rb').to_sym
    Kete.extensions[:blocks][key] ||= Array.new
    Kete.extensions[:blocks][key] << Proc.new { Kernel.load(ext_path) }
  end
end
