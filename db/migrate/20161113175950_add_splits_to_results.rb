class AddSplitsToResults < ActiveRecord::Migration
  def change
    add_column :results, :split_5km, :string
    add_column :results, :split_10km, :string
    add_column :results, :split_15km, :string
    add_column :results, :split_20km, :string
    add_column :results, :split_25km, :string
    add_column :results, :split_30km, :string
    add_column :results, :split_40km, :string
    add_column :results, :split_131m, :string
  end
end