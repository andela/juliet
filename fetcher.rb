require "pry"
require "keys"
require "google_drive"
require "./searcher"

class Fetcher
  attr_reader :name_sheet, :num_of_coy, :initial_num_urls
  attr_accessor :url_sheet, :latest, :insertion_row, :rows

  def initialize(url_sheet, name_sheet)
    session = GoogleDrive.saved_session("config.json")
    @url_sheet = session.spreadsheet_by_key(url_sheet).worksheets[0] # +1
    @name_sheet = session.spreadsheet_by_key(name_sheet).worksheets[0]
    @initial_num_urls = @url_sheet.num_rows
    @num_of_coy = @name_sheet.num_rows
    @latest = 0
    @total_time = 0
  end

  def make_search
    batch_in_fifties(name_sheet, num_of_coy)
    puts "Completed. Total of #{insertion_row -  initial_num_urls - 1} url(s) added in #{@total_time} minutes"
  end

  def batch_in_fifties(name_sheet, num_of_coy)
    start_index, end_index = 2, 501
    if num_of_coy > 500
      batch_coy_names(name_sheet, num_of_coy, start_index, end_index, initial_num_urls)
    else
      get_url(name_sheet, 2, num_of_coy, @insertion_row = (@url_sheet.num_rows + 1))
      save(url_sheet, insertion_row, @url_sheet.num_rows)
    end
  end

  def batch_coy_names(name_sheet, num_of_coy, start_index, end_index, initial_num_urls)
    @insertion_row = initial_num_urls + 1
    while start_index < (num_of_coy + 1)
      @start_time = Time.now
      get_url(name_sheet, start_index, end_index, insertion_row)
      save(url_sheet, insertion_row, rows)
      remaining_coys = num_of_coy - end_index
      end_index += remaining_coys <= 500 ? remaining_coys : 500
      start_index += 500
    end
  end

  def get_url(name_sheet, start_index, end_index, insertion_row)
    @rows = @url_sheet.num_rows
    (start_index..end_index).each do |row|
      company_name = name_sheet[row, 0] # +1
      next if invalid(company_name)
      url = Searcher.new(company_name).search_coy_type
      next if url.nil?
      url.sub!(/\/\z/,"") unless url.sub!(/[\w]*:?(\/\/)?(www.)/,"").nil?
      url_sheet[insertion_row, 1], url_sheet[insertion_row, 2] = company_name, url
      insertion_row += 1
    end
    @insertion_row = insertion_row
  end

  def save(url_sheet, insertion_row, initial_num_urls)
    if url_sheet.save
      time_taken = (Time.now - @start_time) / 60
      @total_time += time_taken
      puts "#{insertion_row - initial_num_urls - 1} url(s) added in #{ time_taken } minute(s)"
    else
      puts "No row was added to the url sheet."
    end
  end

  def invalid(name)
    (url_sheet.cells.values.include? name) || (name.nil?) || !name.match(/[A-z]{3,}/)
  end
end

Fetcher.new(sheet1, sheet2).make_search
