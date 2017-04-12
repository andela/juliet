require "./resources"

class Greenhouse
  include Utility
  attr_reader :sheet

  def initialize
    @sheet = ENV["GH_SHEET_ID"]
  end

  def query_gsce_greenhouse(query_string)
    puts "Searching"
    listings = get_listing.flatten
    sheet_to_populate = PopulateSheet.new(sheet)
    sheet_to_populate.populate(listings)
  end

  def get_listing
    listing, prev_items = [], []
    # (0..50).to_a.shuffle.take(x)
    1.upto(100) do | n |
      # query_string.each do | query_param |
      #   page_listing = GoogleCustomSearchApi.search("#{query_param}", start: n)
      #   items = page_listing.items
      #   if items.empty? && n == 1
      #     puts "No results found"
      #     exit
      #   elsif items.empty? || prev_items == items
      #     break
      #   end
      #   prev_items = items
      #   listing << items
      # end
      page_listing = GoogleCustomSearchApi.search("#{query_string}", start: n)
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
jobs = Greenhouse.new
query = jobs.query_string
jobs.query_gsce_greenhouse(query)
