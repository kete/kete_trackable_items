class KeteTrackableItemsMigrationsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'create_repositories.rb', 'db/migrate', { :migration_file_name => "create_repositories" }
      m.sleep(1)
      m.migration_template 'create_tracking_lists.rb', 'db/migrate', { :migration_file_name => "create_tracking_lists" }
      m.sleep(1)
      m.migration_template 'create_shelf_locations.rb', 'db/migrate', { :migration_file_name => "create_shelf_locations" }
      m.sleep(1)
      m.migration_template 'create_tracked_items.rb', 'db/migrate', { :migration_file_name => "create_tracked_items" }
      m.sleep(1)
      m.migration_template 'create_trackable_item_shelf_locations.rb', 'db/migrate', { :migration_file_name => "create_trackable_item_shelf_locations" }
      m.sleep(1)
      m.migration_template 'create_on_loan_organizations.rb', 'db/migrate', { :migration_file_name => "create_on_loan_organizations" }
      m.sleep(1)
      m.migration_template 'add_trackable_item_columns_to_topics.rb', 'db/migrate', { :migration_file_name => "add_trackable_item_columns_to_topics" }
      m.sleep(1)
      m.migration_template 'create_tracking_events.rb', 'db/migrate', { :migration_file_name => "create_tracking_events" }
    end
  end
end
