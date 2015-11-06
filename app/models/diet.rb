class Diet < ActiveRecord::Base
  validates :name, presence: true, length: { minimum: 2, maximum: 25  }
  has_many :recipe_diets
  has_many :recipes, through: :recipe_diets
end
