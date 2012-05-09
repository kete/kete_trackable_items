class TrackingList < ActiveRecord::Base
  include Workflow
  include KeteTrackableItems::WorkflowUtilities

  has_many :tracked_items, :dependent => :destroy

  workflow do
    state :new do
      event :display, :transitions_to => :displayed
      event :hold_out, :transitions_to => :held_out
      event :loan, :transitions_to => :on_loan_to_organization
      event :queue_for_refiling, :transitions_to => :to_be_refiled
    end
    
    eval(shared_tracking_workflow_specs_as_string)

    state :cancelled
    state :completed
  end

  set_up_workflow_named_scopes.call
end
