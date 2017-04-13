require "#{Rails.root}/lib/helpers/utility"


class Scraper
  include Utility
  attr_reader :sheet, :query

  def initialize(query)
    @sheet = ENV["sheet_id"]
    @query = query
  end

  def query_gs
    puts "Searching for #{query}"
    listings = get_listing.flatten
    sheet_to_populate = PopulateSheet.new(sheet, query)
    sheet_to_populate.populate(listings)
  end

  def get_listing
    listing, prev_items = [], []
    # (0..50).to_a.shuffle.take(x)
    1.upto(1) do | n |
      page_listing = GoogleCustomSearchApi.search("#{query}", start: n)
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
    listing
  end
end

