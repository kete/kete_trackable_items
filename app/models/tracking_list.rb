# item_id
# normal rails dates, id  
class TrackingList < ActiveRecord::Base
  has_many :tracked_items, :dependent => :destroy
  
  # belongs_to :on_loan_organization ??  
end