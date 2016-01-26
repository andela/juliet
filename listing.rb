require 'forwardable'

require './obj-ext'
require './date-ext'
require './url-ext'


class Listing
  attr_accessor :title, :url, :source, :post_date, :company, :company_url, :finalize
  include Dateable, URLable

  extend SingleForwardable

  @@listings = []

  def_delegators :all, :size, :first, :last, :each, :reduce

  def initialize(*args, finalize: true)
    @finalize = finalize
    args.each do |attrib|
      set_attributes(attrib)
    end
    @@listings << self
  end

  def set_attributes(attrs_to_set={})
    if attrs_to_set.is_a? Hash
      attrs_to_set.each do |key, val|
        attr_set = "#{key}="
        self.send(attr_set, val) if self.respond_to? attr_set
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
    # require 'pry' ; binding.pry
  end

  def to_h
    info = {}
    attributes.each{ |attribute|
      info[attribute] = self.send(attribute)
    }
    info
  end

  def valid?
    !!(/indeed\.com.+(?=cmp)/i =~ url)
  end

  def self.all
    @@listings
  end


  def self.saveable
    reduce([]) do |all_listings, listing|
      all_listings.push(listing.to_h) if listing.valid?
      all_listings
    end
  end
end

# include Forwardable
# all.map(&:to_h)
# all.select{|listing|
#   listing.to_h if listing.valid?
# }
