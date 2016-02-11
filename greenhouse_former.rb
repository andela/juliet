require "./resources"
require "net/http"
require "uri"

# GoogleCustomSearchApi::GOOGLE_API_KEY = "AIzaSyDDzhd7lRDnhjPOVyxSNmVXF2654G451pE"
# GoogleCustomSearchApi::GOOGLE_SEARCH_CX =  "016010277763527429812:tqprubgay5k"

def query_gsce_greenhouse(query_string)
  browser = Capybara.current_session
  url = "https://cse.google.com/cse/publicurl?cx=016010277763527429812:tqprubgay5k"
  browser.visit url
  browser.fill_in "gsc-i-id1", with: query_string
  browser.click_on "search"
  browser.current_url
  sleep 3
  browser.save_and_open_page
end

def query_string
  "software developer frontend fullstack backend engineer -senior"
end

query_gsce_greenhouse(query_string)