class UrlMatcherJob
  include Sidekiq::Worker
  sidekiq_options queue: "matcher"

  def perform
    Pruner.new.get_remote_file
  end
end
