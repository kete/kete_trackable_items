class Box < ActiveRecord::Base
  has_many :item_subparts
  # or just kete_trackable_items?
  
  # box_number string
end