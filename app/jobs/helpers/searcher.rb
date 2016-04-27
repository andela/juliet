class Searcher
  attr_reader :company_name

  def initialize(company_name)
    @company_name = company_name
  end

  def search_coy_type
    return look_up_aggregator if permitted?(company_name).nil?
    look_up_coy_url
  end

  def look_up_coy_url
    search_result = Google::Search::Web.new(query: company_name).
                    detect { |n| !permitted?(n.visible_uri).nil? }
    search_result.visible_uri unless search_result.nil?
  end

  def look_up_aggregator
    search_result = Google::Search::Web.new(query: company_name).first
    search_result.visible_uri unless search_result.nil?
  end

  def permitted?(visible_uri)
    visible_uri if visible_uri.downcase.
                   match(data_aggregators.join("|").downcase).nil?
  end

  def data_aggregators
    ["linkedin", "twitter", "crunchbase", "itunes.apple", "google", "yahoo",
     "facebook", "bing", "wikipedia", "github", "techcrunch", "wordpress",
     "greenhouse", "amazon", "youtube", "oreilly", "angel.co", "entrepreneur",
     "reddit", "imdb", "indiegogo", "about", "tech.co"]
  end
end
