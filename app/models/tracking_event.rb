class TrackingEvent < ActiveRecord::Base
  belongs_to :historical_item, :polymorphic => true

  # in some cases, we want to capture the object that
  # recieves the action of the verb by the historical item
  # i.e. a trackable item (historical_item) allocated to shelf location (historical_receiver)
  # or tracking_list (historical_item) loaned to on_loan_organization (historical_receiver)
  belongs_to :historical_receiver, :polymorphic => true

  validates_presence_of :historical_item, :message => lambda { I18n.t('trackable_item_shelf_location.shelf_location_blank_or_does_not_match') }
  validates_presence_of :verb, :event, :before_state
end
