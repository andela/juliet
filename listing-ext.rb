require './listing'
require './validators'

class Listing
  include Validator

  def all_valid?
    x = yield self
    valid? && x
  end


  def validated?
    all_valid? do |l|
      !language_exclude.match(l.title) && !self.class.companies_to_exclude.match(l.company)
    end
  end

  def self.saveable
    reduce([]) do |all_listings, listing|
      all_listings.push(listing.to_h) if listing.validated?
      all_listings
    end
  end

  def self.ie_saveable
    @@ie_listings.reduce([]) do |all_listings, listing|
      all_listings.push(listing.ie_to_h) if listing.validated?
      all_listings
    end
  end
end
