require "active_record"

# Attributes
# box_number
# description
# state
# series_number
# current_location

module TrackableItems
  def self.included(base)
    base.extend(ClassMethods)
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