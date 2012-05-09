# extensions to the kete topic model
Topic.class_eval do
  # adding trackable item functionality
  include KeteTrackableItems::TrackableItem
  set_up_as_trackable_item :described_as => :reference_title_date_range
end
