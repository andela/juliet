# require "#{Rails.root}/lib/helpers/resources"

class Company
  include Utility

  def initialize(sheet)
    @sheet = sheet
    BingSearch.account_key = ENV["bing_api_key"]
  end

  def look_up_coy_url(company_name)
    begin
      url = BingSearch.web("#{company_name} #{youtube_exclusion}")[0].url
    rescue
      puts "Seems there's no url for this listing"
      url = ''
    end
    url
  end

  # This function is just to get company URLs for
  # companies already on the spreadsheet before adding
  # URL lookup to the listings search
  def add_company_url
    (2..@sheet.num_rows).each do |row|
      @sheet[row, 10] = look_up_google(@sheet[row, 3])
    end
    puts "companies added" if @sheet.save
  end
end
