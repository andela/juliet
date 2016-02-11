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
    row = start_row
    listings.each do | listing |
      sheet[row, 1] = listing.cacheId
      sheet[row, 2] = listing.title
      sheet[row, 3] = listing.link
      sheet[row, 4] = listing.displayLink
      sheet[row, 5] = listing.snippet
      sheet[row, 6] = Date.today.strftime("%d-%m-%Y")
      row += 1
    end
    if sheet.save
      puts "Data populated"
    else
      puts "Unable to populate data"
    end
  end

  def sheet_headers(sheet)
    sheet[1, 1] = "Unique Id"
    sheet[1, 2] = "Listing Title"
    sheet[1, 3] = "Url"
    sheet[1, 4] = "Source"
    sheet[1, 5] = "Description"
    sheet[1, 6] = "Date of Search"
  end

  def reload_sheet(sheet)
    sheet.reload
  end
end