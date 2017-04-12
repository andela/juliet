require 'google-search'
require 'google/api_client'
require 'google_drive'


class String

  # levenshtein_distance
  def ld str
    s = self
    t = str
    n = s.length
    m = t.length

    return m if (0 == n)
    return n if (0 == m)

    d = (0..m).to_a
    x = nil

    s.each_char.each_with_index do |char1,i|
      e = i+1

      t.each_char.each_with_index do |char2,j|
        cost = (char1 == char2) ? 0 : 1
        x = min3(
             d[j+1] + 1, # insertion
             e + 1,      # deletion
             d[j] + cost # substitution
            )
        d[j] = e
        e = x
      end

      d[m] = x
    end

    return x
  end


  def min3 a, b, c # :nodoc:
    if a < b && a < c then
      a
    elsif b < c then
      b
    else
      c
    end
  end

end


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

  def second_sort(result, company)
    x = result.to_a
    result.to_a.each_with_index{ |comp, index|
      unless comp.title.downcase.match(company.downcase)
        swap(x, index, index + 1) unless x[index + 1] == nil
      end
    }
    x
  end

  def swap(arr, index, with_index)
    old_elem = arr[index]
    arr[index] = arr[with_index]
    arr[with_index] = old_elem
    arr
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
      %w{ crunchbase linkedin meetup twitter facebook wikipedia yahoo github }
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
      result = web_search.sort do |c1, c2|
        # puts c1.uri.ld(company), c2.uri.ld(company), ''
        [c1.uri.ld(company), c1.index ] <=> [c2.uri.ld(company), c2.index ]
      end
      result = result.first(result_needed.to_i) unless result_needed == :all
      result
    end
  end
end

def GetInfo(sheet)
  GetInfo.new(sheet)
end




      # web_search.each{
      #
      # }

      # [company.ld(c1.uri), company.ld(c1.title) ] <=> [company.ld(c2.uri), company.ld(c2.title) ]
      # [c1.uri.ld(company), c1.title.ld(company) ] <=> [c2.uri.ld(company), c2.title.ld(company) ]
      # web_search.first(result_needed)
      # .collect{ |result|
      #   {index: result.index, uri: result.uri, title: result.title }
      # }
      # (&:uri)


# results.first(3).collect(&:uri)
# (1..ws.num_cols).each do |col|
# p ws[row, col]
# end
# def companies_to_be_searched
#   @@companies_to_search ||= File.readlines(FILENAME).map(&:strip!)
# end
#
# def companies_to_be_searched
#   @@companies_to_search ||= CSV.open(FILENAME, headers: true).map{ |company| company["Company"] }
# end
#
# def companies
#   @@companies ||= []
# end

# def worksheets

# ws = session.spreadsheet_by_key("13ToOJaoVgfALm16fEkJrECUkwDpVjfUpbXeXCI4f1sU").worksheets[1]



# puts company
# web_search.first(3).each do |item|
#
# end
# companies_to_be_searched.each do |query|
#
#   CSV.open(CSVDATAFILE, "a+") do |csv|
#     CSV.open(LIKELY, "a+") do |likely|
#
#     File.open('almost_match.txt', 'a+') do |_f|
#         likely << [item.uri, item.title] if item.index == 0 && !item.uri.match(unpermitted_urls)
#         csv << [item.index, item.uri, item.title]
#         _f.puts [item.index, item.uri, item.title].join(' | ')
#       end
#       _f.puts ""
#     end
#   end
#   end
# end


# GetInfo.search


# FILENAME = 'accurate_needed.txt'
# FILENAME = 'test_companies.txt'
# FILENAME = 'newest_accurate_needed.csv'
# # FILENAME = 'latest_accurate.csv'
# CSVDATAFILE = 'final.csv'
# LIKELY = 'likeit.csv'



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
