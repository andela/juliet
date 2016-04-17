require "json"
require "sinatra"
require "pry"
require "google_drive"
require "capybara/poltergeist"
require "google-search"
require "./searcher"
require "./fetcher"
require "./matcher"
require "sinatra/cross_origin"

configure do
  enable :cross_origin
end


Capybara.register_driver :poltergeist do | app |
    Capybara::Poltergeist::Driver.new(app, js_errors: false)
  end
Capybara.default_driver = :poltergeist
Capybara.ignore_hidden_elements = false

# Could be commented out just for my local env setting.
set :port, 8080

Fetcher.new(sheet1, sheet2).make_search
