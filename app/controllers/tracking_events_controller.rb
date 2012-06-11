class TrackingEventsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  include KeteTrackableItems::MatchingTrackableItemsControllerHelpers

  def index
    if params[:historical_item_id] && params[:historical_item_type]
      @historical_item = params[:historical_item_type].constantize.find(params[:historical_item_id])
    end
    
    @tracking_events = @historical_item ? @historical_item.tracking_events : TrackingEvents.all
  end
end
