class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.text :description
      t.integer :chef_id, :recipe_id
      t.timestamps null: false
    end
  end
end
