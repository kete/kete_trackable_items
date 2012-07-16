require 'ar-extensions'
class TrackedItem < ActiveRecord::Base
  belongs_to :tracking_list
  belongs_to :trackable_item, :polymorphic => true
  
  delegate :description_for_tracked_item, :to => :trackable_item

  validates_presence_of :tracking_list, :message => lambda { I18n.t('tracked_item.tracking_list_blank_or_does_not_match') }
  validates_presence_of :trackable_item, :message => lambda { I18n.t('tracked_item.trackable_item_blank_or_does_not_match') }

  # needs to be unique to tracking_list
  validates_uniqueness_of :tracking_list_id, :scope => [:trackable_item_type, :trackable_item_id]

  private

  def validate
    errors.add(:tracking_list, I18n.t('tracked_item.already_in_tracking_list')) if tracking_list.tracked_items.include?(self)
  end
end
