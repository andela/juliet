require 'google-search'
require 'csv'


class GetInfo
  # FILENAME = 'accurate_needed.txt'
  # FILENAME = 'test_companies.txt'
  FILENAME = 'newest_accurate_needed.csv'
  # FILENAME = 'latest_accurate.csv'
  CSVDATAFILE = 'final.csv'
  LIKELY = 'likeit.csv'

  class << self
    def companies_to_be_searched
      @@companies_to_search ||= File.readlines(FILENAME).map(&:strip!)
    end

    def companies_to_be_searched
      @@companies_to_search ||= CSV.open(FILENAME, headers: true).map{ |company| company["Company"] }
    end

    def companies
      @@companies ||= []
    end

    def unpermitted_urls
      /crunchbase|linkedin|meetup|twitter|facebook/
    end


    def search
      companies_to_be_searched.each do |query|
        web_search = Google::Search::Web.new do |search|
          search.query = query
          search.size = :large
        end

        CSV.open(CSVDATAFILE, "a+") do |csv|
          CSV.open(LIKELY, "a+") do |likely|

          File.open('almost_match.txt', 'a+') do |_f|
            web_search.first(3).each do |item|
              likely << [item.uri, item.title] if item.index == 0 && !item.uri.match(unpermitted_urls)
              csv << [item.index, item.uri, item.title]
              _f.puts [item.index, item.uri, item.title].join(' | ')
            end
            _f.puts ""
          end
        end
        end
      end
    end
  end
end


GetInfo.search

# def to_csv
#   hashes = all_to_h
#   CSV.open(CSVDATAFILE, "w", headers: hashes.first.to_h.keys) do |csv|
#     hashes.each do |h|
#       csv << h.to_h.values
#     end
#   end
# end

# $:.unshift File.dirname(__FILE__) + '/../lib'
# # require 'rubygems'
# require 'google-search'
#
# def find_item uri, query
#   search = Google::Search::Web.new do |search|
#     search.query = query
#     search.size = :large
#     search.each_response { print '.'; $stdout.flush }
#   end
#   search.find { |item| item.uri =~ uri }
# end
#
# def rank_for query
#   print "%35s " % query
#   if item = find_item(/vision\-media\.ca/, query)
#     puts " #%d" % (item.index + 1)
#   else
#     puts " Not found"
#   end
# end
#
# rank_for 'Victoria Web Training'
# rank_for 'Victoria Web School'
# rank_for 'Victoria Web Design'
# rank_for 'Victoria Drupal'
# rank_for 'Victoria Drupal Development'
