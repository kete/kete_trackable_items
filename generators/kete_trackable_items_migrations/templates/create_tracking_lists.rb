class CreateTrackingLists < ActiveRecord::Migration
  def self.up
    create_table :tracking_lists do |t|
      t.integer :repository_id, :null => false
      t.string :workflow_state, :default => 'new', :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :tracking_lists
  end

end
