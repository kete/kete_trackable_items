class TrackingList < ActiveRecord::Base
  include Workflow
  include KeteTrackableItems::WorkflowUtilities

  belongs_to :repository

  has_many :tracked_items, :dependent => :destroy
  accepts_nested_attributes_for :tracked_items, :allow_destroy => true

  # set up workflow states, some are shared with trackable_items
  shared_code_as_string = shared_tracking_workflow_specs_as_string
  
  specification = Proc.new {
    state :new do
      event :display, :transitions_to => :displayed
      event :hold_out, :transitions_to => :held_out
      event :loan, :transitions_to => :on_loan_to_organization
      event :queue_for_refiling, :transitions_to => :to_be_refiled
      event :cancel, :transitions_to => :cancelled
    end
    
    eval(shared_code_as_string)

    # we replace to_be_refiled transitions with complete event only
    state :to_be_refiled do
      event :refile, :transitions_to => :completed
    end

    state :cancelled
    state :completed
  }
  
  workflow(&specification)

  set_up_workflow_named_scopes.call

  # send workflow event, except cancel, to tracked_items
  # upon event being called on tracking_list
  workflow_event_names.each do |event_name|
    unless event_name == 'cancel'
      code = Proc.new {
        tracked_items.each do |tracked_item|
          tracked_item.trackable_item.send("#{event_name}!")
        end
      }

      define_method(event_name, &code)
    end
  end
end
