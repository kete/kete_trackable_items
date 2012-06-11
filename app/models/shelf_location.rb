class ShelfLocation < ActiveRecord::Base
  include KeteTrackableItems::WorkflowUtilities

  belongs_to :repository
  has_many :trackable_item_shelf_locations, :dependent => :destroy

  # tracking history, can be historical_item or historical_receiver
  send :has_many, :tracking_events, :as => :historical_item, :dependent => :delete_all
  send :has_many, :tracking_receiving_events, :as => :historical_receiver, :dependent => :delete_all

  validates_uniqueness_of :code, :case_sensitive => false, :scope => :repository_id

  workflow do
    state :available do
      event :allocate, :transitions_to => :allocated
      event :deactivate, :transitions_to => :deactivated
    end
    
    state :allocated do
      # probably want to create an instance method for clear_out
      # that deactivates all trackable_item_shelf_locations
      event :clear_out, :transitions_to => :available
      event :deallocate, :transitions_to => :available
      # shelf_locations can have more than one trackable_item allocated to them
      event :allocate, :transitions_to => :allocated
    end

    state :deactivated do
      event :reactivate, :transitions_to => :available
    end

    on_transition do |from, to, event_name, *event_args|
      attribute_options = { :historical_item => self,
        :verb => to.to_s,
        :before_state => from.to_s,
        :event => event_name.to_s }

      attribute_options[:historical_receiver] = trackable_items.last if event_name == :allocate
      
      TrackingEvent.create!(attribute_options)
    end
  end

  set_up_workflow_named_scopes.call

  # returns a hash with trackable_item_type as key
  # and array of ids for that type as value
  def trackable_items_types_and_ids
    @trackable_items_types_and_ids = trackable_item_shelf_locations.with_state_active.inject(Hash.new) do |result, mapping_object|
      type_key = mapping_object.trackable_item_type
      item_id = mapping_object.trackable_item_id

      values = result[type_key] || Array.new
      values << item_id

      result[type_key] = values
      result
    end
  end

  # good enough for our purposes
  # WARNING: this is not a full association, but a hacked together collection
  def trackable_items
    @trackable_items = Array.new

    trackable_items_types_and_ids.each do |k,v|
      @trackable_items += k.constantize.find(v)
    end

    @trackable_items
  end

  def new_allocation
    allocate!
  end

  def mapping_deactivated_or_destroyed
    deallocate! if allocated? && trackable_items.size == 0
  end

  def clear_out
    trackable_item_shelf_locations.each do |mapping|
      mapping.make_deactivated
    end
  end

  def name_for_tracking_event
    repository.name + ': ' + code
  end
end
