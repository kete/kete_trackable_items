module TrackableItemsHelper
  # wrapped in a div to allow for styling the form to be inline
  def button_to_place_in_shelf_location(trackable_item)
    # whether we should redirect to site basket or not
    # if no repositories are associated with this basket, specify site

    options = { :trackable_item => { :id => trackable_item.id,
        :type => trackable_item.class.name } }

    options[:urlified_name] = @site_basket.urlified_name if @current_basket.repositories.count < 1

    "<div class=\"add-to-shelf-location\">" +
      button_to(t('trackable_items_helper.add_to_shelf_location'),
                new_trackable_item_shelf_location_url(options)) +
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
