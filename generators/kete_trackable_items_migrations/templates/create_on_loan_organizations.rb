class CreateOnLoanOrganizations < ActiveRecord::Migration
  def self.up
    create_table :on_loan_organizations do |t|
      t.string :name, :null => false
      t.text :contact_details

      t.timestamps
    end
  end

  def self.down
    drop_table :on_loan_organizations
  end
end
