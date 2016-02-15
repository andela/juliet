# Populates spreadsheet for greenhouse
class PopulateSheet
  attr_reader :sheet
  def initialize(listing_sheet)
    session = GoogleDrive.saved_session("auth.json")
    @sheet = session.spreadsheet_by_key(listing_sheet).worksheets[0]
  end

  def populate(listings)
    reload_sheet(sheet)
    listings_in_fifties(listings)
  end

  def save(listings, sheet, start_row = 2)
    sheet_headers(sheet) if sheet.rows.first.blank?
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
      inspector = PageInspector.new(listing.link)
      coy_and_link = inspector.listing_info unless inspector.listing_info.empty? || inspector.listing_info.nil?
      next if coy_and_link.nil?
      sheet[row, 1] = listing.cacheId
      sheet[row, 2] = listing.title.sub("Job Application for ","").split(" at").first
      sheet[row, 3] = coy_and_link[:company_name]
      sheet[row, 4] = coy_and_link[:link]
      sheet[row, 5] = listing.displayLink
      sheet[row, 6] = listing.snippet
      sheet[row, 7] = Date.today.strftime("%d-%m-%Y")
      row += 1
    end
    puts "Adding #{row - start_row} rows ..."
  end

  def listings_in_fifties(listings)
    puts "There are #{listings.count} listings"
    number_of_listings = listings.count
    start_index, end_index = 0, 49
    if number_of_listings > 50
      while start_index < number_of_listings
        start_row = start_index == 0 ? 2 : start_index + 1
        set = listings[start_index..end_index]
        remaining_listings = number_of_listings - ( end_index + 1 )
        end_index += remaining_listings <= 50 ? remaining_listings : 50
        start_index += 50
        save(set, sheet, start_row)
      end
    else
      set = listings[start_index..number_of_listings]
      save(set, sheet)
    end
  end

  # def write_to_csv(listing)
  #   fingerprint = Time.now.strftime("%m%d%Y")
  #   CSV.open("listings#{fingerprint}.csv", "a+") { |csv|  csv << lisitng }
  # end

  def sheet_headers(sheet)
    sheet[1, 1] = "Unique Id"
    sheet[1, 2] = "Listing Title"
    sheet[1, 3] = "Company Name"
    sheet[1, 4] = "Url"
    sheet[1, 5] = "Source"
    sheet[1, 6] = "Description"
    sheet[1, 7] = "Date of Search"
  end

  def reload_sheet(sheet)
    sheet.reload
  end
end