class CreateShelfLocations < ActiveRecord::Migration
  def self.up
    create_table :shelf_locations do |t|
      t.text :code, :null => false
      t.integer :repository_id, :null => false
      f.text :status, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :shelf_locations
  end
end
