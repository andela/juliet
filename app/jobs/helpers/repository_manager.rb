module RepositoryManager
  def gdrive_session
    GoogleDrive.saved_session("config.json")
  end
end
