class AddFullNameAndHomeTownToRunners < ActiveRecord::Migration
  def change
    add_column :runners, :full_name, :string
    add_column :runners, :city, :string
    add_column :runners, :state, :string
    add_column :runners, :country, :string
  end
end
