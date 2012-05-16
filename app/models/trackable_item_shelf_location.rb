class TrackableItemShelfLocation < ActiveRecord::Base
  include KeteTrackableItems::WorkflowUtilities

  belongs_to :shelf_location
  belongs_to :trackable_item, :polymorphic => true

  validates_presence_of :shelf_location, :message => lambda { I18n.t('trackable_item_shelf_location.shelf_location_blank_or_does_not_match') }
  validates_presence_of :trackable_item, :message => lambda { I18n.t('trackable_item_shelf_location.trackable_item_blank_or_does_not_match') }

  # needs to be unique to shelf_location to trackable_item
  validates_uniqueness_of :shelf_location_id, :scope => [:trackable_item_type, :trackable_item_id]

  delegate :repository, :to => :shelf_location, :allow_nil => true
  delegate :repository_id, :to => :shelf_location, :allow_nil => true
  delegate :code, :to => :shelf_location, :allow_nil => true

  workflow do
    state :active do
      event :deactivate, :transitions_to => :deactivated
    end
   
    state :deactivated do
      event :reactivate, :transitions_to => :active
    end
  end

  set_up_workflow_named_scopes.call
end
