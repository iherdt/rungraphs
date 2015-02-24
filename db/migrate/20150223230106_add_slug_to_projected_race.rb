class AddSlugToProjectedRace < ActiveRecord::Migration
  def change
    add_column :projected_races, :slug, :string
    add_index :projected_races, :slug, :unique => true
  end
end
