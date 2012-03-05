class TrackedItem < ActiveRecord::Base
  
  belongs_to :tracking_list
  belongs_to :trackable_item, :polymorphic => true
  
  delegate :description_for_tracked_item, :to => :item
  
end