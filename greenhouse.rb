require "./resources"
require "mechanize"
require "uri"

def query_gsce_greenhouse(query_string)
  agent = Mechanize.new
   binding.pry
  agent.get(URI("https://cse.google.com/cse/publicurl?cx=016010277763527429812:tqprubgay5k"))

  listings = page.form_with(class: "gsc-search-box gsc-search-box-tools") do | field |
    field.search = query_string
  end.submit
  binding.pry
end

def query_string
  "software developer frontend fullstack -senior"
end

query_gsce_greenhouse(query_string)