class AddTeamToRunners < ActiveRecord::Migration
  def change
  	add_column :runners, :team, :string
  end
end
