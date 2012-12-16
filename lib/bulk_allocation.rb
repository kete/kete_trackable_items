require 'excel_doc'

class MapFromExcel < ExcelRow
  def legacy_id
    self[:legacy_id]
  end

  def shelf_location
    self[:shelf_location]
  end

  def repository
    self[:repository]
  end
end

class BulkAllocation
  extend ExtendedContentHelpers
  extend ExtendedContentScopeHelpers
  # Export the current Mappings of shelf locations for trackable items
  def self.export(basket)
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
  def self.import(file)
    rows = ExcelDoc.new(file).read(row_class=MapFromExcel)
    locations = Hash.new
    repositories = Hash.new

    #$logger = Logger.new("#{Rails.root.to_s}/log/uber.log")
    #$logger.level = 0

    rows.each do |row|
      #$logger.debug "Row: #{row.inspect}"
      repository = repositories[row[:repository]] ||= Repository.find(:first, :conditions => ['name = ? or id = ?', row[:repository], row[:repository]])
      if repository.nil?
        #$logger.warn "Could not find matching repository for: #{row[:repository]}"
        next
      end

      matching_topic = Topic.find(:first, :conditions => field_condition_sql_for("#{row[:legacy_id]}", 100)) # '100' here represents the ID of the extended field in the database...
      if matching_topic.nil?
        #$logger.warn "Could not find matching topic for legacy_identifier: #{row[:legacy_id]}"
        next
      end

      matching_location = locations[row[:shelf_location]] ||= repository.shelf_locations.find_by_code(row[:shelf_location])
      if matching_location.nil?
        matching_location = locations[row[:shelf_location]] = repository.shelf_locations.create(:code => row[:shelf_location])
        if matching_location.nil?
          #$logger.error "Error in creating shelf_location #{row[:shelf_location]}"
        end
      end

      # Create or update shelf location for topics
      if matching_topic.shelf_location_ids.present?
        ts = TrackableItemShelfLocation.find(:first, :conditions => ['trackable_item_id=?', matching_topic.id])
      else
        ts = TrackableItemShelfLocation.new :trackable_item => matching_topic
      end

      if ts.shelf_location == matching_location
        #$logger.debug "Shelf location for topic #{row[:legacy_id]} is already #{row[:shelf_location]}"
        next
      end

      ts.shelf_location = matching_location
      ts.save
    end
  end
end
