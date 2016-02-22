# Populates spreadsheet for greenhouse
require "./resources"
class PopulateSheet
  attr_accessor :sheet
  def initialize(listing_sheet)
    session = GoogleDrive.saved_session("auth.json")
    @sheet = session.spreadsheet_by_key(listing_sheet).worksheets[0]
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
      coy_and_link = inspector.listing_info
      next if coy_and_link.empty?
      sheet[row, 1] = listing.cacheId
      sheet[row, 2] = listing.title.sub("Job Application for ","").split(" at").first
      sheet[row, 3] = coy_and_link[:company_name]
      sheet[row, 4] = coy_and_link[:link]
      sheet[row, 5] = listing.displayLink
      sheet[row, 6] = listing.snippet
      sheet[row, 7] = coy_and_link[:duties]
      sheet[row, 8] = coy_and_link[:requirement]
      sheet[row, 9] = Date.today.strftime("%d-%m-%Y")
      row += 1
    end
    @latest += row - start_row
    puts "Adding #{row - start_row} row(s) ..."
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

  def sheet_headers(sheet)
    sheet[1, 1] = "Unique Id"
    sheet[1, 2] = "Listing Title"
    sheet[1, 3] = "Company Name"
    sheet[1, 4] = "Url"
    sheet[1, 5] = "Source"
    sheet[1, 6] = "Description"
    sheet[1, 7] = "Applicant's Duties"
    sheet[1, 8] = "Preferred Candidate"
    sheet[1, 9] = "Date of Search"
    sheet.save
  end

  def reload_sheet(sheet)
    sheet.reload
  end
end
