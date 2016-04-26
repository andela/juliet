class Media < ActiveRecord::Base
  belongs_to :user
  ALLOWED = /.{12,}/
  validates :file_name, presence: true, format: { with: ALLOWED }
  validates :user, presence: true
end
