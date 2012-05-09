class TrackableItemShelfLocation < ActiveRecord::Base
  include KeteTrackableItems::WorkflowUtilities

  belongs_to :shelf_location
  belongs_to :trackable_item, :polymorphic => true

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
