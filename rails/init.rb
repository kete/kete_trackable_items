ActionController::Base.send(:include, KeteTrackableItemsControllerHelpers)
ActionController::Base.send(:helper, KeteTrackableItemsHelper)

config.to_prepare do
  # load our locales
  I18n.load_path += Dir[ File.join(File.dirname(__FILE__), '../config/locales/*.{rb,yml}') ]
end