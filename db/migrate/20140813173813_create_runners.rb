class CreateRunners < ActiveRecord::Migration
  def change
    create_table :runners do |t|
      t.string    :first_name
      t.string    :last_name
      t.integer  :birth_year
      
      t.timestamps
    end
  end
end
