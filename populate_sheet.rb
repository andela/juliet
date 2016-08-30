require "./resources"
class PopulateSheet
  include Utility
  attr_accessor :sheet, :exclusion_list
  def initialize(listing_sheet)
    session = GoogleDrive.saved_session("auth.json")
    @sheet = session.spreadsheet_by_key(listing_sheet).worksheets[0]
    # @exclusion_list = session.spreadsheet_by_key(listing_sheet).worksheets[3]
    @company = Company.new(@sheet)
    @latest = 0
  end

  def populate(listings)
    reload_sheet(sheet)
    listings_in_fifties(listings)
  end

  def save(listings, sheet, start_row = 2)
    sheet_headers(sheet) if sheet.num_rows == 0
    fill_rows(listings, sheet, start_row)
    if sheet.save
      puts "Data populated"
    else
      puts "Unable to populate data"
    end
  end

  def fill_rows(listings, sheet, row)
    start_row = row
    listings.each do | listing |
      next if sheet.cells.values.include? listing.cacheId
      inspector = PageInspector.new(listing.link)
      coy_info = inspector.listing_info
      title = listing.title.sub("Job Application for ","").split(" at").first
      next if (coy_info.values.include? nil) || (coy_info.empty?) || (!permitted?(title))
      coy_url = @company.look_up_coy_url("#{coy_info[:company_name]} #{coy_info[:location]}")
      coy_info.merge!(id: listing.cacheId, title: title, source: listing.displayLink, desc: listing.snippet, url: coy_url)
      fill_row_cells(coy_info, row)
      row += 1
    end
    @latest += row - start_row
    puts "Adding #{row - start_row} row(s) ..."
  end

  def fill_row_cells(coy_info, row)
    sheet[row, 1] = coy_info[:id]
    sheet[row, 2] = coy_info[:title]
    sheet[row, 3] = coy_info[:company_name]
    sheet[row, 4] = coy_info[:url]
    sheet[row, 5] = Date.today.strftime("%d-%m-%Y")
    sheet[row, 6] = coy_info[:desc]
    sheet[row, 7] = coy_info[:duties]
    sheet[row, 8] = coy_info[:date] if coy_info[:date]
  end

  def listings_in_fifties(listings)
    number_of_listings = listings.count
    puts "Found #{number_of_listings} listings"
    start_index, end_index = 0, 49
    if number_of_listings > 50
      batch_listing(listings, number_of_listings, start_index, end_index)
    else
      set = listings[start_index..number_of_listings]
      save(set, sheet, sheet.num_rows + 1)
    end
    puts "Search completed. A total of #{@latest} listings were added."
  end

  def batch_listing(listings, number_of_listings, start_index, end_index)
    while start_index < number_of_listings
      start_row = sheet.num_rows + 1
      set = listings[start_index..end_index]
      remaining_listings = number_of_listings - ( end_index + 1 )
      end_index += remaining_listings <= 50 ? remaining_listings : 50
      start_index += 50
      save(set, sheet, start_row)
    end
  end

  def sheet_headers(sheet, posted_on = false)
    sheet[1, 1] = "Listing Id"
    sheet[1, 2] = "Listing Title"
    sheet[1, 3] = "Company Name"
    sheet[1, 4] = "Company Url"
    sheet[1, 5] = "Date scraped"
    sheet[1, 6] = "Description snippet"
    sheet[1, 7] = "Description full"
    sheet[1, 8] = "Date Posted" if posted_on
    sheet.save
  end

  def reload_sheet(sheet)
    sheet.reload
  end
end
