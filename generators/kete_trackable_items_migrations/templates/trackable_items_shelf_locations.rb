class TrackableItemsShelfLocations < ActiveRecord::Migration
  def self.up
    create_table :trackable_items_shelf_locations do |t|
      t.integer :shelf_location_id, :null => false
      t.integer :trackable_item_id, :null => false
      t.string :trackable_item_type, :null => false
      t.text :status, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :trackable_items_shelf_locations
  end
end
