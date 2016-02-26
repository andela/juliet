require "./resources"

class ScrapeWorker
  include Sidekiq::Worker

  def perform
    # Company.putter
  end
end