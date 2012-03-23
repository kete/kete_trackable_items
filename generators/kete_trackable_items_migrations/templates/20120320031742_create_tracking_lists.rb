class CreateTrackingLists < ActiveRecord::Migration
  def self.up
    create_table :tracking_lists do |t|
      # Could add this later
      #t.order_id :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :tracking_lists
  end

end
