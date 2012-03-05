class ShelfLocation < ActiveRecord::Base
  belongs_to :repository
  
  has_many :boxes
  has_many :item_subparts

  validates_uniqueness_of :shelfcode
  # shelf_code?
  # unknown location fields
  # normal rails date fields
end