require "./resources"

class ScrapeWorker
  include Sidekiq::Worker

  def perform
     # Company.putter
    jobs = Greenhouse.new
    query = jobs.query_string
    jobs.query_gsce_greenhouse(query)
  end
end