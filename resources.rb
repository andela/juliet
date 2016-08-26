require "capybara/poltergeist"
require "pry"
require "google-search"
require "google/apis/drive_v2"
require "google_custom_search_api"
require "google_drive"
require "whenever"
require "duckduckgo"
require "bing-search"
require "./utility"
require "./page_inspector"
require "./populate_sheet"
require "./keys"
require "./company"

Capybara.register_driver :poltergeist do | app |
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end
Capybara.default_driver = :poltergeist
Capybara.ignore_hidden_elements = false
