class TrackedItemsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable

  before_filter :get_tracked_item, :except => [:create]
  before_filter :get_trackable_item
  before_filter :get_tracking_list

  permit "site_admin or admin of :site_basket or admin of :current_basket"

  def create
    tracked_item = @trackable_item.tracked_items.build(@tracking_list)

    redirect_to tracking_list_url(:id => @tracking_list) if tracked_item.save
  end

  def destroy
    tracked_item = @trackable_item.tracked_items.find(@tracked_item)
    tracked_item.destroy unless tracked_item.nil?

    # TODO: this redirect may need to redirect a different place in some contexts
    redirect_to repository_tracking_list_url(:id => @tracking_list, :repository_id => @tracking_list.repository)
  end

  private

  def get_tracked_item
    @tracked_item = TrackedItem.find(params[:id])
  end

  def get_trackable_item
    if @tracked_item
      @trackable_item = @tracked_item.trackable_item
    else
      type = params[:tracked_item_type]
      @trackable_item ||= type.classify.constantize.find(params[:tracked_item_id])
    end
  end

  def get_tracking_list
    @tracking_list ||= TrackingList.find(params[:tracking_list_id])
  end
end
