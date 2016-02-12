# Populates spreadsheet for greenhouse
class PopulateSheet
  attr_reader :sheet
  def initialize(listing_sheet)
    session = GoogleDrive.saved_session("auth.json")
    @sheet = session.spreadsheet_by_key(listing_sheet).worksheets[0]
  end

  def populate(listings)
    reload_sheet(sheet)
    save(listings, sheet)
  end

  def save(listings, sheet, start_row = 2, start_col = 1)
    sheet_headers(sheet) if sheet.rows.first.blank?
    fill_rows(listings, sheet, start_row)
    if sheet.save
      puts "Data populated"
    else
      puts "Unable to populate data"
    end
  end

  def fill_rows(listings, sheet, row)
    puts "There are #{listings.count} listings"
    listings.each do | listing |
      inspector = PageInspector.new(listing.link)
      coy_and_link = inspector.listing_info unless inspector.listing_info.empty? || inspector.listing_info.nil?
      next if inspector.listing_info.empty? || inspector.listing_info.nil?
      sheet[row, 1] = listing.cacheId
      sheet[row, 2] = listing.title.sub("Job Application for ","")
      sheet[row, 3] = coy_and_link[:company_name]
      sheet[row, 4] = coy_and_link[:link]
      sheet[row, 5] = listing.displayLink
      sheet[row, 6] = listing.snippet
      sheet[row, 7] = Date.today.strftime("%d-%m-%Y")
      write_to_csv([listing.cacheId, listing.title.sub("Job Application for ",""), coy_and_link[:company_name], coy_and_link[:link], listing.displayLink, listing.snippet, Date.today.strftime("%d-%m-%Y") ])
      row += 1
    end
    puts "Total rows: #{row}"
  end

  def write_to_csv(listing)
    fingerprint = Time.now.strftime("%-m-%d-%Y")
    CSV.open("listings#{fingerprint}.csv", "a+") { |csv|  csv << lisitng }
  end

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