# extensions to the kete topic model
Topic.class_eval do
  # adding trackable item functionality
  include TrackableItems
  set_up_trackable_items :described_as => :reference_title_date_range

  has_many :shelf_locations, :through => :trackable_item_shelf_location
  #has_many :trackable_items_shelf_locations

end
