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
      # requirement =
      # duties =
      coy_and_link.merge!(company_name: company_name, link: link)
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
