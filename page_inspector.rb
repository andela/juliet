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
      coy_and_link.merge!(company_name: company_name, link: link, requirement: property("requirement"), duties: property("duties"))
    end
    coy_and_link
  rescue
    coy_and_link
  end

  def property(property_name)
    element_index = 0 if property_name == "duties"
    element_index = 1 if property_name == "requirement"
    property_value = ""
    browser.find("#content").all("ul")[ element_index ].all("li").each do |link|
      if link.first("span")
        property_value += link.first("span").text
      else
        property_value += link.text
      end
    end
    property_value
  rescue
    "Please visit the URL of this listing to get this information."
  end

  def permitted_roles
    /\A(software developer)|frontend|fullstack|backend|(web developer)|(software engineer)|developer|(front end)|(back end)|(full stack)|Full-Stack\z/i
  end

  def unpermitted_roles
    /\ASenior|(5+)\z/
  end
end
