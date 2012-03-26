class TrackedItemsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable
  
  before_filter :get_trackable_item
  before_filter :get_trackable_item
  before_filter :get_user
  before_filter :get_tracked_item, :except => [:new, :index, :create]
  
  protected
  
  def get_trackable_item
    @tracked_item ||= @trackable_item.tracked_items.find(params[:id])
  end
  
  def get_trackable_item
    @trackable_item ||= @trackable_item_class.present? ? @trackable_item_class.find(params[@trackable_item_key]) : nil
  end
    
  def get_user
    @user = current_user
  end
end