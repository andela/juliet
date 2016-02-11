require "./resources"

class Greenhouse
  attr_reader :sheet

  def initialize
    @sheet = "1Jdvf9pvAu1VBALc1gyQV75nuu1CUst6C-LvMa-5EvwA"
  end

  def query_gsce_greenhouse(query_string)
    listings = []
    puts "Searching"
    1.upto(10) do | n |
      listings_per_page = GoogleCustomSearchApi.search(query_string, page: 1)
      listings << listings_per_page.items
    end
    puts "Found result matching your search" unless listings.empty?
    sheet_to_populate = PopulateSheet.new(sheet)
    sheet_to_populate.populate(listings.flatten)
  end

  def query_string
    "software developer frontend fullstack backend engineer -senior"
  end
end

jobs = Greenhouse.new
query = jobs.query_string
jobs.query_gsce_greenhouse(query)