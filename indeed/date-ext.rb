require 'active_support/core_ext/integer/time'


module Dateable
  def format_date(date)
    matcher = /^(?<day>\d+)[\+]?\s(?<period>hour[s]?|day[s]?|month[s]?)/
    matches = date.match(matcher)
    if matches
      day = matches[:day].to_i
      period = matches[:period].to_sym
      final_date = Time.now - day.send(period)
      final_date.strftime("%d/%m/%Y")
    else
      date
    end
  end
end

# def format_date(date)
#   matcher = /^(?<day>\d+)\s(?<period>hour[s]?|day[s]?)/
#   matches = date.match(matcher)
#   day = matches[:day].to_i
#   period = matches[:period].to_sym
#   final_date = Time.now - day.send(period)
# end


# html.css('.qa_home_logos').css('#container').each{ |result|
#   result.css('.qa_home_logo_container').css('a').each{ |x|
#     x['href' ]
#   }
# }


# x = 0

# puts x += 1

# resultsCol > div.pagination > a:nth-child(12) > span > span
# puts c += 1

# next_btn = "Prev"
  # require 'pry' ; binding.pry
