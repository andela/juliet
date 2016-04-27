class User < ActiveRecord::Base
  has_many :medias, dependent: :destroy
  ALLOWED = /[A-z\s]{2,50}/
  VALID_EMAIL = /([\w\-\.]{2,})@([\w]{2,}).[A-z]{2,8}/
  validates :name, presence: true, format: { with: ALLOWED }
  validates :email, presence: true, length: { maximum: 255 },
                    uniqueness: { case_sensitive: false },
                    format: { with: VALID_EMAIL }

  before_save :downcase_fields

  def downcase_fields
    name.downcase!
    email.downcase!
  end
end
