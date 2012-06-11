class CreateTrackingEvents < ActiveRecord::Migration
  def self.up
    create_table :tracking_events do |t|
      t.integer :historical_item_id, :null => false, :references => nil
      t.string :historical_item_type, :null => false
      t.string :verb, :before_state, :event, :null => false
      t.text :note

      t.integer :historical_receiver_id, :references => nil
      t.string :historical_receiver_type

      t.timestamps
    end
  end

  def self.down
    drop_table :tracking_events
  end
end
