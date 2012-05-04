class TrackedItemsController < ApplicationController
  # Prevents the following error from showing up, common in Rails engines
  # A copy of ApplicationController has been removed from the module tree but is still active!
  unloadable
  
  ##########
  # NOTES FOR CHRIS
  # missing link was adding this to Topic in archives central
  #    has_many :tracked_items, :as => :trackable_item, :dependent => :destroy
  # if you look at trollied in lib/gets_trollied`
  # there is this bit of magic

  # module ClassMethods
  #   def set_up_to_get_trollied(*args)

  #     send :has_many, :line_items, :as => :purchasable_item, :dependent => :destroy
  # thats where all the models become purchaseable_items
  # guessing we will need something like that in the trackable items gem as well
  # once we have a trackable_item adding and removing things from the list is not so bad.

  # I did this in the console
  # >> t = Topic.last
  # >> tl = TrackingList.last
  # >> tracked_item = t.tracked_items.build :tracking_list => tl
  # >> tracked_item.save
  # => true
  # >> TrackedItem.count
  # => 1
  # >> z = t.tracked_items.find_by_tracking_list_id tl
  # => #<TrackedItem id: 3, tracking_list_id: 3, trackable_item_id: 106775, trackable_item_type: "Topic", created_at: "2012-05-04 05:25:07", updated_at: "2012-05-04 05:25:07">
  # >> z.destroy
  # >> TrackedItem.count
  # => 0

  before_filter :get_trackable_item
  before_filter :get_tracking_list
  before_filter :get_user
  
  def create
    tracked_item = @trackable_item.tracked_items.build(@trracking_list)

    if tracked_item.save
      redirect_to url_for_tracking_list(@trracking_list.id)
    end
  end


  def destroy
    tracked_item = @trackable_item.tracked_items.find_by_tracking_list_id(@trracking_list)
    tracked_item.destroy unless tracked_item.nil?
  end

  protected
  
  def get_trackable_item
    type = params[:tracked_item_type]
    @trackable_item ||= type.classify.constantize.find_by_id(params[:tracked_item_id])
  end
  
  def get_tracking_list
    @trracking_list ||= TrackingList.find_by_id(params[:tracking_list_id])
  end
    
  def get_user
    @user = current_user
  end
end