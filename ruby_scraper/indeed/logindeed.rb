require 'mechanize'
require 'uri'

def navigate_to_login(start_url)
  agent = Mechanize.new
  agent.get(URI(start_url))
  signin_page = agent.page.link_with(text: 'Sign in').click

  my_page = signin_page.form_with(name: 'loginform') do |form|
    form.email = 'developers@andela.com'
    form.password = 'sy3sYB9i7sMR'
    form.checkbox_with(name: 'remember').check
  end.submit

  # require 'pry' ; binding.pry
  my_page.link_with(text: /Apply Now/).click
end



# [['', 'fff', 'fff.com', '', 'ddd', 'ddd.com']]
