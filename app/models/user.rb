class User < ActiveRecord::Base
  has_many :medias
  ALLOWED = /[A-z]{2,50}/
  VALID_EMAIL = /[\w\-\.]+@[\w]+.[A-z]{2,8}/
  validates :name, presence: true, format: { with: ALLOWED }
  validates :email, presence: true, length: { maximum: 255 },
            uniqueness: { case_sensitive: false }, format: { with: VALID_EMAIL }
end
