module KeteTrackableItemsControllerHelpers
  def self.included(klass)
    klass.send :helper_method, :url_for_repository
    klass.send :include, UrlFor
  end
  
  module UrlFor
    
    # Repository URLs
    def url_for_repository(repo_id)
      url_for(
        :controller => "repositories",
        :action => :show, 
        :urlified_name => @current_basket.urlified_name,
        :id => repo_id) 
    end

    # Could DRY up these helper methods a bit e.g.
    # def url_to_controller_action(controller_name, action)
    def url_to_create_repository
      url_for(
        :controller => "repositories",
        :action => :create, 
        :urlified_name => @current_basket.urlified_name) 
    end

    def url_to_edit_repository(repo_id)
      url_for(
        :controller => "repositories",
        :action => :edit, 
        :urlified_name => @current_basket.urlified_name,
        :id => repo_id) 
    end

    def url_to_update_repository(repo_id)
      url_for(
        :controller => "repositories",
        :action => :update, 
        :urlified_name => @current_basket.urlified_name,
        :id => repo_id) 
    end

    def url_for_new_repository
      url_for(
        :controller => "repositories",
        :action => :new, 
        :urlified_name => @current_basket.urlified_name) 
    end
    
    # Shelf Location URLs
    def url_for_shelf_location(shelf_id)
      url_for(
        :controller => "shelf_locations",
        :action => :show, 
        :urlified_name => @current_basket.urlified_name,
        :id => shelf_id) 
    end

    def url_to_edit_shelf_location(shelf_id)
      url_for(
        :controller => "shelf_locations",
        :action => :edit, 
        :urlified_name => @current_basket.urlified_name,
        :id => shelf_id) 
    end

    #Tracking List URLs
    def url_for_tracking_list(tracking_list_id)
      url_for(
        :controller => "tracking_lists",
        :action => :show, 
        :urlified_name => @current_basket.urlified_name,
        :id => tracking_list_id) 
    end

    def url_for_new_tracking_list
      url_for(
        :controller => "tracking_lists",
        :action => :new, 
        :urlified_name => @current_basket.urlified_name)  
    end
  end
  
end    