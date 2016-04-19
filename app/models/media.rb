class Media < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true
  mount_uploader :file_name, MediaUploader
end
