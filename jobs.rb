require 'nokogiri'
require 'httparty'
require 'pry'
require 'httpclient'
require 'active_support/core_ext/integer/time'
require 'hashie'
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
  indeed_url = "http://www.indeed.com/jobs?as_and=#{search_for},Indeedapply:1&as_phr=&as_any=&as_not=senior,+lead,+director,+specialist,+experienced,+senior,+Mid+Level,+Seasoned,+Parttime&as_ttl=&as_cmp=&jt=fulltime&st=employer&sr=directhire&salary=&fromage=any&limit=#{upper_bound}&sort=&psf=advsrch"
  indeed_url
end

# "http://www.indeed.com/jobs?q=#{search_for}+-senior,+-lead,+-director,+-specialist,+-experienced,+-senior,+-Mid+-Level,+-Seasoned,+-Parttime,+Indeedapply%3A1&radius=25"
# "http://www.indeed.com/jobs?q=full+stack+developer+-senior%2C+-lead%2C+-director%2C+-specialist%2C+-experienced%2C+-senior%2C+-Mid+-Level%2C+-Seasoned%2C+-Parttime%2C+Indeedapply%3A1&start=30"



def get_indeed_data(limit: 100, search: nil, ie_populate: true)
  current_size = ie_populate ? Listing.ie_saveable.size : Listing.saveable.size
  limit += current_size
  puts "#{current_size} already exists, looking for #{limit} more"
  real_limit = limit
  total = 0

  begin
    next_url ||= indeed_url(limit, search: search)
    page = HTTParty.get(next_url)
    html = Nokogiri::HTML(page)

    all_listings = html.css('#resultsCol').css('.result')
    all_listings.each{ |result|
      evaluate_object(result, search, ie_populate)
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
end

def evaluate_object(result, search, ie_populate)
  unless result.css('span.iaLabel').blank?
    obj = populate_obj(result, search)
    url = obj[:url]
    finalize= !(/^http[s]?:\/\/www.indeed.com\/cmp/i).match(url)
    obj[:url] = get_url(url) if finalize
    Listing.new(obj, finalize: false, ie: ie_populate)
  end
end

def populate_obj(result, search)
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

  obj
end


def get_url url
  uri = URI(url)
  id = params(uri.query)[:jk]
  # puts obj[:url] #if finalize
  "http://www.indeed.com/viewjob?jk=#{id}"
end

def params(q)
  Hashie.symbolize_keys q.split('&').map{|x| x.split('=')}.to_h
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

# def indeed_d

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
  puts "Getting current data from spreadsheet to ensure there are no duplicates"
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
  puts "Mainly for easy management, removing all rows that lists as applied"
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

def ie_repopulate_data_resort(sheet, tab, data: Listing.saveable)
  puts "Emptying all the rows and saving all objects that could be saved"
  sheet = sheet.is_a?(String) ? GSheet.new(sheet) : sheet
  data_sheet = sheet.worksheets[tab]
  # data = Listing.saveable
  (3..data_sheet.num_rows).each do |x|
    1.upto(data_sheet.num_cols) do |y|
      data_sheet[x, y] = nil
    end
  end
  data_sheet.save
  sheet.save(tab, data, start_row: 3, sheet: data_sheet)
  sheet
end

def save_listing_record(sheet, tab, listing: Listing.ie_saveable)
  puts "Saving all listsing records. Total of #{listing.size} records will be saved"
  sheet = sheet.is_a?(String) ? GSheet.new(sheet) : sheet
  next_data_row = sheet.worksheets[tab].num_rows + 1
  sheet.save(tab, listing, start_row: next_data_row )
end

def save_job_ids(sheet, tab)
  puts "Saving all uniq job ids."
  puts "This ids are not really being used now, however in the next tweak of the methods, before creating a new Listing object, it would first check if the ids already exists"
  sheet = sheet.is_a?(String) ? GSheet.new(sheet) : sheet
  jobsidtab = sheet.worksheets[tab]
  ids = jobsidtab.rows.flatten
  ids += Listing.map(&:id)
  ids.uniq!
  sheet.save(tab, ids, sheet: jobsidtab)
end

def record_stats(sheet, tab)
  puts "Recording the stats of the search made/done"
  sheet = sheet.is_a?(String) ? GSheet.new(sheet) : sheet
  raise StandardError unless sheet.is_a? GSheet
  data_sheet = sheet.worksheets[tab]
  listing_data = Listing.ie_all.reduce(Hash.new(0)){ |all, listing|
    all[listing.search_type] += 1
    # if listing.is_a? Listing
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
  puts "Initiating the process"
  ie_populate_data(sheet, data_sheet)
  listings = sheet.worksheets[id_sheet]
  ids = listings.rows.flatten
  puts "Current listing at #{ids.size}"
  get_indeed_data(limit: 400, search: search)
  ie_repopulate_data_resort(sheet, data_sheet)
  # save_listing_record(sheet, data_sheet)
  save_job_ids(sheet, id_sheet)
  listings.reload
  new_ids = listings.rows.flatten.uniq
  puts "For a search for #{search.join(' ')}, a total of #{ new_ids.size - ids.size } listings has been added"
  record_stats(sheet, stats_sheet)
  require 'pry' ; binding.pry
end
