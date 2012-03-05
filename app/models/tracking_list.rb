class TrackingList < ActiveRecord::Base
  has_many :trackable_items
  
end