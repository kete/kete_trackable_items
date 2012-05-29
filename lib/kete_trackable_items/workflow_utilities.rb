module KeteTrackableItems
  module WorkflowUtilities
    def self.included(base)
      base.send :include, Workflow
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
    end
    
    # mostly grabbed from trollied, would be nice if split into shared lib
    module ClassMethods
      # returns a Hash where keys are event name and values are event object
      def workflow_events
        events = workflow_spec.states.values.collect &:events

        # skip blank values
        events = events.select { |e| e.present? }

        # flatten
        events_hash = Hash.new
        events.each do |v|
          v.each do |key,value|
            events_hash[key] = value
          end
        end

        events_hash
      end

      def workflow_event_names
        workflow_events.keys
      end

      # kete_trackable_items specific stuff starts
      def shared_tracking_workflow_specs_as_string
        '
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
        '
      end

      def set_up_workflow_named_scopes
        Proc.new {
          # create a named_scope for each of our declared states
          workflow_spec.state_names.each do |name|
            scope_name = "with_state_#{name}".to_sym
            named_scope scope_name, :conditions => { :workflow_state => name.to_s }, :order => 'updated_at DESC'
          end

          # workflow_in(state_name)
          named_scope :workflow_in, lambda { |*args|
            options = args.last.is_a?(Hash) ? args.pop : Hash.new
            state = args.is_a?(Array) ? args.first : args
            
            if state == 'all'
              options
            else
              { :conditions => { :workflow_state => state.to_s }.merge(options) }
            end
          }
        }
      end
    end

    module InstanceMethods
      def current_state_humanized
        current_state.name.to_s.humanize
      end
    end
  end
end
