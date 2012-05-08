class TrackedItemsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable
  
  before_filter :get_trackable_item
  before_filter :get_tracking_list
  
  def create
    tracked_item = @trackable_item.tracked_items.build(@tracking_list)

    if tracked_item.save
      redirect_to tracking_list_url(:id => @tracking_list)
    end
  end


  def destroy
    tracked_item = @trackable_item.tracked_items.find_by_tracking_list_id(@tracking_list)
    tracked_item.destroy unless tracked_item.nil?

    # TODO: this redirect may need to redirect a different place in some contexts
    redirect_to tracking_list_url(:id => @tracking_list)
  end

  private
  
  def get_trackable_item
    type = params[:tracked_item_type]
    @trackable_item ||= type.classify.constantize.find_by_id(params[:tracked_item_id])
  end
  
  def get_tracking_list
    @tracking_list ||= TrackingList.find_by_id(params[:tracking_list_id])
  end
end
