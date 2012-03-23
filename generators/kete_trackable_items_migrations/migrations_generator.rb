class MigrationsGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # Walter: If you are happy with this approach I'll add the rest of the migrations
      m.file "20120320031742_create_tracking_lists.rb",   "db/migrate/20120320031742_create_tracking_lists.rb"
    end
  end
end