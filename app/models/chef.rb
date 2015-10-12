class Chef < ActiveRecord::Base
  has_many :recipes
  has_many :likes
  
  before_save { self.email = self.email.downcase}
  validates :name,  presence: true, length: { minimum: 3, maximum: 40 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-,]+\.[a-z]+\z/i
  validates :email, presence: true, length: { minimum: 3, maximum: 100 },
                                    uniqueness: { case_sensitive: false },
                                    format: { with: VALID_EMAIL_REGEX }
end