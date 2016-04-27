class SaveToDrive
  include Sidekiq::Worker
  sidekiq_options queue: "default"

  def perform(path, filename)
    gdrive_session = GoogleDrive.saved_session("config.json")
    if gdrive_session.upload_from_file(path, filename, convert: true)
      File.delete(path)
    end
  end
end
