class AddSlugToRunners < ActiveRecord::Migration
  def change
    add_column :runners, :slug, :string
    add_index :runners, :slug, :unique => true
  end
end
