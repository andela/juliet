require "./resources"

class Greenhouse
  attr_reader :sheet

  def initialize
    #  Top sheet is to be used
    # @sheet = "1Jdvf9pvAu1VBALc1gyQV75nuu1CUst6C-LvMa-5EvwA"
    @sheet = "1FVfJAmWx_y29Jk1EnGQHB3glK33R8kaQ4ICZ53h9v6k"
  end

  def query_string
    [ "software developer", "frontend developer", "fullstack developer", "backend developer", "software engineer",
      "ruby", "rails", "python", "django", "java", "android", "iOS", "php", "laravel"
    ]
  end

  def unallowed_params
    "-senior -.NET -c# -Lead -5+ -Director -Manager -Sr -Ph.D -Master's"
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

jobs = Greenhouse.new
query = jobs.query_string
jobs.query_gsce_greenhouse(query)