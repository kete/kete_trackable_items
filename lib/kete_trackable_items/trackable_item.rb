require "active_record"

module KeteTrackableItems
  module TrackableItem
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def set_up_as_trackable_item(*args)
        options = args.last.is_a?(Hash) ? args.pop : Hash.new

        # don't allow multiple calls
        return if self.included_modules.include?(KeteTrackableItems::TrackableItem::InstanceMethods)

        send :include, KeteTrackableItems::TrackableItem::InstanceMethods

        # associations to support allocating a trackable_item to a shelf_location or shelf_locations
        send :has_many, :trackable_item_shelf_locations, :as => :trackable_item, :dependent => :delete_all
        send :has_many, :shelf_locations, :through => :trackable_item_shelf_locations, :conditions => "trackable_item_shelf_locations.workflow_state = 'active'"
        # associations to support adding a trackable_item to a tracking_list
        send :has_many, :tracked_items, :as => :trackable_item, :dependent => :delete_all
        send :has_many, :tracking_lists, :through => :tracked_items

        # when a trackable_item is in 'on_loan' state, which on_loan_organization is it on loan to?
        send :belongs_to, :on_loan_organization

        self.non_versioned_columns << "on_loan_organization_id"

        cattr_accessor :described_as_in_tracking_list
        self.described_as_in_tracking_list = options[:described_as] || :title

        # set up our states and events through workflow gem
        send :include, KeteTrackableItems::WorkflowUtilities
    
        class_eval do
          shared_code_as_string = shared_tracking_workflow_specs_as_string

          specification = Proc.new {
            state :unallocated do
              event :allocate, :transitions_to => :on_shelf
            end

            eval(shared_code_as_string)

            state :to_be_refiled do
              event :refile, :transitions_to => :on_shelf
            end
          }

          workflow(&specification)

          set_up_workflow_named_scopes.call
        end

        self.non_versioned_columns << "workflow_state"
      end
    end

    module InstanceMethods
      # could be called is_allocated_to_shelf ?
      def has_shelf_locations?
        shelf_locations.size > 0
      end

      def description_for_tracked_item
        send(self.class.described_as_in_tracking_list)
      end

      # add workflow triggered methods that run when corresponding event is triggered as necessary
      def new_allocation
        allocate! unless on_shelf? # a previous addition of shelf location may have triggered transition to on_shelf
      end

      def mapping_deactivated_or_destroyed
        unassign_location! if on_shelf? && !has_shelf_locations?
      end
    end
  end
end
