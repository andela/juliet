require "./resources"

class Company
  def initialize(sheet)
    @sheet = sheet
  end

  def look_up_coy_url(company_name)
    Google::Search::Web.new(query: company_name).all[0..2].map{ |result| result.visible_uri }.join(" OR ")
  end

  # This function is just to get company URLs for
  # companies already on the spreadsheet before add URL
  # lookup to the listings search

  def add_company_url
    (2..@sheet.num_rows).each do |row|
      @sheet[row, 10] = look_up_google(@sheet[row, 3])
    end
    puts "companies added" if @sheet.save
  end
end
