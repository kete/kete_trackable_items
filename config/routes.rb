require 'trackable_items'
# Routes needs more thought since some default routes in ArchivesCentral are taking precedence.
ActionController::Routing::Routes.draw do |map|
  map.resources :tracking_lists, :only => [:show, :index]
  map.resources :repositories
  map.resources :shelf_locations
end