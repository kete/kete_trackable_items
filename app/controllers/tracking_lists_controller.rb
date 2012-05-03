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

  def new
    @tracking_list = TrackingList.new 
    @tracking_list.save
    render :action => "show",:id=>@tracking_list.id
  end
    
end