# name Archives Central, PNCC, WDC
# other contact details?
class Repository < ActiveRecord::Base
  # we inherit security from our basket
  # site basket == can see all repositories
  # otherwise must be associated to the basket we are within
  belongs_to :basket

  has_many :shelf_locations
    
end
