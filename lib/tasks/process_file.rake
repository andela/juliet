desc "Process files that are uploaded. Prune and make company URL search"
task process_files: :environment do
  puts "Start file processing"
  UrlMatcherJob.perform_async
  puts "Done."
end
