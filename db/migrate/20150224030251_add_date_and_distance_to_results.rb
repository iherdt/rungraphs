class AddDateAndDistanceToResults < ActiveRecord::Migration
  def change
    add_column :results, :date, :date
    add_column :results, :distance, :float
  end
end
