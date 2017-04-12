require 'google-search'
require 'google/api_client'
require 'google_drive'
require './string-ext'
require './google-search-ext'

# May not be in use

class GetInfo
  attr_reader :sheet
  def initialize(sheet)
    @sheet = sheet
  end

  def worksheets
    ws = self.class.session.spreadsheet_by_key(sheet)
    ws.worksheets if ws
  end

  # perform_search
  # accepts the following params
  # 0 based tab to search[0, 1, 2, 3] etc
  # start_row: row to start search, first row may be the header
  # col_for_data: column where the company to search is gotten [1, 2, 3, 4] etc
  # first_col_for_url: first column where the url would be entered, near matches would be entered in the subsequent columns
  def perform_search(sheet_tab, start_row: 1, col_for_data: 1, first_col_for_url: 2, result_needed: 3)
    sheet_to_use = worksheets[sheet_tab]
    (start_row..sheet_to_use.num_rows).each do |row|
      company = sheet_to_use[row, col_for_data].downcase
      company = company.split(',').first if company.match(self.class.corporation_type)
      company = company.downcase.gsub(/[^[:word:]\s]/, '')

      results = self.class.search(company, result_needed: result_needed)
      next_col_for_url = first_col_for_url

      results = second_sort results, company
      results.each_with_index do |result, index|
        # c = index + first_col_for_url - 1

        col_for_url = index + next_col_for_url
        col_for_title = col_for_url + 1
        url = result.uri
        title = result.title
        unless url.match(self.class.unpermitted_urls)
          # matcher = company.is_a? String ? company : company.first
          # if title.match(matcher)
          sheet_to_use[row, col_for_url] = url
          # if index == 0
            sheet_to_use[row, col_for_title] = title
            next_col_for_url += 1
          # end
        end
      end
    end
    sheet_to_use.save
  end

  def second_sort(results, company)
    results.sort_by{|result| result.match_value(company)}.reverse
  end


  class << self
    attr_accessor :session

    def session
      @@session ||= GoogleDrive.saved_session("auth.json")
    end

    def unpermitted_urls
      # /crunchbase|linkedin|meetup|twitter|facebook|wikipedia|yahoo|github/
      unpermit = unpermitted.join('|')
      Regexp.new unpermit
    end

    def unpermitted
      %w{ crunchbase linkedin meetup twitter facebook wikipedia yahoo github angel }
    end

    def corporation_type
      /llc|inc|ltd|plc/
    end

    def save

    end

    def search(company, result_needed: 3)
      web_search = Google::Search::Web.new do |search|
        # exclude_list = unpermitted.map{ |exclude| "-#{exclude}" }.join(' ')
        search.query = "#{company}"
        # search.query = "#{company} #{exclude_list}"
        # puts search.query
        search.size = :large
      end
      web_search = web_search.select{ |result| !unpermitted_urls.match(result.uri) }
      # require 'pry' ; binding.pry
      result = web_search.sort do |c1, c2|
        # puts c1.uri.ld(company), c2.uri.ld(company), ''
        [c1.uri.ld(company), c1.index ] <=> [c2.uri.ld(company), c2.index ]
      end
      result = result.first(result_needed.to_i) unless result_needed == :all
      result
    end
  end
end
