# require "#{Rails.root}/lib/helpers/resources"

class Company
  include Utility

  attr_reader :company_name, :agent, :page
  VALID_URI = /:https*:\/\/([\w.\/]+)(?=%)/
  
  def initialize(sheet)
    @sheet = sheet
    @agent = Mechanize.new
    url = URI.parse(URI.encode(ENV["google_web_search_url"]))
    @page = agent.get(url)
    @company_name = ''
  end

  def look_up_coy_url(company)
    @company_name = company
    search_coy_type
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

  def search_coy_type
    return look_up_aggregator if permitted?(company_name).nil?
    look_up_coy
  end

  def make_search
    google_form = page.form("f")
    google_form.q = company_name
    cur_page = agent.submit(google_form)
    cur_page.links.map(&:href).map do |n|
      n.match(VALID_URI)[1] if n.match(VALID_URI)
    end.compact unless cur_page.nil?
  end

  def look_up_coy
    make_search.detect{ |n| !permitted?(n[0]).nil? }.try(:chop)
  end

  def look_up_aggregator
    make_search.first.try(:chop)
  end

  def permitted?(uri)
    uri if uri.downcase.match(data_aggregators.join("|").downcase).nil?
  end

  def data_aggregators
    ["linkedin", "twitter", "crunchbase", "itunes.apple", "google", "yahoo",
     "facebook", "bing", "wikipedia", "github", "techcrunch", "wordpress",
     "greenhouse", "amazon", "youtube", "oreilly", "angel.co", "entrepreneur",
     "reddit", "imdb", "indiegogo", "about", "tech.co"]
  end
end
