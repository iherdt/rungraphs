class AddFullNameToProjectedResults < ActiveRecord::Migration
  def change
    add_column :projected_results, :full_name, :string
  end
end
