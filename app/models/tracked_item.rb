class TrackedItem < ActiveRecord::Base
  belongs_to :tracking_list
  belongs_to :trackable_item, :polymorphic => true
  
  delegate :description_for_tracked_item, :to => :trackable_item

  # needs to be unique to tracking_list
  validates_uniqueness_of :tracking_list_id, :scope => [:trackable_item_type, :trackable_item_id]

  private

  def validate
    errors.add(:tracking_list, I18n.t('tracked_item.already_in_tracking_list')) if tracking_list.contains?(trackable_item)
  end
end
