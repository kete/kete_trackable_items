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

      end

      state :display do

      end

      state :held_out do

      end

      state :on_loan_organisation do

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

  end

  module InstanceMethods

  end
end