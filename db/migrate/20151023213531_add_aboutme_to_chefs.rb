class AddAboutmeToChefs < ActiveRecord::Migration
  def change
    add_column :chefs, :about_me, :string
  end
end
