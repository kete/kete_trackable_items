class TrackingList < ActiveRecord::Base
  include Workflow
  include KeteTrackableItems::WorkflowUtilities

  belongs_to :repository

  has_many :tracked_items, :dependent => :destroy
  accepts_nested_attributes_for :tracked_items, :allow_destroy => true

  # tracking history, can be historical_item
  has_many :tracking_events, :as => :historical_item, :dependent => :delete_all

  # we want to list most recent first in most cases
  default_scope :order => 'created_at DESC'

  # set up workflow states, some are shared with trackable_items
  shared_code_as_string = shared_tracking_workflow_specs_as_string

  specification = Proc.new {
    state :new do
      # use a tracking list to allocate items in bulk to a shelf_location
      event :allocate, :transitions_to => :completed

      # manage handling of item after it has been assigned a shelf_location
      event :display, :transitions_to => :completed
      event :hold_out, :transitions_to => :completed
      event :loan, :transitions_to => :completed
      event :queue_for_refiling, :transitions_to => :completed
      event :refile, :transitions_to => :completed
      event :cancel, :transitions_to => :cancelled

      event :clear_list, :transitions_to => :new
    end

    eval(shared_code_as_string)

    # we replace to_be_refiled transitions with complete event only
    state :to_be_refiled do
      event :refile, :transitions_to => :completed
    end

    state :completed do
      event :reactivate, :transitions_to => :reactivated
    end

    state :reactivated do
      # use a tracking list to allocate items in bulk to a shelf_location
      event :allocate, :transitions_to => :completed

      # manage handling of item after it has been assigned a shelf_location
      event :display, :transitions_to => :completed
      event :hold_out, :transitions_to => :completed
      event :loan, :transitions_to => :completed
      event :queue_for_refiling, :transitions_to => :completed
      event :cancel, :transitions_to => :cancelled
    end

    state :cancelled

    on_transition do |from, to, event_name, *event_args|
      attribute_options = { :historical_item => self,
        :verb => to.to_s,
        :before_state => from.to_s,
        :event => event_name.to_s }

      if event_name == :loan && @on_loan_organization
        attribute_options[:historical_receiver] = @on_loan_organization
      end

      TrackingEvent.create!(attribute_options)
    end
  }

  workflow(&specification)

  set_up_workflow_named_scopes.call

  # send workflow event, except cancel, to tracked_items
  # upon event being called on tracking_list
  workflow_event_names.each do |event_name|
    skip_events = %w[cancel complete reactivate allocate]
    unless skip_events.include?(event_name.to_s)
      code = Proc.new {
        tracked_items.each do |tracked_item|
          tracked_item.trackable_item.send("#{event_name}!")
        end
      }

      define_method(event_name, &code)
    end
  end

  def name_for_tracking_event
    repository.name + ': ' + I18n.t('tracking_list.name_for_tracking_event.tracking_list') + ' ' + id.to_s
  end

  def loan_to(on_loan_organization)
    # TODO: optimize this, probably a query per tracked_item right now
    # possibly worthwhile to move to a backgroundrb process
    tracked_items.each do |tracked_item|
      trackable_item = tracked_item.trackable_item
      trackable_item.on_loan_organization = on_loan_organization
      trackable_item.save_without_revision
    end
    loan!
  end

  def clear_list
    tracked_items.each do |mapping|
      mapping.destroy
    end
  end
end
