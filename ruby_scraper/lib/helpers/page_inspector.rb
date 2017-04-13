# require "#{Rails.root}/lib/helpers/resources"

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
        title = browser.find('h1.app-title').text
        coy_and_link.merge!(company_name: company_name, link: link, description: property("description", link), requirements: property("requirements", link), responsibilities: property("responsibilities", link), location: location, title: title)
      end
      coy_and_link
    elsif link.include? "lever"
      browser.visit link
      page_url = browser.current_url.split("#").first
      if page_url == link
        company_name = browser.find("title").text.split("-").first.strip
        location = browser.has_css?(".posting-categories") ? browser.find(".sort-by-time").text : ""
        title = browser.find("h2", match: :first).text
        coy_and_link.merge!(company_name: company_name, link: link, description: property("description", link), requirements: property("requirements", link), responsibilities: property("responsibilities", link), location: location, title: title)
      end
      coy_and_link
    elsif link.include? "workable"
      browser.visit link
      page_url = browser.current_url.split("#").first
      if page_url == link
        company_name = browser.find("title").text.split("-").first.strip
        location = browser.has_css?(".section--header") ? browser.find(".meta").text.split(",").first.strip : ""
        title = browser.find("h1").text
        coy_and_link.merge!(company_name: company_name, link: link, description: property("description", link), requirements: property("requirements", link), responsibilities: property("responsibilities", link), location: location, title: title)
      end
      coy_and_link
      elsif link.include? "jobvite"
        browser.visit link 
        page_url = browser.current_url.split("#").first
        if page_url == link
          company_name = browser.find('title').text.split('-').sub('Careers', '').strip
          location = browser.find('p.jv-job-detail-meta').text.split.last
          title = browser.find('h2.jv-header').text
          coy_and_link.merge!(company_name: company_name, link: link, description: property("description", link), requirements: property("requirements", link), responsibilities: property("responsibilities", link), location: location, title: title)
        end
        coy_and_link
      elsif link.include? "smartrecruiters"
        browser.visit link 
        page_url = browser.current_url.split("#").first
        if page_url == link
          company_name = browser.find('meta[itemprop="hiringOrganization"]')["content"]
          location = browser.find('li[itemprop="jobLocation"]').text
          title = browser.find('.job-title[itemprop="title"]').text.split(',').first
          coy_and_link.merge!(company_name: company_name, link: link, description: property("description", link), requirements: property("requirements", link), responsibilities: property("responsibilities", link), location: location, title: title)
        end
        coy_and_link
    end
  rescue
    coy_and_link
  end

  def property(property_name, link)
    #element_index = 0 if property_name == "duties"
    #element_index = 1 if property_name == "requirement"
    if link.include? "greenhouse"
      property_value = case property_name
                         when "description" then browser.find('#content').text
                         when "requirements" then browser.all('#content > ul')[0].text
                         when "responsibilities" then browser.all('#content > ul')[1].text
                         end
    elsif link.include? "lever"
      property_value = case property_name
                         when "description" then browser.all('.content > .section-wrapper', match: :first)[1].text
                         when "requirements" then browser.all('ul.posting-requirements')[0].text
                         when "responsibilities" then browser.all('ul.posting-requirements')[1].text
                         end
    elsif link.include? "workable"
      property_value = case property_name
                         when "description" then browser.all('.section--text')[0].text.sub("Description","") + browser.all('.section--text')[1].text
                         when "requirements" then browser.all('.section--text > ul')[0].text
                         when "responsibilities" then browser.all('.section--text > ul')[1].text
                         end
    # elsif link.include? "icims"
    #   property_value = case property_name
    #                      when "description" then browser.all('.section--text')[0].text.sub("Description","") + browser.all('.section--text')[1].text
    #                      when "requirements" then browser.all('.section--text > ul')[0].text
    #                      when "responsibilities" then browser.all('.section--text > ul')[1].text
    #                      end
    elsif link.include? "jobvite"
      property_value = case property_name
                         when "description" then browser.find('div.jv-job-detail-description').text
                         when "requirements" then browser.all('div.jv-job-detail-description > ul')[1].text
                         when "responsibilities" then browser.all('div.jv-job-detail-description > ul')[0].text
                         end
    elsif link.include? "smartrecruiters"
      property_value = case property_name
                         when "description" then browser.find('section#st-companyDescription > .wysiwyg').text
                         when "requirements" then browser.find('section#st-qualifications > .wysiwyg').text
                         when "responsibilities" then  browser.find('section#st-jobDescription > .wysiwyg').text
                        end
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
    # property_value = permitted?(property_value) ? property_value : nil
    property_value
  rescue
    "Please visit the URL of this listing to get this information."
  end
end
