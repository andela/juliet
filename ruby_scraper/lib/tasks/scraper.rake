require "#{Rails.root}/lib/helpers/scraper"
require "#{Rails.root}/lib/helpers/utility"
require "#{Rails.root}/lib/helpers/page_inspector"
require "#{Rails.root}/lib/helpers/populate_sheet"
require "#{Rails.root}/lib/helpers/company"

Capybara.register_driver :poltergeist do | app |
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end
Capybara.default_driver = :poltergeist
Capybara.ignore_hidden_elements = false



namespace :scraper do
  desc "Scrape job listings"
  task jobs: :environment do
    query_terms = ["Front-end Developer", "Back-end Developer", "Mobile Developer", "Mid-Level Developer", "Senior Developer", "Technical Product Manager", "DevOps Engineer", "QA/Test Engineer", "Engineering Manager", "VP Engineering"]
    query_terms.each do |term|
      scraper = Scraper.new(term)
      scraper.query_gs
    end
  end
end
