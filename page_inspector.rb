require "./resources"

class PageInspector

  attr_reader :url, :browser

  def initialize(url)
    @url = url
    @browser = Capybara.current_session
  end

  def listing_info(link = url)
    coy_and_link = {}
    browser.visit link
    page_url = browser.current_url.split("#").first
    if page_url == link
      company_name = browser.find(".company-name", visible: false).text.sub("at ","")
      coy_and_link.merge!(company_name: company_name, link: link)
    # else
    #   browser.find("#main").all("a").each do| n |
    #     unless n.text.scan(permitted_roles).flatten.all?(&:nil?)
    #       link = n["href"].start_with?("/") ? "https://boards.greenhouse.io" + n["href"] : n["href"]
    #       listing_info(link)
    #     end
    #   end
    end
    coy_and_link
  rescue
    coy_and_link
  end

  def permitted_roles
    /\A(software developer)|frontend|fullstack|backend|(web developer)|(software engineer)|developer|(front end)|(back end)|(full stack)|Full-Stack\z/i
  end

  def unpermitted_roles
    /\ASenior|(5+)\z/
  end

end

# inspector = PageInspector.new("https://boards.greenhouse.io/enernoc/jobs/118749?t=52cgjt")
# inspector.listing_info
