require "./resources"

class Greenhouse
  include Utility
  attr_reader :sheet

  def initialize
    @sheet = "1FVfJAmWx_y29Jk1EnGQHB3glK33R8kaQ4ICZ53h9v6k"
  end

  def query_gsce_greenhouse(query_string)
    puts "Searching"
    listings = get_listing.flatten
    sheet_to_populate = PopulateSheet.new(sheet)
    sheet_to_populate.populate(listings)
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