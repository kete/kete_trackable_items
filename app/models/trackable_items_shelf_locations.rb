class TrackableItemsShelfLocations < ActiveRecord::Base
  belongs_to :shelf_location
  belongs_to :trackable_item

end