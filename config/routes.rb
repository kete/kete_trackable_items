# Routes needs more thought since some default routes in ArchivesCentral are taking precedence.
ActionController::Routing::Routes.draw do |map|
  map.resources :tracked_items, :path_prefix => ':urlified_name', :only => [:create]
  map.resources :trackable_item_shelf_locations, :path_prefix => ':urlified_name', :only => [:create]
  map.resources :tracking_lists, :path_prefix => ':urlified_name', :only => [:show, :new, :index]
  map.resources :repositories, :path_prefix => ':urlified_name', :has_many => :shelf_locations #, :has_many => :tracking_lists
end
