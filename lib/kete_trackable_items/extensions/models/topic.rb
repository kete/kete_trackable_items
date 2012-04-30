# extensions to the kete topic model
Topic.class_eval do
  # adding trackable item functionality
  include TrackableItems
  set_up_trackable_items :described_as => :reference_title_date_range
  
end
