class AddSlugToRaces < ActiveRecord::Migration
  def change
    add_column :races, :slug, :string
    add_index :races, :slug, :unique => true
  end
end
