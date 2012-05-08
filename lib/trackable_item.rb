require "active_record"

# Attributes
# box_number
# description
# state
# series_number
# current_location

# possible states:
# => allocated, display, held_out, on_loan_organisation,  (specified from external data source?)

module TrackableItem
  def self.included(base)
    base.extend(ClassMethods)

    base.class_eval do
      include Workflow
      workflow do
        state :unallocated do
          event :allocate, :transitions_to => :on_shelf
        end

        state :on_shelf do
          event :display, :transitions_to => :displayed
          event :hold_out, :transitions_to => :held_out
          event :loan, :transitions_to => :on_loan_to_organisation
        end

        state :displayed do
          event :hold_out, :transitions_to => :held_out
          event :loan, :transitions_to => :on_loan_to_organisation
          event :queue_for_refiling, :transitions_to => :to_be_refiled
        end

        state :held_out do
          event :loan, :transitions_to => :on_loan_to_organisation
          event :queue_for_refiling, :transitions_to => :to_be_refiled
        end

        state :on_loan_to_organisation do
          event :display, :transitions_to => :displayed
          event :hold_out, :transitions_to => :held_out
          event :queue_for_refiling, :transitions_to => :to_be_refiled
        end

        # This looks like it might be a state too or a substate of one of the others
        state :to_be_refiled do
          event :refile, :transitions_to => :on_shelf
          # Not sure if it makes sense to be able to go to any other states from here
        end
      end
    end

  end

  module ClassMethods
    def set_up_as_trackable_item(*args)
      options = args.last.is_a?(Hash) ? args.pop : Hash.new

      # don't allow multiple calls
      return if self.included_modules.include?(TrackableItem::InstanceMethods)

      send :include, TrackableItem::InstanceMethods

      # May be necessary: , :dependent => :delete_all
      send :has_many, :trackable_item_shelf_locations, :as => :trackable_item, :dependent => :delete_all
      send :has_many, :shelf_locations, :through => :trackable_item_shelf_locations
      #acts_as :trackable_item

      # not sure if it has many/what about subitems?
      send :has_one, :on_loan_organisations

      # set up the ability to be added to a tracking list, etc.
      has_many :tracked_items, :as => :trackable_item, :dependent => :delete_all
      send :has_many, :tracking_lists, :through => :tracked_items

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
      shelf_locations.size > 1
    end

  end
end
