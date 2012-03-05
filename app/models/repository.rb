class Repository < ActiveRecord::Base
  # Archives Central, PNCC, WDC
  
  has_many :shelf_locations
    
end