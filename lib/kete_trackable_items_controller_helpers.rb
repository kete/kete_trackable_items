module KeteTrackableItemsControllerHelpers
  def self.included(klass)
    klass.send :helper_method, :url_for_repository
    klass.send :include, UrlFor
  end
  
  module UrlFor
    
    def url_for_repository(repo_id)
      url_for(
        :controller => "repositories",
        :action => :show, 
        :urlified_name => @current_basket.urlified_name,
        :id => repo_id) 
    end
    
  end
  
end    