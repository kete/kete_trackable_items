class TrackingEventsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  include KeteTrackableItems::PaginateSetUp

  permit "site_admin or admin of :site_basket or admin of :current_basket"

  def index
    set_page_variables

    if params[:historical_item_id] && params[:historical_item_type]
      @historical_item = params[:historical_item_type].constantize.find(params[:historical_item_id])
    end
    
    @tracking_events = @historical_item ? @historical_item.tracking_events.paginate(@page_options) : TrackingEvents.all.paginate(@page_options)

    set_results_variables(@tracking_events)
  end
end
