# repository_id
# some sort of shelf description? 
# status - for deactivation

# relationship between trackable_item and shelf_location is polymorphic ??

class ShelfLocation < ActiveRecord::Base
  belongs_to :repository
  # you might be able to leave off the :polymorphic => true bit,
  # though you might have to specify :source => :trackable_item perhaps
  has_many :trackable_item_shelf_locations
  has_many :trackable_items, :through => :trackable_item_shelf_locations, :polymorphic => true

  # , :polymorphic => true - can't have has_many on polymorphic?
  #has_many :trackable_items, :through => :trackable_item_shelf_locations
  #has_many :trackable_items, :foreign_key => :trackable_item_id
  #has_many :trackable_items, :through => :trackable_item_shelf_locations, :source => :trackable_item, :source_type => 'Topic'


  #def self.trackable_items
  #  ShelfLocation.joins("LEFT OUTER JOIN trackable_item_shelf_locations ON trackable_item_shelf_locations.shelf_location_id = shelf_location.id")
  #end
end
