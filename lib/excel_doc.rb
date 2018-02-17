require "rubyXL"

class ExcelDoc
  def initialize(path)
    @path = path
  end

  def write(data)
    @workbook = RubyXL::Workbook.new
    @worksheet = @workbook.worksheets[0]
    @headers = data.first.keys
    col_count = 0
    @headers.each do |head|
      @worksheet.add_cell(0, col_count, head.to_s)
      col_count += 1
    end

    row_count = 1 #Headings were inserted at row 0, so start the count for data at row 1

    data.each do |row|
      col_count = 0 # reset column count for each row
      @headers.each do |head|
        @worksheet.add_cell(row_count, col_count, row[head])
        col_count += 1
      end
      row_count += 1
    end

    @workbook.write(@path)
  end

  def read(row_class = ExcelRow)
    unless @data.present?
      @workbook  = RubyXL::Parser.parse(@path)
      @worksheet = @workbook.worksheets[0]
      @headers   = @worksheet[0].map { |i| i.value.underscore.to_sym }
      @data      = @worksheet.each_with_index.map do |row, row_number|
        row_class.new row, row_number, headers
      end
      @data.shift # shift out heading line
    end

    @data
  end

  attr_reader :workbook, :worksheet, :headers
end

class ExcelRow < Hash
  def initialize(row, row_number, headers)
    row.each_with_index do |item, index2|
      self[headers[index2]] = item.value
    end
    @row_number = row_number
  end

  attr_reader :row_number
end
