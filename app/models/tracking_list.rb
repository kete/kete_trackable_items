class TrackingList < ActiveRecord::Base
  belongs_to :tracking_list
  belongs_to :item, :polymorphic => true
  
  has_many :items
  
  delegate :description_for_tracked_item, :to => :item
  
end