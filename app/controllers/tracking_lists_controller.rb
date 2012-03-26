class TrackingListsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable
  
  before_filter :get_trackable_items_user
  before_filter :get_tracking_list
  
  def show
    respond_to do |format|
      format.html
    end
  end
  
  protected

  def get_trackable_items_user
    @trackable_items_user = User.find(params[:user_id])
  end

  def get_tracking_list
    @tracking_list = @trackable_items_user.tracking_list
  end
  
end