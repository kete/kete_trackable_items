# put any application controller overrides or additions in here
ApplicationController.class_eval do
end

kete_trackable_items_controllers = ['repositories', 'shelf_locations','tracking_lists',
                                    'tracking_events', 'trackable_item_shelf_locations']

ApplicationController.add_ons_full_width_content_wrapper_controllers += kete_trackable_items_controllers
ApplicationController.add_ons_content_wrapper_end_controllers += kete_trackable_items_controllers
