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
require './listing-ext'


def get_dice_data(limit: 100)
  dice_url = ''
end

MAXLIMIT = 100

def indeed_url(limit = MAXLIMIT, search: nil)
  params_to_search = search || %w{ full stack developer }
  search_for = params_to_search.join("+")
  upper_bound = MAXLIMIT > limit ? limit : MAXLIMIT
  indeed_url = "http://www.indeed.com/jobs?as_and=#{search_for}&as_phr=&as_any=&as_not=senior,+lead,+director,+specialist,+experienced,+senior,+Mid+Level,+Seasoned,+Parttime&as_ttl=&as_cmp=&jt=fulltime&st=employer&sr=directhire&salary=&radius=25&fromage=any&limit=#{upper_bound}&sort=&psf=advsrch"
  indeed_url
end


def get_indeed_data(limit: 100, search: nil, ie_populate: true)
  real_limit = limit
  total = 0

  begin
    next_url ||= indeed_url(limit, search: search )
    page = HTTParty.get(next_url)
    html = Nokogiri::HTML(page)

    all_listings = html.css('#resultsCol').css('.result')
    all_listings.each{ |result|
      unless result.css('span.iaLabel').blank?
        obj = {}
        obj[:id] = result.css('h2.jobtitle')[0]['id']
        obj[:title] = result.css('.turnstileLink')[0]['title']
        obj[:url] = 'http://www.indeed.com'+ result.css('.turnstileLink')[0]['href']
        obj[:source] =  'Indeed'
        obj[:post_date] = result.css('.result-link-bar').css('.date').text
        obj[:company] = result.css('.company').text.strip
        obj[:search_date] = Date.today.strftime("%d-%m-%Y")
        obj[:search_type] = search.join(' ')
        obj[:company_url]
        Listing.new(obj, finalize: true, ie: ie_populate)
      end
      total += 1
    }

    jobs = Listing.all
    valid_gotten = ie_populate ? Listing.ie_saveable : Listing.saveable
    next_limit = limit - valid_gotten.size
    remaining = real_limit - valid_gotten.size
    limit **= 2 if limit == next_limit && limit < MAXLIMIT
    next_url = indeed_url(next_limit, search: search) +  "&start=#{total}" # "&start=#{jobs.size}"
    next_btn = html.css("#resultsCol").css(".pagination").css(".pn").css(".np").try(:last).try(:text)
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

def repopulate_data(sheet, tab)
  # get data from here
  sheet = sheet.is_a?(String) ? GSheet.new(sheet) : sheet
  data_sheet = sheet.worksheets[tab]
  valids = []
  1.upto(data_sheet.num_rows) do |row|
      listing = Listing.new(finalize: false).tap do |l|
        l.id = data_sheet[row, 1]
        l.title = data_sheet[row, 2]
        l.url = data_sheet[row, 3]
        l.source = data_sheet[row, 4]
        l.post_date = data_sheet[row, 5]
        l.company = data_sheet[row, 6]
      end
      valids << listing if listing.validated? # [at this point this is Listing.all]
  end
  # require 'pry' ; binding.pry
  # 1uAFNyapvG2n1PhtxDmhOxz52sXJ_hKg5FusYgYAxdK0
# sheet = GSheet.new('1uVZkmo_SPTjXEDc9CZ0QEMotfWiwtybb1QuA7A_cJZI')
# sheet.save(0, valids.map(&:to_h))

end

def ie_populate_data(sheet, tab)
  sheet = sheet.is_a?(String) ? GSheet.new(sheet) : sheet
  data_sheet = sheet.worksheets[tab]
  valids = []
  3.upto(data_sheet.num_rows) do |row|
      obj = {}
      obj[:id] = data_sheet[row, 1]
      obj[:title] = data_sheet[row, 2]
      obj[:company] = data_sheet[row, 3]
      obj[:source] = data_sheet[row, 4]
      obj[:post_date] = data_sheet[row, 5]
      obj[:url] = data_sheet[row, 6]
      obj[:company_url] = data_sheet[row, 7]
      listing = Listing.new(obj, finalize: false, ie: false)
      valids << listing if listing.validated? # [at this point this is Listing.all]
  end
  valids
end

def ie_repopulate_data_remove_applied(sheet, tab)
  sheet = sheet.is_a?(String) ? GSheet.new(sheet) : sheet
  data_sheet = sheet.worksheets[tab]
  unapplied = data_sheet.rows[3..data_sheet.num_rows].select{|x| !x[12].match(/^applied/i) }
  (3..data_sheet.num_rows).each do |x|
    1.upto(data_sheet.num_cols) do |y|
      data_sheet[x, y] = nil
    end
  end
  sheet.save(tab, unapplied, start_row: 3, sheet: data_sheet)
  sheet
