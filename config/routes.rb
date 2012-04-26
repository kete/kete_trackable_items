require 'trackable_items'
# Routes needs more thought since some default routes in ArchivesCentral are taking precedence.
ActionController::Routing::Routes.draw do |map|
  map.resources :repositories, :path_prefix => ':urlified_name'
  map.resources :shelf_locations, :path_prefix => ':urlified_name'
  map.resources :tracking_lists, :path_prefix => ':urlified_name', :only => [:show, :index]
end