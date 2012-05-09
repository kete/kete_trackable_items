class TrackingList < ActiveRecord::Base
  include Workflow
  include KeteTrackableItems::WorkflowUtilities

  belongs_to :repository
  has_many :tracked_items, :dependent => :destroy

  # set up workflow states, some are shared with trackable_items
  shared_code_as_string = shared_tracking_workflow_specs_as_string
  
  specification = Proc.new {
    state :new do
      event :display, :transitions_to => :displayed
      event :hold_out, :transitions_to => :held_out
      event :loan, :transitions_to => :on_loan_to_organization
      event :queue_for_refiling, :transitions_to => :to_be_refiled
    end
    
    eval(shared_code_as_string)

    state :cancelled
    state :completed
  }
  
  workflow(&specification)

  set_up_workflow_named_scopes.call
end
