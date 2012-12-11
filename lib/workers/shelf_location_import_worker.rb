class ShelfLocationImportWorker < BackgrounDRb::MetaWorker
  set_worker_name :shelf_location_import_worker

  def create(args = nil)
    # Just in case
  end

  def import(file)
    logger = Logger.new("#{Rails.root.to_s}/log/import.log")
    logger.level 0
    logger.debug "hello!"
  end
end
