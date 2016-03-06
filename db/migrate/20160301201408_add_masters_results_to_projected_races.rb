class AddMastersResultsToProjectedRaces < ActiveRecord::Migration
  def change
    add_column :projected_races, :men_40_results, :hstore, array: true
    add_column :projected_races, :women_40_results, :hstore, array: true
    add_column :projected_races, :men_50_results, :hstore, array: true
    add_column :projected_races, :women_50_results, :hstore, array: true
    add_column :projected_races, :men_60_results, :hstore, array: true
    add_column :projected_races, :women_60_results, :hstore, array: true
  end
end
