require "json"
require "sinatra"
require "pry"
require "capybara/poltergeist"
require "google-search"
require "./searcher"
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
