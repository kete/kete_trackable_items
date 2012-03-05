require "active_record"

module TrackableItems
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def set_up_trackable_items(*args)
      options = args.last.is_a?(Hash) ? args.pop : Hash.new

      # don't allow multiple calls
      return if self.included_modules.include?(KeteTrackableItems::InstanceMethods)
      
      send :include, TrackableItems::InstanceMethods
      
      send :has_many, :shelf_locations
      send :has_many, :items
      
      # box_number
      # state
      
      # series_number
    
    def description_for_tracked_item
      
    end
  
  end
  
  module InstanceMethods

  end
end