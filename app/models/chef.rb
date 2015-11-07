class Chef < ActiveRecord::Base
  has_many :recipes
  has_many :likes
  has_many :reviews
  #has_many :reviews, as: :reviewable
  
  before_save { self.email = self.email.downcase}
  validates :name,  presence: true, length: { minimum: 3, maximum: 40 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-,]+\.[a-z]+\z/i
  validates :email, presence: true, length: { minimum: 3, maximum: 100 },
                                    uniqueness: { case_sensitive: false },
                                    format: { with: VALID_EMAIL_REGEX }
  has_secure_password

  # CLASS and Instance methods that extend the Chef ActiveRecord class via /models/concerns files.
  
    # Our extensions to add useful helper routines and to put biz logic in the model and not in controllers.
    include ChefExtensions   # /models/concerns/chef_extensions.rb
    
    # Authenication gem extensions:
    # include AuthenticationGemExtensions
  
end