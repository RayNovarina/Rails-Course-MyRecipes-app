class RecipeDiet < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :diet
end
