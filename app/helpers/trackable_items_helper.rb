module TrackableItemsHelper
  # wrapped in a div to allow for styling the form to be inline
  def button_to_place_in_shelf_location(trackable_item)
    # whether we should redirect to site basket or not
    # if no repositories are associated with this basket, specify site
    button_url = @current_basket.repositories.count < 1 ? new_trackable_item_shelf_location_url(:urlified_name => @site_basket.urlified_name) : new_trackable_item_shelf_location_url

    "<div class=\"add-to-shelf-location\">" +
      button_to(t('trackable_items_helper.add_to_shelf_location'),
                button_url) +
      "</div>"
  end

  def shelf_locations_or_appropriate_action(trackable_item)
    html = String.new
    if trackable_item.has_shelf_locations?
      html += "<div class=\"shelf-locations\">" +
          "</div>"
    end

    html += button_to_place_in_shelf_location(trackable_item)

    html
  end

end
