class AddIndexToRunners < ActiveRecord::Migration
  def change
    add_index :runners, [:first_name, :last_name]
  end
end
