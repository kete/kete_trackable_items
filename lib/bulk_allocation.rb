module BulkAllocation
  # Export the current Mappings of shelf locations for trackable items
  def export(basket)
    con = ActiveRecord::Base.connection
    topic_to_shelf_mapping = con.select_all("SELECT
                      SUBSTR(extended_content,
                        LOCATE('<legacy_identifier xml_element_name=\"dc:identifier\">', extended_content) + LENGTH('<legacy_identifier xml_element_name=\"dc:identifier\">'),
                        LOCATE('</legacy_identifier>', extended_content) - LOCATE('<legacy_identifier xml_element_name=\"dc:identifier\">', extended_content) - LENGTH('<legacy_identifier xml_element_name=\"dc:identifier\">')
                      ) as legacy_id,
                      sl.code as shelf_location,
                      r.name as repository
                    FROM topics t
                    LEFT OUTER JOIN trackable_item_shelf_locations ts
                      ON (ts.trackable_item_id = t.id)
                    LEFT OUTER JOIN shelf_locations sl
                      ON (sl.id = ts.shelf_location_id)
                    LEFT OUTER JOIN repositories r
                      ON (r.id = sl.repository_id)
                    WHERE
                      t.basket_id = #{con.quote basket.id}
                    AND extended_content LIKE #{con.quote '%legacy_identifier%'}")

    file = Tempfile.new("export-#{Time.now.strftime '%Y%m%d-%H%M'}.xlsx", "#{Rails.root.to_s}/tmp/")
    ExcelDoc.new(file.path).write(topic_to_shelf_mapping)

    file.rewind # just in case

    file
  end

  # Import the new mappings of shelf locations for trackable items
  def import(file)
    rows = ExcelDoc.new(file).read(row_class=MapFromExcel)
    locations = Hash.new
    repositories = Hash.new

    rows.each do |row|
      matching_topic = Topic.find(:first, :conditions =>
        ["extended_content like ?", "%<legacy_identifier xml_element_name=\"dc:identifier\">#{row.legacy_id}</legacy_identifier>%"])
      next if matching_topic.nil?

      repository = repositories[row.repository] ||= Repository.find(:first, :conditions => ['name = ? or id = ?', row.repository, row.repository])

      matching_location = locations[row.shelf_location] ||= repository.shelf_locations.find_by_code(row.shelf_location)
      if matching_location.nil?
        matching_location = locations[row.shelf_location] = repository.shelf_locations.create(:code => row.shelf_location)
      end

      # Create or update shelf location for topics
      if matching_topic.shelf_location_ids.present?
        ts = TrackableItemShelfLocation.find(:first, :conditions => ['trackable_item_id=?', matching_topic.id])
      else
        ts = TrackableItemShelfLocation.new :trackable_item => matching_topic
      end
      ts.shelf_location = matching_location
      ts.save
    end
  end

  module_function :export, :import
end
