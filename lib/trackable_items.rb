require "active_record"

# Attributes
# box_number
# description
# state
# series_number
# current_location

# possible states:
# => allocated, display, held_out, on_loan_organisation,  (specified from external data source?)

module TrackableItems
  def self.included(base)
    base.extend(ClassMethods)

    base.class_eval do
      include Workflow
      workflow do
        state :waiting_to_be_on_shelf do
          event :put_on_shelf, :transitions_to => :on_shelf
        end

        state :on_shelf do
          event :put_on_display, :transitions_to => :displayed
          event :hold_out, :transitions_to => :held_out
          event :loan, :transitions_to => :on_loan_to_organisation
        end

        state :displayed do
          event :hold_out, :transitions_to => :held_out
          event :loan, :transitions_to => :on_loan_to_organisation
          event :make_ready_to_refile, :transitions_to => :waiting_to_be_refiled
        end

        state :held_out do
          event :loan, :transitions_to => :on_loan_to_organisation
          event :make_ready_to_refile, :transitions_to => :waiting_to_be_refiled
        end

        state :on_loan_to_organisation do
          event :put_on_display, :transitions_to => :displayed
          event :hold_out, :transitions_to => :held_out
          event :make_ready_to_refile, :transitions_to => :waiting_to_be_refiled
        end

        # This looks like it might be a state too or a substate of one of the others
        state :waiting_to_be_refiled do
          event :put_on_shelf, :transitions_to => :on_shelf
          # Not sure if it makes sense to be able to go to any other states from here
        end

      end
    end

  end

  module ClassMethods
    def set_up_trackable_items(*args)
      options = args.last.is_a?(Hash) ? args.pop : Hash.new

      # don't allow multiple calls
      return if self.included_modules.include?(TrackableItems::InstanceMethods)

      send :include, TrackableItems::InstanceMethods

      send :has_many, :shelf_locations
      # not sure if it has many/what about subitems?
      send :has_one, :on_loan_organisations

      def description_for_tracked_item

      end

      # Define workflow methods
      def allocated

      end

      def display

      end

      def held_out

      end

      def on_loan_organisation

      end

      def to_be_refiled

      end
    end
  end

  module InstanceMethods
    # could be called is_allocated_to_shelf ?
    def has_shelf_location?
      if shelf_locations.size > 0
    end


  end
end