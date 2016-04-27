class SaveToDriveJob
  include Sidekiq::Worker
  include RepositoryManager
  sidekiq_options queue: "default"

  def perform(path, filename)
    if gdrive_session.upload_from_file(path, filename, convert: true)
      File.delete(path)
    end
  end
end
