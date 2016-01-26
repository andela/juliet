require 'nokogiri'
require 'httparty'
require 'pry'
require 'httpclient'
require 'active_support/core_ext/integer/time'
require 'forwardable'

require './custom_google'
require './sheets'
require './date-ext'
require './obj-ext'
require './url-ext'
require './listing'
require './listing-ext'


# def exclusion_list
#   sheet = GSheet.new '18qGCs7WC09In3yD-HH3F1h-ysLuMDKyPRpCadS0A77g'
#   exclusion_sheet = sheet.worksheets[2]
#   excludes = exclusion_sheet.rows
#   @company_url_map = {}
#   excludes.each{ |row|
#     row.each_with_index{ |col, index|
#       # mapping the company to the url using the spreadsheet format
#       next_col = row[index + 1]
#       @company_url_map[col] = next_col unless col.blank? || next_col.blank?
#     }
#   }
#   @company_url_map
# end

# exclusion_list


def get_dice_data(limit: 100)
  dice_url = ''
end

MAXLIMIT = 100

def indeed_url(limit = MAXLIMIT)
  upper_bound = MAXLIMIT > limit ? limit : MAXLIMIT
  indeed_url = "http://www.indeed.com/jobs?as_and=full+stack+developer&as_phr=&as_any=&as_not=senior,+lead,+director,+specialist,+experienced,+senior,+Mid+Level,+Seasoned,+Parttime&as_ttl=&as_cmp=&jt=fulltime&st=employer&sr=directhire&salary=&radius=25&fromage=any&limit=#{upper_bound}&sort=&psf=advsrch"
  indeed_url
end


def get_indeed_data(limit: 100)
  real_limit = limit

  begin
    next_url ||= indeed_url(limit)
    page = HTTParty.get(next_url)
    html = Nokogiri::HTML(page)

    html.css('#resultsCol').css('.result').each{ |result|
      obj = {}
      obj[:title] = result.css('.turnstileLink')[0]['title']
      obj[:url] = 'http://www.indeed.com'+ result.css('.turnstileLink')[0]['href']
      obj[:source] =  'Indeed'
      obj[:post_date] = result.css('.result-link-bar').css('.date').text
      obj[:company] = result.css('.company').text.strip
      obj[:company_url]
      Listing.new(obj)
    }

    jobs = Listing.all
    valid_gotten = Listing.saveable
    next_limit = limit - valid_gotten.size
    remaining = real_limit - valid_gotten.size
    limit **= 2 if limit == next_limit && limit < MAXLIMIT
    next_url = indeed_url(next_limit) +  "&start=#{jobs.size}"
    next_btn = html.css("#resultsCol").css(".pagination").css(".pn").css(".np").last.text
  end while( remaining > 0 && next_btn.match(/Next/))
  # Listing.all
end

def save_data(tab=1)
  sheet = GSheet.new('15EVVpDe85GlqLf1_TvkBGRoJ5qQgtKSKBWXES9MTcFE')
  sheet.save(tab, Listing.saveable)
end

def populate_indeed
  # page = HTTParty.get('http://www.indeed.com/jobs?as_and=full+stack+developer&as_phr=&as_any=&as_not=senior%2C+lead%2C+director%2C+specialist%2C+experienced%2C+senior%2C+Mid+Level%2C+Seasoned%2C+Parttime&as_ttl=&as_cmp=&jt=fulltime&st=employer&sr=directhire&salary=&radius=25&l=&fromage=any&limit=2&sort=&psf=advsrch')
  url = 'http://www.indeed.com/jobs?as_and=full+stack+developer&as_phr=&as_any=&as_not=senior,+lead,+director,+specialist,+experienced,+senior,+Mid+Level,+Seasoned,+Parttime&as_ttl=&as_cmp=&jt=fulltime&st=employer&sr=directhire&salary=&radius=25&fromage=any&limit=100&sort=&psf=advsrch'
  page = HTTParty.get(url)
  html = Nokogiri::HTML(page)

  jobs = []
  # c = 0
  html.css('#resultsCol').css('.result').each{ |result|
    # puts c += 1
    obj = {}

    url = 'http://www.indeed.com'+ result.css('.turnstileLink')[0]['href']
    date = result.css('.result-link-bar').css('.date').text
    final_dest = get_final_url(url)
    date = format_date(date)

    obj[:title] = result.css('.turnstileLink')[0]['title']
    obj[:url] = final_dest
    obj[:source] =  'Indeed'
    obj[:post_date] = date
    obj[:company] = result.css('.company').text.strip
    obj[:company_url]
    jobs << obj
  }
  next_url = url + "&start=#{jobs.size}"

  # binding.pry
  sheet = GSheet.new('1JmDKlL-Z_LuM0P-ON7gZTbq3G-4dxiHw9Lo33F4n1jQ')
  sheet.save(0, jobs)
