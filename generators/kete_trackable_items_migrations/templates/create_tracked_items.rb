class CreateTrackedItems < ActiveRecord::Migration
  def self.up
    create_table :tracked_items do |t|
      t.integer :tracking_list_id, :null => false
      t.integer :trackable_item_id, :null => false, :references => nil
      t.string :trackable_item_type, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :tracked_items
  end
end
