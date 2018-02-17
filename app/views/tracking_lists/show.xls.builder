xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
xml.Workbook({
  'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet", 
  'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
  'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",    
  'xmlns:html' => "http://www.w3.org/TR/REC-html40",
  'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet" 
  }) do

  xml.Worksheet 'ss:Name' => t('.tracking_list') do
    xml.Table do
      # Rows
      for tracked_item_trackable_item_pair in @tracked_item_trackable_item_pairs
        item = tracked_item_trackable_item_pair[1]
        xml.Row do
          xml.Cell { xml.Data item.series_no, 'ss:Type' => 'String' }
          xml.Cell { xml.Data item.box_no, 'ss:Type' => 'String' }
          xml.Cell { xml.Data item.item_no, 'ss:Type' => 'String' }
          xml.Cell { xml.Data item.title, 'ss:Type' => 'String' }
          xml.Cell { xml.Data item.current_state_humanized, 'ss:Type' => 'String' }
    if item.shelf_locations.any?
      xml.Cell { xml.Data item.shelf_locations.first.code, 'ss:Type' => 'String' }
    else
      xml.Cell { xml.Data '', 'ss:Type' => 'String' }
    end	    
        end
      end
    end
  end
end
