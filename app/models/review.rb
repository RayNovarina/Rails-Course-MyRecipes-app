class Review < ActiveRecord::Base
  belongs_to :chef  
  belongs_to :recipe
  #has_one :recipe, as: :recipe_review
  
  #belongs_to :reviewable, polymorphic: true
  
  #validates_uniqueness_of :chef, scope: :recipe
  
  validates :description, presence: true, length: { minimum: 3, maximum: 5000 }
  

end
