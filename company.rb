require "./resources"

class Company
  def initialize(sheet)
    @sheet = sheet
    BingSearch.account_key = "CIQ1Ne+untlnZdyUM5lkqive6UmB6Tk03XRcin4xtkw"
  end

  def look_up_coy_url(company_name)
    BingSearch.web(company_name)[0..1].map{ |result| result.url }.join(" OR ")
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
