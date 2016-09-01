 require "./resources"

class PageInspector
  include Utility
  attr_reader :url, :browser

  def initialize(url)
    @url = url
    @browser = Capybara.current_session
  end

  def listing_info(link = url)
    coy_and_link = {}
    if link.include? "greenhouse"
      browser.visit link
      page_url = browser.current_url.split("#").first
      if page_url == link
        company_name = browser.find(".company-name", visible: false).text.sub("at ","")
        location = browser.has_css?(".location") ? browser.find(".location").text : ""
        coy_and_link.merge!(company_name: company_name, link: link, requirement: property("requirement", link), duties: property("duties", link), location: location)
      end
      coy_and_link
    elsif link.include? "lever"
      browser.visit link
      page_url = browser.current_url.split("#").first
      if page_url == link
        company_name = browser.find("title").text.split("-").first.strip
        location = browser.has_css?(".posting-categories") ? browser.find(".sort-by-time").text : ""
        title = browser.find("h2", match: :first).text
        coy_and_link.merge!(company_name: company_name, link: link, requirement: property("requirement", link), duties: property("duties", link), location: location, title: title)
      end
      coy_and_link
    elsif link.include? "workable"
      browser.visit link
      page_url = browser.current_url.split("#").first
      company_name = browser.find("title").text.split("-").first.strip
      location = browser.has_css?(".section--header") ? browser.find(".meta").text.split(",").first.strip : ""
      title = browser.find("h1").text
      coy_and_link.merge!(company_name: company_name, link: link, requirement: property("requirement", link), duties: property("duties", link), location: location, title: title)
      coy_and_link
    end

  rescue
    coy_and_link
  end

  def property(property_name, link)
    #element_index = 0 if property_name == "duties"
    #element_index = 1 if property_name == "requirement"
    if link.include? "greenhouse"
      property_value = browser.find('#content').text
    elsif link.include? "lever"
      property_value = browser.all('.content > .section-wrapper', match: :first)[1].text
    elsif link.include? "workable"
      property_value = browser.all('.section--text')[0].text.sub("Description","") + browser.all('.section--text')[1].text
    end
=begin
    browser.find("#content").all("ul")[ element_index ].all("li").each do |link|
      if link.first("span")
        property_value += link.first("span").text
      else
        property_value += link.text
      end
    end
    property_value = permitted?(property_value) ? property_value : nil
=end
    property_value = permitted?(property_value) ? property_value : nil
    return property_value
  rescue
    "Please visit the URL of this listing to get this information."
  end
end
