require "./resources"
require "capybara/poltergeist"

class Greenhouse
  include Utility
  attr_reader :sheet, :browser

  def initialize
    @sheet = ENV["GH_SHEET_ID"]
    # @data_storage = DataStorage.new
    @browser = Capybara.current_session
  end

  def query_gsce_greenhouse(query_string)
    puts "Searching"
    listings = get_listing.flatten
    # @data_storage.save_data(listings)
    sheet_to_populate = PopulateSheet.new(sheet)
    sheet_to_populate.populate(listings)
  end

  def get_job_description(item)
    browser.visit item.link
    item["snippet"] = browser.find("#content").text if browser.has_css?("#content")
    item
  end

  def get_listing
    listing, prev_items = [], []
    1.upto(10) do | n |
      query_string.each do | query_param |
        page_listing = GoogleCustomSearchApi.search("#{query_param} #{unallowed_params}", page: n)
        items = page_listing.items
        if items.empty? && n == 1
          puts "No results found"
          exit
        elsif items.empty? || prev_items == items
          break
        end
        prev_items = items
        listing << items
      end
    end
    listing
  end
end
jobs = Greenhouse.new
query = jobs.query_string
jobs.query_gsce_greenhouse(query)
