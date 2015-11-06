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
   
  # how many up or down votes have a chef's recipes received.
  def chef_recipes_likes(chef, type)
    options = { obj_chef: chef, b_thumbs_up_total: type == "up", b_thumbs_down_total: type =="down", b_forRecipes: true }
    results = model_likes(options)
    return (type == "up") ? results[:totals][:thumbs_up_total]: results[:totals][:thumbs_down_total]
    
  end
  
end