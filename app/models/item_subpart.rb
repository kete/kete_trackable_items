class ItemSubpart < ActiveRecord::Base
  # Or should this be the topic?
  belongs_to :kete_trackable_item
  
  has_many: organisations
  has_many: shelf_locations
  
  # current_location e.g. display, held_out (rts), on_loan, => other_location (rts), re-filing, allocated => shelf_code
  
  
end