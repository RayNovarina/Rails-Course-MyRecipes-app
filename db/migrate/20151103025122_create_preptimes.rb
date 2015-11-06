class CreatePreptimes < ActiveRecord::Migration
  def change
    create_table :preptimes do |t|
      t.string :name
      t.timestamps
    end
  end
end
