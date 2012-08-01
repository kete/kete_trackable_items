class CreateShelfLocations < ActiveRecord::Migration
  def self.up
    create_table :shelf_locations do |t|
      t.string :code, :null => false
      t.integer :repository_id, :null => false
      t.string :workflow_state, :default => 'empty', :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :shelf_locations
  end
end
