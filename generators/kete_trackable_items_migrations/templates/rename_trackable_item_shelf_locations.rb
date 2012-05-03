class RenameTrackableItemShelfLocations < ActiveRecord::Migration
  def self.up
    rename_table :trackable_items_shelf_locations, :trackable_item_shelf_locations
  end

  def self.down
    rename_table :trackable_item_shelf_locations, :trackable_items_shelf_locations
  end
end
