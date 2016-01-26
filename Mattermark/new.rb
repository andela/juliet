require 'faraday'
require 'page_rankr'
require 'json'
require 'csv'

Object.class_eval do
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end
end

class MatterMark
  API_KEY = 'kapeTe6EsPeduruchUswAve4enUmeqaw'
  ENDPOINT = 'https://api.mattermark.com'
  # FILENAME = 'test_companies.txt'
  FILENAME = 'accurate_needed.txt'

  class << self
    attr_accessor :connection
    attr_reader :companies

    def companies_interest
      companies_to_be_searched.each{ |company|
        puts company
        search(company)
      }
    end

    def companies_to_be_searched
      @@companies_to_search ||= File.readlines(FILENAME).map(&:strip!)
    end

    def companies
      @@companies ||= []
    end

    def connection
      @@connection ||= Faraday::Connection.new(ENDPOINT)
    end

    def params(params = {})
      basic = { key: API_KEY }
      if params
        params = convert_to_hash(params) if params.is_a? String
        basic.merge(params)
      end
    end

    def convert_to_hash(params)
      all_params = params.split('&')
      params = {}
      all_params.each do|param|
        key, value = param.split('=')
        value = true if value.blank?
        params[key] = value
      end
      params
    end

    def search(group_name)
      params = params(object_type: 'company', term: group_name)
      response = connection.get('/search', params)
      data = parse_data(response)
      create_company(group_name, data)
    end

    def create_company(group_name, data)
      data.each do|d|
        company_name = d['object_name']
        mmid = d['object_id']
        url = d['company_domain']
        mmscore = d['company_mattermark_score']
        begin
          ranking = PageRankr.ranks(url, :alexa_global)# , :moz_rank
          alexa = ranking[:alexa_global] || 100_000_000_000_000
          moz = ranking[:moz_rank] || 0
          puts ranking
          # rank = alexa
          # rank = PageRankr.ranks(url, :google)[:google].to_i
        rescue
          moz = 0
          alexa = 100_000_000_000_000
          # rank = 100_000_000_000_000
        end
        rank = {alexa: alexa , moz: moz}
        # .values.map(:to_i)
        rank.each{ |key, val| rank[key] = val.to_i }
        companies << Company.new(group_name, company_name, mmid, url, rank, mmscore)
      end
    end

    def parse_data(response)
      body = response.body
      JSON.parse(body) unless body.blank?
    end

    def populate_company(id)
      response = connection.get("/companies/#{id}", params)
      parse_data(response)
    end
  end
end

class Company
  attr_reader :name, :mmid, :url, :data, :rank, :group, :mmscore
  @@group = {}
  CSVDATAFILE = "data_matched.csv"
  TXTDATAFILE = "matched.txt"
  GUESSFILE = "likely.txt"

  def initialize(group, name, mmid, url, rank, mmscore)
    @name = name
    @mmid = mmid
    @url = url
    @rank = rank
    @group = group
    @mmscore = mmscore
    @@group[group] ||= []
    @@group[group] << self
  end

  def populate
    @data = MatterMark.populate_company(mmid)
  end

  def to_s
      "Company: #{@name} | MatterMarkID: #{@mmid} | URL: #{@url} | PageRank: #{@rank} | MatterMarkScore: #{@mmscore}| Appeared In Search For: #{@group}"
  end

  alias_method :old_to_s, :to_s

  def to_s
    "Company: #{@name} | MatterMarkID: #{@mmid} | URL: #{@url} | AlexaRank: #{@rank[:alexa]} | MozRank: #{@rank[:moz]} | MatterMarkScore: #{@mmscore}| Appeared In Search For: #{@group}"
  end

  def to_h
    {name: @name, mmid: @mmid, url: @url, rank: @rank, mattermark_score: @mmscore ,group: @group }
  end

  alias_method :old_to_h, :to_h

  def to_h
    {name: @name, mmid: @mmid, url: @url, alexa_rank: @rank[:alexa], moz_rank: @rank[:moz] , mattermark_score: @mmscore ,group: @group }
  end

  class << self
    def all
      @@group
    end

    def order
      all.each do |_company_group, value|
        value.sort! do|a, b|
          a.rank.to_i <=> b.rank.to_i
        end
      end
    end

    def order_by_alexa_and_moz
      all.each do |_company_group, value|
        value.sort! do|a, b|
          [a.rank[:alexa], b.rank[:moz]] <=> [b.rank[:alexa], a.rank[:moz]]
        end
      end
    end

    def all_to_h
      all.values.flatten
    end

    def each
      all.each{ |company|
        yield company
      }
    end

    def to_csv
      hashes = all_to_h
      CSV.open(CSVDATAFILE, "w", headers: hashes.first.to_h.keys) do |csv|
        hashes.each do |h|
          csv << h.to_h.values
        end
      end
    end

    def companies_searched
      all.keys
    end

    def from_csv
      data = CSV.read(CSVDATAFILE)
      data.each{|record|
        {name: @name, mmid: @mmid, url: @url, rank: @rank, mattermark_score: @mmscore ,group: @group }
        name, mmid, url, rank, mattermark_score, group = record
        new(group, name, mmid, url, rank, mattermark_score)
      }
    end

    alias_method :old_from_csv, :from_csv

    def from_csv
      data = CSV.read(CSVDATAFILE)
      data.each{|record|
        name, mmid, url, alexa, moz, mattermark_score, group = record
        rank = {alexa: alexa, moz: moz}
        new(group, name, mmid, url, rank, mattermark_score)
      }
    end

    def predictive_guess
      matches = match
      File.open(GUESSFILE, 'w') do |f|
        matches.each{ |_group, _val|
          f.puts _group
          if _val.is_a? Array
            _val.each{ |company|
              f.puts company.to_s
            }
          else
            f.puts _val.to_s
          end
          f.puts "\n"
        }
      end
    end

    def match
      comp = {}
      all.each{ |search, matches|
        total_matches = matches.size
        matches.each_with_index{ |company, index|
          if search.strip.downcase == company.name.strip.downcase
            comp[search] = company
            break
          elsif index == (total_matches - 1)
            comp[search] = matches
          end
        }
      }
      return comp
    end

    def save
      File.open(TXTDATAFILE, 'w') do |f|
        all.each{ |_group, _val|
          f.puts _groupx
          _val.each{|_each_val|
            f.puts _each_val.to_s
          }
          f.puts "\n"
        }
      end
    end
  end
end

class Matching
  MATCHEDFILE = 'matched_companies.txt'
  UNMATCHEDFILE = 'unmatched_companies.txt'

  def self.start
    MatterMark.companies_interest
    Company.order_by_alexa_and_moz
    Company.predictive_guess

    Company.save
    Company.to_csv
    # Company.order
  end

  def self.stats_from_file
    Company.from_csv
    all_matched = Company.all.keys
    all_searched = MatterMark.companies_to_be_searched
    not_found = all_searched - all_matched

    total_not_found = not_found.size
  end

  def self.stats
    all_matched = Company.all.keys
    all_searched = MatterMark.companies_to_be_searched
    not_found = all_searched - all_matched
    File.open(MATCHEDFILE, 'w'){ |f| f.write(all_matched.join("\n"))}
    File.open(UNMATCHEDFILE, 'w'){ |f| f.write(not_found.join("\n"))}
    total_not_found = not_found.size
  end

  # def :>
end
