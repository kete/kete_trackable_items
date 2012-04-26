module KeteTrackableItemsHelper
  include KeteTrackableItemsControllerHelpers::UrlFor
  
  # wrapped in a div to allow for styling the form to be inline
  def button_to_place_in_shelf_location(trackable_item)
    "<div class=\"add-to-shelf-location\">" +
    # @TODO ADD YML LATER
      button_to('Add shelf location',
               :controller => :shelf_locations,
               :action => :add_to_trackable_item,
               trackable_item.class.as_foreign_key_sym => trackable_item) +
      "</div>"
  end

  def shelf_location_status_or_button_to_place_in_shelf_location(trackable_item)
    html = String.new
    if current_user && current_user != false &&
        trackable_item.has_shelf_location?(trackable_item)
      html = "<div class=\"shelf-locations\">Shelf locations" +
        "</div>"
    else
      html = button_to_place_in_shelf_location(trackable_item)
    end
    html
  end
    
end
