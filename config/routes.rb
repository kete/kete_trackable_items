# Routes needs more thought since some default routes in ArchivesCentral are taking precedence.
ActionController::Routing::Routes.draw do |map|
  map.resources :on_loan_organizations, :path_prefix => ':urlified_name'
  map.resources :tracking_events, :path_prefix => ':urlified_name', :only => [:index]
  map.resources :tracked_items, :path_prefix => ':urlified_name', :only => [:create]
  map.resources :trackable_item_shelf_locations, :path_prefix => ':urlified_name', :only => [:new, :create, :update]
  map.resources :repositories, :path_prefix => ':urlified_name', :has_many => [:shelf_locations, :tracking_lists]
end
