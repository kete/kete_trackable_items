class TrackingListsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  def show
    @tracking_list = TrackingList.find(params[:id])
  end

  def index
    @tracking_lists = TrackingList.all
  end

  def create
    @tracking_list = @trackable_item.tracked_items.build(@tracking_list)

    if @tracking_list.save
      redirect_to tracking_list_url(:id => @tracking_list)
    end
  end

  def destroy
    tracked_item = @trackable_item.tracked_items.find_by_tracking_list_id(@tracking_list)
    tracked_item.destroy unless tracked_item.nil?

    # TODO: this redirect may need to redirect a different place in some contexts
    redirect_to tracking_list_url(:id => @tracking_list)
  end
    
end
