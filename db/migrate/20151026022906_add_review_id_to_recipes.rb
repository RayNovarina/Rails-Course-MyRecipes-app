class AddReviewIdToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :review_id, :integer

  end
end
