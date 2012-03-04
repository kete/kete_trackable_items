require "active_record"

module KeteTrackableItems
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def set_up_kete_trackable_items(*args)
      options = args.last.is_a?(Hash) ? args.pop : Hash.new

      # don't allow multiple calls
      return if self.included_modules.include?(KeteTrackableItems::InstanceMethods)
      
      send :include, KeteTrackableItems::InstanceMethods
      
    end
  
  end
  
  module InstanceMethods

  end
end