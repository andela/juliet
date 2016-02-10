require 'forwardable'

require './obj-ext'
require './date-ext'
require './url-ext'


class Listing
  attr_accessor :id, :title, :company, :source, :post_date, :url, :company_url, :search_type, :search_date
  attr_reader :finalize

  include Dateable, URLable

  extend SingleForwardable

  @@listings = []
  @@ie_listings = []


  def_delegators :all, :size, :first, :last, :each, :reduce, :select, :map

  def initialize(*args, finalize: true, ie: false)
    @finalize = finalize
    unless args.blank?
      listing_id = args.first[:id]
      listing_url = args.first[:url]
      listing_by_id = listing_id.blank? ? nil : self.class.find(listing_id)
      listing_by_url = listing_url.blank? ? nil : self.class.find_by_url(listing_url)
      existing_listing = listing_by_id || listing_by_url
      if existing_listing
        return existing_listing
      else
        populate_attr(args)
      end
    end
    @@ie_listings << self if ie
    @@listings << self
  end

  def populate_attr(args)
    args.each do |attrib|
      set_attributes(attrib)
    end
  end

  def set_attributes(attrs_to_set={})
    if attrs_to_set.is_a? Hash
      attrs_to_set.each do |key, val|
        attr_set = "#{key}="
        if self.respond_to? attr_set
          self.send(attr_set, val)
        else
          var = "@#{key}"
          self.instance_variable_set(var, val)
        end
      end
    end
  end

  def post_date=(date)
    @post_date = format_date(date)
  end

  def url=(uri)
    if finalize
      @url = get_final_url(uri)
    else
      @url = uri
    end
  end

  def to_h
    info = {}
    attributes.each{ |attribute|
      info[attribute] = self.send(attribute)
    }
    info
  end

  # def ie_to_h
  #   {
  #     id: id,
  #     title: title,
  #     company: company,
  #     source: source,
  #     post_date: post_date,
  #     url: url,
  #     company_url: company_url
  #   }
  # end

  def valid?
    regex_match = /^http[s]?:\/\/www.indeed.com\//i
    !!(regex_match =~ url)
  end

  def self.all
    @@listings
  end

  def self.ie_all
    @@ie_listings
  end

  def self.find(listing_id)
    select{|listing| listing.id == listing_id }.first
  end

  def self.find_by_url(url)
    select{|listing| listing.url == url }.first
  end

  def self.saveable
    reduce([]) do |all_listings, listing|
      all_listings.push(listing.to_h) if listing.valid?
      all_listings
    end
  end

  def self.ie_saveable
    ie_all.reduce([]) do |all_listings, listing|
      all_listings.push(listing.to_h) if listing.valid?
      all_listings
    end
  end
end

# self.send(attr_set, val) if self.respond_to? attr_set
