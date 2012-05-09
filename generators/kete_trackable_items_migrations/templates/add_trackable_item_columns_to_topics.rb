class AddTrackableItemColumnsToTopics < ActiveRecord::Migration
  def self.up
    change_table :topics do |t|
      t.integer :on_loan_organization_id
      t.string :workflow_state, :default => 'unallocated', :null => false
    end
  end

  def self.down
    change_table :topics do |t|
      t.remove :on_loan_organization_id
      t.remove :workflow_state
    end
  end
end
