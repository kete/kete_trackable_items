class TrackableItemsShelfLocations < ActiveRecord::Base
  belongs_to :shelf_locations
  belongs_to :trackable_items

end