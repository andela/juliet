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
      !language_exclude.match(l.title) && !companies_to_exclude.match(l.company)
    end
  end

  # def self.all_validated
  #
  # end
end

# def valid?
#   !!(/indeed\.com.+(?=cmp)/i =~ url)
# end
# x.nil? ? valid? : valid? && x
