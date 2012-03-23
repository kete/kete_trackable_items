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

      state :allocated do
        event :display, :transitions_to => :display
        event :held_out, :transitions_to => :held_out
        event :on_loan_organisation, :transitions_to => :on_loan_organisation
      end

      state :display do
        event :held_out, :transitions_to => :held_out
        event :on_loan_organisation, :transitions_to => :on_loan_organisation
        event :to_be_refiled, :transitions_to => :to_be_refiled
      end

      state :held_out do
        # to complete
      end

      state :on_loan_organisation do
        # to complete
      end
      
      # This looks like it might be a state too or a substate of one of the others
      state :to_be_refiled do

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

  module InstanceMethods

  end
end