end

def check_remote_co(url)
  page = HTTParty.get(url)
  html = Nokogiri::HTML(page)
  company_info = html.css('#company_info_section')
  company = {}
  company[:name] = company_info.css('.title').css('h1').text.strip
  begin
    company[:url] = company_info.css('#company_contact_section').css('dd').css('span').css('a')[0]['href']
  rescue
    company[:url] = company_info.css('#parent_company_section').css('dd').css('span').css('a')[0]['href']
  end
  company
end


def populate_remoteus
  page = HTTParty.get('https://remote.co/qa-leading-remote-companies/')
  html = Nokogiri::HTML(page)
  listing = []
  companies = []
  company_tags = html.css('.qa_home_logos').css('#container').css('.qa_home_logo_container')
  company_tags.css('a').each do |result|
      url = result['href']
      listing << url
      companies << check_remote_co(url)
  end

  sheet = GSheet.new('1JmDKlL-Z_LuM0P-ON7gZTbq3G-4dxiHw9Lo33F4n1jQ')
  sheet.save(1, companies)
end

def get_company_url(sheet, tab)
  x = GSheet.new(sheet)
  uris = []
  x.get_data_from_column(tab, col: 5) do |data|

    search_data = GetInfo.search(data, result_needed: 1)
    uri = search_data.first.uri
    company = {}
    company[:uri] = uri
    uris << company
  end
end

def repopulate_data
  # get data from here
  sheet1 = GSheet.new('1fYSSp1v3zBQ4mhKrIcJ9Sox-BZCE052doPk5gCJ-U00')
  data_sheet = sheet1.worksheets[0]
  valids = []
  1.upto(data_sheet.num_rows) do |row|
      listing = Listing.new(finalize: false).tap do |l|
        l.title = data_sheet[row, 1]
        l.url = data_sheet[row, 2]
        l.source = data_sheet[row, 3]
        l.post_date = data_sheet[row, 4]
        l.company = data_sheet[row, 5]
      end

      valids << listing if listing.validated?
  end
  # require 'pry' ; binding.pry
# sheet = GSheet.new('1uVZkmo_SPTjXEDc9CZ0QEMotfWiwtybb1QuA7A_cJZI')
# sheet.save(0, valids.map(&:to_h))

end



# remaining = limit - jobs.size
#remaining > 0 ? remaining : nil
# while(true until false)
# def mapping

# valids << listing if valid
# https://docs.google.com/spreadsheets/d/1fYSSp1v3zBQ4mhKrIcJ9Sox-BZCE052doPk5gCJ-U00/edit#gid=0
# https://docs.google.com/spreadsheets/d/1uVZkmo_SPTjXEDc9CZ0QEMotfWiwtybb1QuA7A_cJZI/edit#gid=1256831373
# require 'pry' ; binding.pry
  # data_sheet.rows.each{ |job_data|
  #   listing = Listing.new.tap do |l|
  #
  #     job_data.each_with_index{ |col, index|
  #         l.title = col if index == 0
  #         l.url = col if index == 1
  #         l.source = col if index == 2
  #         l.post_date = col if index == 3
  #         l.company = col if index == 4
  #     }
  #
  #   end
  # }
  # data_sheet.rows.each{
  #
  # }
  # add data to this
  # sheet2 = GSheet.new()
# https://docs.google.com/spreadsheets/d/1uVZkmo_SPTjXEDc9CZ0QEMotfWiwtybb1QuA7A_cJZI/edit#gid=1256831373



# /(?=5).*(?=years)/
# require 'pry' ; binding.pry
# save(tab, uris, start_row: 1, start_col: 1)
# data = {url: search.url}#[search.url]

# sheet[] = data
# data_found = search(data)#.map{ |d| { url: d.uri }}
# sheet[] = data_found.first.uri
