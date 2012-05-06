class MigrationsGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      record do |m|
            m.migration_template 'create_tracking_list.rb', 'db/migrate', { :migration_file_name => "create_tracking_list" }
            m.sleep(1)
            m.migration_template 'create_repositories.rb', 'db/migrate', { :migration_file_name => "create_repositories" }
            m.sleep(1)
            m.migration_template 'create_shelf_locations.rb', 'db/migrate', { :migration_file_name => "create_shelf_locations" }
            m.sleep(1)
            m.migration_template 'create_tracked_items.rb', 'db/migrate', { :migration_file_name => "create_tracked_items" }
            m.sleep(1)
            m.migration_template 'create_trackable_item_shelf_locations.rb', 'db/migrate', { :migration_file_name => "create_trackable_item_shelf_locations" }
          end
    end
  end
end
