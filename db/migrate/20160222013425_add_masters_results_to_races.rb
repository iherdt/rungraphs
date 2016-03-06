class AddMastersResultsToRaces < ActiveRecord::Migration
  def change
    add_column :races, :men_40_results, :hstore, array: true
    add_column :races, :women_40_results, :hstore, array: true
    add_column :races, :men_50_results, :hstore, array: true
    add_column :races, :women_50_results, :hstore, array: true
    add_column :races, :men_60_results, :hstore, array: true
    add_column :races, :women_60_results, :hstore, array: true
  end
end
