module KeteTrackableItemsHelper
  include KeteTrackableItemsControllerHelpers::UrlFor

  # wrapped in a div to allow for styling the form to be inline
  def button_to_place_in_shelf_location(trackable_item)
    "<div class=\"add-to-shelf-location\">" +
        #button_to(t('trackable_items.helpers.add_trackable_item_to_shelf'),
                  #:controller => :trackable_items_shelf_locations,
                  #:action => :create
        #trackable_item.class.as_foreign_key_sym => trackable_item) +
        "</div>"
  end

  def shelf_location_status_or_button_to_place_in_shelf_location(trackable_item)
    html = String.new
    if current_user && current_user != false && trackable_item.has_shelf_location?
      html = "<div class=\"shelf-locations\">" +
          "</div>"
    else
      html = button_to_place_in_shelf_location(trackable_item)
    end
    html
  end

end
