ApplicationHelper.module_eval do
  def add_trackable_items_links
    html = link_to(t('application_helper.add_trackable_items_links.add_items_to_tracking_list'),
                   '#', :id => 'add-items-button', :tabindex => 2)

    html += link_to(t('application_helper.add_trackable_items_links.close_add_items_to_tracking_list'),
                    '#', :id => 'close-add-items-button', :tabindex => 2, :style => 'display: none;' )

    html += javascript_tag("jQuery(document).ready(function(){
			    jQuery('#add-items-button').click(function() {
		            jQuery('#trackable_item_search_form').slideDown('slow',
			    function() {
		            jQuery('#add-items-button').hide();
			    jQuery('#close-add-items-button').show();
			    });
			    });
			    jQuery('#close-add-items-button').click(function() {
		            jQuery('#trackable_item_search_form').slideUp('slow',
			    function() {
			    jQuery('#close-add-items-button').hide();
		            jQuery('#add-items-button').show();
			    });
			    });
			    });
			    ")

    html
  end
end
