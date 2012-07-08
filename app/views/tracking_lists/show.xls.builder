xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
xml.Workbook({
  'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet", 
  'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
  'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",    
  'xmlns:html' => "http://www.w3.org/TR/REC-html40",
  'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet" 
  }) do

  xml.Worksheet 'ss:Name' => t('.tracked_items') do
    xml.Table do
      # Tracked List Header
      xml.Row do
        xml.Cell { xml.Data 'List ID', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Repository', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Current State', 'ss:Type' => 'String' }
      end

      # Tracked List Data
      xml.Row do
        xml.Cell { xml.Data @tracking_list.id, 'ss:Type' => 'String' }
        xml.Cell { xml.Data @tracking_list.repository.name, 'ss:Type' => 'String' }
        xml.Cell { xml.Data @tracking_list.current_state_humanized, 'ss:Type' => 'String' }
      end

      # Tracked Items Header
      xml.Row do
        xml.Cell { xml.Data 'Series No', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Box No', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Item No', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Shelf Code', 'ss:Type' => 'String' }
        xml.Cell { xml.Data 'Description', 'ss:Type' => 'String' }
      end

      # Rows
      for tracked_item in @tracking_list.tracked_items
      	topic = Topic.find(tracked_item.trackable_item.id)
        xml.Row do
          xml.Cell { xml.Data topic.series_no, 'ss:Type' => 'String' }
          xml.Cell { xml.Data topic.box_no, 'ss:Type' => 'String' }
          xml.Cell { xml.Data topic.item_no, 'ss:Type' => 'String' }
	  if topic.shelf_locations.any?
	    xml.Cell { xml.Data topic.shelf_locations.first.code, 'ss:Type' => 'String' }
	  else
	    xml.Cell { xml.Data '', 'ss:Type' => 'String' }
	  end	    
          xml.Cell { xml.Data topic.title, 'ss:Type' => 'String' }
        end
      end
    end
  end
end
