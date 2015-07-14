class AddTeamResultsToRaces < ActiveRecord::Migration
  def change
  	enable_extension "hstore"
  	add_column :races, :men_results, :hstore, array: true
  	add_column :races, :women_results, :hstore, array: true
  end
end
