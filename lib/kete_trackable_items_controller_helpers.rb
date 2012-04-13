module KeteTrackableItemsControllerHelpers
  def self.included(klass)
    klass.send :helper_method, :url_for_repository
    klass.send :include, UrlFor
  end
  
  module UrlFor
    
    # Under development
    def url_for_repository
    end
    
  end
  
end    