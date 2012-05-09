class CreateTrackableItemShelfLocations < ActiveRecord::Migration
  def self.up
    create_table :trackable_item_shelf_locations do |t|
      t.integer :shelf_location_id, :null => false
      t.integer :trackable_item_id, :null => false, :references => nil
      t.string :trackable_item_type, :null => false
      t.string :workflow_state, :default => 'active', :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :trackable_item_shelf_locations
  end
end
