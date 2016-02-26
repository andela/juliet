require "./resources"

set :output, "cron_log.log"

every 1.minutes do
  rake "action:search"
  # runner "ScrapeWorker.perform_async"
  # command "ruby 'company.rb'"
  # command "ruby 'greenhouse.rb'"
  end
