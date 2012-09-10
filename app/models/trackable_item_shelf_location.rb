require 'ar-extensions'
class TrackableItemShelfLocation < ActiveRecord::Base
  include KeteTrackableItems::WorkflowUtilities

  after_create :update_state_of_shelf_location_and_trackable_item

  # after destroy, change state of trackable_item and shelf_location
  after_destroy :send_deactivated_to_associations

  belongs_to :shelf_location
  belongs_to :trackable_item, :polymorphic => true

  validates_presence_of :shelf_location_id, :message => lambda { I18n.t('trackable_item_shelf_location.shelf_location_blank_or_does_not_match') }
  validates_presence_of :trackable_item, :message => lambda { I18n.t('trackable_item_shelf_location.trackable_item_blank_or_does_not_match') }

  # needs to be unique to shelf_location to trackable_item
  validates_uniqueness_of :shelf_location_id, :scope => [:trackable_item_type, :trackable_item_id], :message => lambda { I18n.t('trackable_item_shelf_location.previously_allocated_reactivate_instead') }

  delegate :repository, :to => :shelf_location, :allow_nil => true
  delegate :repository_id, :to => :shelf_location, :allow_nil => true
  delegate :code, :to => :shelf_location, :allow_nil => true
  delegate :description_for_tracked_item, :to => :trackable_item, :allow_nil => true

  workflow do
    state :active do
      event :deactivate, :transitions_to => :deactivated
    end
   
    state :deactivated do
      event :reactivate, :transitions_to => :active
    end
  end

  set_up_workflow_named_scopes.call

  def tell_associations_deactivated_or_destroyed
    shelf_location.mapping_deactivated_or_destroyed
    trackable_item.mapping_deactivated_or_destroyed
  end

  def deactivate
    tell_associations_deactivated_or_destroyed
  end

  def make_deactivated
    deactivate!
  end

  def tell_associations_reactivated
    shelf_location.mapping_reactivated
    trackable_item.mapping_reactivated
  end

  def reactivate
    tell_associations_reactivated
  end

  private
  
  def update_state_of_shelf_location_and_trackable_item
    shelf_location.new_allocation
    trackable_item.new_allocation
  end

  def send_deactivated_to_associations
    tell_associations_deactivated_or_destroyed
  end
end
