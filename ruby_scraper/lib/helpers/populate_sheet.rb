# require "#{Rails.root}/lib/helpers/resources"

class PopulateSheet
  include Utility
  attr_accessor :sheet, :exclusion_list, :query
  def initialize(listing_sheet, query)
    session = GoogleDrive.saved_session("auth.json")
    @sheet = session.spreadsheet_by_key(listing_sheet).worksheets[0]
    # @exclusion_list = session.spreadsheet_by_key(listing_sheet).worksheets[3]
    @company = Company.new(@sheet)
    @query = query
    @latest = 0
    Geocoder.configure(:timeout => 5)
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

  def country_lookup(location)
    location = location.to_s
    if (location.length > 1)
      begin
        Geocoder.search(location).first.country if Geocoder.search(location).first != nil
      rescue
        retry 
      end
    else
      false
    end
  end

  def fill_rows(listings, sheet, row)
    start_row = row
    listings.each do | listing |
      next if sheet.cells.values.include? listing.cacheId # skip if listing already exists
      inspector = PageInspector.new(listing.link)
      coy_info = inspector.listing_info
      # next unless (["United States", "United Kingdom", "Canada"]).include? country_lookup(coy_info[:location])
      next if (sheet.cells.values.include? listing.cacheId) # || (sheet.cells.values.include? coy_info[:company_name])
      if listing.link.include? "greenhouse"
        posting_source = 'greenhouse'
      elsif listing.link.include? "lever"
        posting_source = 'lever'
      elsif listing.link.include? "workable"
        posting_source = 'workable'
      elsif listing.link.include? "jobvite"
        posting_source = 'jobvite'
      elsif listing.link.include? "smartrecruiters"
        posting_source = 'smartrecruiters'
      end

      

      next if (coy_info.values.include? nil) || (coy_info.empty?) #|| (!permitted?(title)) # skip if the job description or title is in the exclusion list
      coy_url = @company.look_up_coy_url("#{coy_info[:company_name]} #{coy_info[:location]}")
      country = country_lookup(coy_info[:location]) || ''
      coy_info.merge!(id: listing.cacheId, url: coy_url, location: country, posting_source: posting_source, posting_url: listing.link)
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
    sheet[row, 4] = coy_info[:location]
    sheet[row, 5] = coy_info[:url]
    sheet[row, 6] = coy_info[:posting_url]
    sheet[row, 7] = coy_info[:description]
    sheet[row, 8] = coy_info[:requirements]
    sheet[row, 9] = coy_info[:responsibilities]
    sheet[row, 10] = Date.today.strftime("%d-%m-%Y")
    sheet[row, 11] = coy_info[:posting_source]
    sheet[row, 12] = query
    sheet[row, 13] = coy_info[:date] if coy_info[:date]
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
    sheet[1, 4] = "Location"
    sheet[1, 5] = "Company Url"
    sheet[1, 6] = "Scraping URL"
    sheet[1, 7] = "Job description"
    sheet[1, 8] = "Job requirements"
    sheet[1, 9] = "Job responsibilities"
    sheet[1, 10] = "Date scraped"
    sheet[1, 11] = "Source"
    sheet[1, 12] = "Bucket"
    sheet[1, 13] = "Date Posted" if posted_on
    sheet.save
  end

  def reload_sheet(sheet)
    sheet.reload
  end
end
