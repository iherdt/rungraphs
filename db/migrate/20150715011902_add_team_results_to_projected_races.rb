class AddTeamResultsToProjectedRaces < ActiveRecord::Migration
  def change
  	add_column :projected_races, :men_results, :hstore, array: true
  	add_column :projected_races, :women_results, :hstore, array: true
  end
end
