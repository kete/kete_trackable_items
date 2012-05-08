# repository_id
# some sort of shelf description? 
# status - for deactivation

# relationship between trackable_item and shelf_location is polymorphic ??

class ShelfLocation < ActiveRecord::Base
  belongs_to :repository
  has_many :trackable_item_shelf_locations

  validates_uniqueness_of :code, :case_sensitive => false, :scope => :repository_id

  # returns a hash with trackable_item_type as key
  # and array of ids for that type as value
  def trackable_items_types_and_ids
    @trackable_items_types_and_ids = trackable_item_shelf_locations.inject(Hash.new) do |result, mapping_object|
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

end
