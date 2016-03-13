#  May not be in use.
Google::Search::Item::Web.class_eval do
  def match_value(company)
    val = 0
    search_for = company.gsub(/[^\w\s\d]/i, '').split
    # search_for = company.split #regex to split with
    search_for.each{ |word|
        word_regex = Regexp.new word, 'i'
        val += 1 if title.match(word_regex)
    }
    val
  end
end
