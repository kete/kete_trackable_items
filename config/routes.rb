ActionController::Routing::Routes.draw do |map|
  map.resources :tracking_lists, :only => [:show]
end