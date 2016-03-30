class Searcher
  attr_reader :company_name, :browser

  def initialize(company_name)
    @browser = Capybara.current_session
    @company_name = company_name
  end

  def look_up_coy_url
    Google::Search::Web.new(query: company_name).all.map(&:visible_uri).uniq[0..2]
  end
end
