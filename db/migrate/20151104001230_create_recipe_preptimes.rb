class CreateRecipePreptimes < ActiveRecord::Migration
  def change
    create_table :recipe_preptimes do |t|
      t.integer :preptime_id, :recipe_id
      t.timestamps
    end
  end
end
