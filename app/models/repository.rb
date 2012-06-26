# name Archives Central, PNCC, WDC
# other contact details?
class Repository < ActiveRecord::Base
  # we inherit security from our basket
  # site basket == can see all repositories
  # otherwise must be associated to the basket we are within
  belongs_to :basket

  has_many :shelf_locations, :dependent => :destroy
  has_many :tracking_lists, :dependent => :destroy

  validates_uniqueness_of :name, :case_sensitive => false

  # we want to list alphabetically by repository name in most cases
  default_scope :order => 'name ASC'
end
