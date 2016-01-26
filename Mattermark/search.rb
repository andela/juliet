require 'bundler'
Bundler.require(:default)

# Full Mattermark API documentation can be found at:
# http://mattermark.com/api/documentation/
API_KEY = "kapeTe6EsPeduruchUswAve4enUmeqaw"
# API_KEY = '0144712DD81BE0C3D9724F5E56CE6685'
# FILE_NAME = 'companies.txt'
FILE_NAME = 'companies_interest.txt'

class Company
  include HTTParty
  base_uri 'https://api.mattermark.com'

  def self.search(term)
    term = self.clean_term(term)
    options = { query: {} }
    options[:query][:key] = API_KEY
    options[:query][:term] = term
    options[:query][:object_types] = 'company'
    self.get("/search", options)
  end

  # Depending on the types of matches you are
  # or are not getting, you may want to scrub your
  # search terms.
  def self.clean_term(term)
    term = term.strip!
    # term = term.replace('&', '')
    # term = term.replace('[', '')
    # term = term.replace(']', '')
  end
end

module Matching
  def self.search_for_company_name(name)
    results = Company.search(name)
    if results.count > 0
      results.each do |result|
        # puts "Found matching domain: #{result['company_domain']}"
        result['company_domain']
      end
      puts "Search for #{name} [FOUND]"
      results.first['company_domain']
    else
      puts "Search for #{name} [NO MATCH]"
    end

  end
end

matched = []
unmatched = []
f = File.open(FILE_NAME, 'r:UTF-8')
f.each_line do |name|
puts name
  begin
    domain = Matching.search_for_company_name(name)
    if domain.nil?
      matched << "[NO MATCH] for #{name}"
    else
      puts domain
      matched << domain
    end
  rescue
    matched << "[NO MATCH] for #{name}"
  end
end

base_filename = 'results'
puts "Matching companies can be found in #{base_filename}-matches.txt"
File.open("#{base_filename}-matched.txt", 'w:UTF-8') { |file| file.write(matched.join("\n")) }

puts "Companies without matches can be found in #{base_filename}-unmatched.txt"
File.open("#{base_filename}-unmatched.txt", 'w:UTF-8') { |file| file.write(unmatched.join("\n")) }
