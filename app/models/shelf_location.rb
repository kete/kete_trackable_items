# repository_id
# some sort of shelf description? 
# status - for deactivation

# relationship between trackable_item and shelf_location is polymorphic ??

class ShelfLocation < ActiveRecord::Base
  belongs_to :repository
  # you might be able to leave off the :polymorphic => true bit,
  # though you might have to specify :source => :trackable_item perhaps
  has_many :trackable_item_shelf_locations
  has_many :trackable_items, :through => :trackable_item_shelf_locations
  # or has_many :trackable_item_shelf_locations
end
