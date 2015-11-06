class CreateRecipeDiets < ActiveRecord::Migration
  def change
    create_table :recipe_diets do |t|
      t.integer :diet_id, :recipe_id
      t.timestamps null: false
    end
  end
end