end

def save_listing_record(sheet, tab, listing: Listing.ie_saveable)
  sheet = sheet.is_a?(String) ? GSheet.new(sheet) : sheet
  next_data_row = sheet.worksheets[tab].num_rows + 1
  sheet.save(tab, listing, start_row: next_data_row )
end

def save_job_ids(sheet, tab)
  sheet = sheet.is_a?(String) ? GSheet.new(sheet) : sheet
  jobsidtab = sheet.worksheets[tab]
  ids = jobsidtab.rows.flatten
  ids += Listing.map(&:id)
  ids.uniq!
  sheet.save(tab, ids, sheet: jobsidtab)
end

def record_stats(sheet, tab)
  sheet = sheet.is_a?(String) ? GSheet.new(sheet) : sheet
  raise StandardError unless sheet.is_a? GSheet
  data_sheet = sheet.worksheets[tab]
  listing_data = Listing.ie_all.reduce(Hash.new(0)){ |all, listing|
    all[listing.search_type] += 1 # if listing.is_a? Listing
    # all[listing[]]
    all
  }
  listing_stats = listing_data.map{ |search_type, total|
    [search_type, total, Date.today.strftime("%d-%m-%Y")]
  }
  current_tally = data_sheet.num_rows
  next_data = current_tally + 1

  sheet.save(tab, listing_stats, start_row: next_data , sheet: sheet)
end


def init(sheet, search: ['full', 'stack', 'developer'] , data_sheet: 1, id_sheet: 5, stats_sheet: 6)
  ie_populate_data(sheet, data_sheet)
  listings = sheet.worksheets[id_sheet]
  ids = listings.rows.flatten
  puts "Current listing at #{ids.size}"
  get_indeed_data(limit: 400, search: search)
  save_listing_record(sheet, data_sheet)
  save_job_ids(sheet, id_sheet)
  listings.reload
  new_ids = listings.rows.flatten
  puts "Total of #{ new_ids.size - ids.size } listings has been added"
  record_stats(sheet, stats_sheet)
  # require 'pry' ; binding.pry
end

# init # ie_populate_data
# get_indeed_data(search: [], limit: 400)
# save_listing_record

# save_job_ids
# record_stats

# (3..data_sheet.num_rows).each do |x|
#   1.upto(data_sheet.num_cols) do |y|
#     data_sheet[x, y] = nil
#   end
# end



# def
#
# end



# require 'pry' ; binding.pry
# sheet = GSheet.new('')
# valids = []
# 1.upto(data_sheet.num_rows) do |row|
#   # unless data_sheet[row, 13].match(/applied/i)
#   #   obj = {}
#   #   obj[:job_id] = data_sheet[row, 1]
#   #   obj[:title] = data_sheet[row, 2]
#   #   obj[:company] = data_sheet[row, 3]
#   #   obj[:source] = data_sheet[row, 4]
#   #   obj[:post_date] = data_sheet[row, 5]
#   #   obj[:url] = data_sheet[row, 6]
#   #   obj[:company_url] = data_sheet[row, 7]
#   #   obj[:linkedin] = data_sheet[row, 8]
#   #   obj[:location_city] = data_sheet[row, 9]
#   #   obj[:location_state] = data_sheet[row, 10]
#   #   obj[:employees] = data_sheet[row, 11]
#   #   obj[:industry] = data_sheet[row, 12]
#   #   obj[:status] = data_sheet[row, 13]
#   #   obj[:date_applied] = data_sheet[row, 14]
#   #   obj[:ie_feedback] = data_sheet[row, 15]
#   #   obj[:viewed] = data_sheet[row, 16]
#   #   obj[:response] = data_sheet[row, 17]
#   #   obj[:mql] = data_sheet[row, 18]
#   #   obj[:feedback] = data_sheet[row, 19]
#   #   obj[:next_step] = data_sheet[row, 20]
#   #   listing = Listing.new(obj, finalize: false, ie: false)
#   #   valids << listing if listing.validated? # [at this point this is Listing.all]
#   end
# end


# listing = Listing.new(finalize: false).tap do |l|
  # l.title = data_sheet[row, 1]
  # l.company = data_sheet[row, 2]
  # l.source = data_sheet[row, 3]
  # l.post_date = data_sheet[row, 4]
  # l.url = data_sheet[row, 5]
  # l.company_url = data_sheet[row, 6]
# end


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
