module TrackableItemsHelper
  # wrapped in a div to allow for styling the form to be inline
  def button_to_place_in_shelf_location(trackable_item)
    "<div class=\"add-to-shelf-location\">" +
        button_to(t('trackable_items_helper.add_to_shelf_location'),
                  :controller => :trackable_items_shelf_locations,
                  :action => :create) +
        "</div>"
  end

  def shelf_locations_or_appropriate_action(trackable_item)
    html = String.new
    if trackable_item.has_shelf_locations?
      html = "<div class=\"shelf-locations\">" +
          "</div>"
    else
      html = button_to_place_in_shelf_location(trackable_item)
    end
    html
  end

end
