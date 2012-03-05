class Repository < ActiveRecord::Base
  # Archives Central, PNCC, WDC
  
  has_many :shelf_locations
  
  validates_uniqueness_of :shelf_code
  
end