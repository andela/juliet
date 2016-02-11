require "./resources"

class Greenhouse
  attr_reader :sheet

  def initialize
    # @sheet = "1Jdvf9pvAu1VBALc1gyQV75nuu1CUst6C-LvMa-5EvwA"
    @sheet = "1z1UX3KuFofy9jBba1bUB756yZviEiqTVCZh0FApC1iE"
  end

  def query_string
    "software developer frontend fullstack backend engineer -senior -.NET -c# -"
  end

  def query_gsce_greenhouse(query_string)
    puts "Searching"
    listings = get_listing.flatten
    puts "Found result matching your search"
    sheet_to_populate = PopulateSheet.new(sheet)
    sheet_to_populate.populate(listings)
  end

  def get_listing
    listing = []
    1.upto(10) do | n |
      page_listing = GoogleCustomSearchApi.search(query_string, page: n)
      items = page_listing.items
      if items.empty? && n == 1
        puts "No results found"
        exit
      elsif items.empty?
        break
      end
      listing << items
    end
    listing
  end
end

jobs = Greenhouse.new
query = jobs.query_string
jobs.query_gsce_greenhouse(query)