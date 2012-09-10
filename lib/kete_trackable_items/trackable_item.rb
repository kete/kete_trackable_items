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

        # tracking history, can be historical_item or historical_receiver
        send :has_many, :tracking_events, :as => :historical_item, :dependent => :delete_all
        send :has_many, :tracking_receiving_events, :as => :historical_receiver, :dependent => :delete_all

        # when a trackable_item is in 'on_loan' state, which on_loan_organization is it on loan to?
        send :belongs_to, :on_loan_organization

        self.non_versioned_columns << "on_loan_organization_id"
        
        OnLoanOrganization.has_many(self.name.tableize.to_sym)

        cattr_accessor :described_as_in_tracking_list
        self.described_as_in_tracking_list = options[:described_as] || :title

        # set up our states and events through workflow gem
        send :include, KeteTrackableItems::WorkflowUtilities
    
        class_eval do
          shared_code_as_string = shared_tracking_workflow_specs_as_string

          specification = Proc.new {
            state :unallocated do
              event :allocate, :transitions_to => :on_shelf
              event :display, :transitions_to => :displayed
              event :hold_out, :transitions_to => :held_out
              event :loan, :transitions_to => :on_loan_to_organization
            end

            eval(shared_code_as_string)

            state :to_be_refiled do
              event :refile, :transitions_to => :on_shelf
            end

            on_transition do |from, to, event_name, *event_args|
              attribute_options = { :historical_item => self,
                :verb => to.to_s,
                :before_state => from.to_s,
                :event => event_name.to_s }

              historical_receiver = nil
              case event_name
              when :allocate
                historical_receiver = shelf_locations.last
              when :loan
                historical_receiver = on_loan_organization
              end

              attribute_options[:historical_receiver] = historical_receiver if historical_receiver

              TrackingEvent.create!(attribute_options)
            end
          }

          workflow(&specification)

          set_up_workflow_named_scopes.call
        end

        self.non_versioned_columns << "workflow_state"

        # only to be used in combination with some other scope
        # otherwise you run the possibility of returning an aweful lot of objects!
        named_scope :not_one_of_these, lambda { |ids| { :conditions => ["id not in ('#{ids.join("\',\'")}')", ids] } }

        named_scope :not_in_these_baskets, lambda { |ids| { :conditions => ["basket_id not in ('#{ids.join("\',\'")}')", ids] } }
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

      alias :name_for_tracking_event :description_for_tracked_item

      # add workflow triggered methods that run when corresponding event is triggered as necessary
      def new_allocation
        allocate!
      end

      def mapping_deactivated_or_destroyed
        # only deallocate if this the last active trackable_item_shelf_location
        unassign_location! if on_shelf? && shelf_locations.size == 1
      end

      def mapping_reactivated
        allocate!
      end
    end
  end
end
