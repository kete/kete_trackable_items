# repository_id
# some sort of shelf description? 
# status - for deactivation

class ShelfLocation < ActiveRecord::Base
  belongs_to :repository
  
  has_many :items

  #validates_uniqueness_of :shelfcode
  # shelf_code?
  # unknown location fields
  # normal rails date fields
end