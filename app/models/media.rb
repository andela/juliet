class Media < ActiveRecord::Base
  belongs_to :user
  ALLOWED = /[\w]{5,}/
  validates :file_name, presence: true, format: { with: ALLOWED }
  validates :user, presence: true
  mount_uploader :file_name, MediaUploader
end
