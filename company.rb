require "resources"
class Company
  def initialize(company_name, sheet)
    @company_name = company_name
    @sheet = sheet
  end

  def check_spreadsheet
    if sheet.cells.values.include? @company_name
    end
  end

  def look_up_google
    https://www.google.com/
  end
end