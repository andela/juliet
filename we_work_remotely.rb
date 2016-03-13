require "./resources"
class WeWorkRemotely
  SHEET = ENV["WWR_SHEET_ID"]
  attr_reader :url, :browser, :sheet_editor, :sheet
  include Utility
  def initialize(url = "placeholder")
    @url = url
    @browser = Capybara.current_session
    @sheet_editor = PopulateSheet.new(SHEET)
    @sheet = @sheet_editor.sheet
  end

  def lookup(link = url)
    browser.visit link
    grab_listings(browser.all(".jobs-container article ul li a").map { |i| i["href"] })
  end

  def inspect_listing_page(link)
    browser.visit link
    page_content = ""
    company_name = browser.find(".listing-header-container .company").text
    company_url = browser.find(".listing-header-container a")["href"]
    posting_date = browser.find(".listing-header-container h3").text.sub("Posted ","")
    posting_title = browser.find(".listing-header-container h1").text
    browser.find(".listing-container").all("div").each{|content| page_content += "#{content.text}\n" }
    source = "https://weworkremotely.com"
    info = { company_name: company_name, url: company_url, source: source, link: link,
             title: posting_title, date: posting_date, desc: page_content
           } if permitted?(page_content) && permitted?(posting_title)
    info.nil? ? {} : info
  rescue
    {}
  end

  def grab_listings(links)
    counter, listings = 1, []
    links.each do |link|
      info = inspect_listing_page(link)
      next if info.empty?
      listings << info.merge!(id: counter)
      counter += 1
    end
    save(listings)
  end

  def save(listings, row = 2)
    sheet_editor.sheet_headers(sheet, true) if sheet.num_rows == 0
    listings.each do |listing|
      next if sheet.cells.values.include? listing[:link]
      sheet_editor.fill_row_cells(listing, row)
      row += 1
    end
    if sheet.save
      puts "Data populated"
    else
      puts "Unable to populate data"
    end
  end

end
WeWorkRemotely.new("https://weworkremotely.com/categories/2-programming/jobs").lookup