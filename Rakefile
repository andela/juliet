namespace :action do
  task default: %w[search]

  desc "Run the script than initiates the search"
  task :search do
    # ruby "greenhouse.rb"
    ScrapeWorker.perform_async
  end
end