require "capybara/poltergeist"
require "nokogiri"
require "httparty"
require "pry"
require "httpclient"
require "active_support/core_ext/integer/time"
require "hashie"
require "forwardable"
require "./custom_google"
require "./sheets"
require "./date-ext"
require "./obj-ext"
require "./url-ext"
require "./listing-ext"
require "google/api_client"
require "google_custom_search_api"
require "google_drive"
require "./populate_sheet"
require "./keys"

Capybara.register_driver :poltergeist do | app |
    Capybara::Poltergeist::Driver.new(app, js_errors: false)
  end
Capybara.default_driver = :poltergeist