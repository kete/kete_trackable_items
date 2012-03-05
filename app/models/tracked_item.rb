class TrackedItem < ActiveRecord::Base
  has_many :tracked_items
  
end