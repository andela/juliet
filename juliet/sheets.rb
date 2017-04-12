require 'google/api_client'
require 'google_drive'
require './obj-ext'


class GSheet
  attr_accessor :sheet
  attr_reader :all_data

  def initialize(sheet)
    @all_data = []
    @sheet = sheet
  end

  def worksheets
    ws = self.class.session.spreadsheet_by_key(sheet)
    ws.worksheets if ws
  end

  def self.session
    @@session ||= GoogleDrive.saved_session("auth.json")
  end

  def save(sheet_tab, data, start_row: 2, start_col: 1, sheet: nil)
    sheet = sheet.try(:worksheets) || worksheets
    sheet_to_use = sheet[sheet_tab]
    row = start_row
    data.each{ |d| #url, title, company, date
      col = start_col
      save_string(d, sheet_to_use, row, col) if d.is_a? String
      save_enum(d, sheet_to_use, row, col) if d.is_a? Enumerable
      row += 1
    }
    sheet_to_use.save
  end

  def save_string(data, sheet, row, col)
    sheet[row, col] = data
  end

  def save_enum(data, sheet, row, col)
    data.each do |key, value|
      if data.is_a? Hash
        sheet[row, col] = value
      elsif data.is_a? Array
        sheet[row, col] = key
      end
      col += 1
    end
  end

  def get_data_from_column(sheet_tab, start_row: 1, col: 1)
    sheet_to_use = worksheets[sheet_tab]
    row = start_row
    start_row = start_row.to_i
    start_row.upto(sheet_to_use.num_rows) do |row|
      data = sheet_to_use[row, col]
      yield data if block_given?
      @all_data << data
    end
  end

end


# get_data_from_column(1) do |data, sheet|
#   # sheet[] = data
#   data_found = search(data)#.map{ |d| { url: d.uri }}
#   sheet[] = data_found.first.uri
# end
# data = {url: search.url}#[search.url]
# save(1, data,start_row: 1, start_col: 1)


  # begin
  #   data = sheet_to_use[row, start_col]
  #   data_unavailable = data.blank?
  #   # search(data) unless data_available
  #   @all_data << data unless data_unavailable
  #   row += 1
  # end until(data_unavailable)

  # def search data
  #   @data << data
  # end
