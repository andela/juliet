class User < ActiveRecord::Base
  mount_uploader :attachement, AttachmentUploader
  ALLOWED = /[A-z]{2,50}/
  VALID_EMAIL = /[\w\-\.]+@[A-z]+.[A-z]{2,8}/
  validates :name, presence: true, format: { with: ALLOWED }
  validates :email, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false }, format: { with: VALID_EMAIL }
end
