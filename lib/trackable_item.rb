require "active_record"

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
          event :loan, :transitions_to => :on_loan_to_organization
        end

        state :displayed do
          event :hold_out, :transitions_to => :held_out
          event :loan, :transitions_to => :on_loan_to_organization
          event :queue_for_refiling, :transitions_to => :to_be_refiled
        end

        state :held_out do
          event :loan, :transitions_to => :on_loan_to_organization
          event :queue_for_refiling, :transitions_to => :to_be_refiled
        end

        state :on_loan_to_organization do
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

      # associations to support allocating a trackable_item to a shelf_location or shelf_locations
      send :has_many, :trackable_item_shelf_locations, :as => :trackable_item, :dependent => :delete_all
      send :has_many, :shelf_locations, :through => :trackable_item_shelf_locations

      # associations to support adding a trackable_item to a tracking_list
      send :has_many, :tracked_items, :as => :trackable_item, :dependent => :delete_all
      send :has_many, :tracking_lists, :through => :tracked_items

      # when a trackable_item is in 'on_loan' state, which on_loan_organization is it on loan to?
      send :has_one, :on_loan_organization
    end
  end

  module InstanceMethods
    # could be called is_allocated_to_shelf ?
    def has_shelf_location?
      shelf_locations.size > 1
    end
    
    # TODO: add workflow triggered methods that run when corresponding event is triggered
    # as necessary
  end
end
