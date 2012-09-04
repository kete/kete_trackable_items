list_management_members = [:remove_from_list, :restore_to_list]

ActionController::Routing::Routes.draw do |map|
  map.resources :on_loan_organizations, :path_prefix => ':urlified_name'
  map.resources :tracking_events, :path_prefix => ':urlified_name', :only => [:index]
  map.resources :tracked_items, :path_prefix => ':urlified_name', :only => [:create]
  map.resources :trackable_item_shelf_locations, :path_prefix => ':urlified_name', :only => [:new, :create, :update]
  map.resources :repositories, :path_prefix => ':urlified_name' do |repository|
    repository.resources :shelf_locations, :member => list_management_members

    repository.resources :tracking_lists, :member => list_management_members
  end

  # Various RSS feeds not associated with search
  map.with_options :controller => 'tracking_lists', :action => "show" do |tracking_list|
    tracking_list.tracking_list_xls ':urlified_name/repositories/:repository_id/tracking_lists/:id/trackinglist.:format'
  end
end
