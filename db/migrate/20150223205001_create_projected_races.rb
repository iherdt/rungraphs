class CreateProjectedRaces < ActiveRecord::Migration
  def change
    create_table :projected_races do |t|
      t.string    :name
      t.date      :date
      t.float     :distance
      t.integer   :temperature
      t.integer   :humidity
      t.string    :date_and_time
      t.string    :location
      t.string    :weather
      t.string    :sponsor
      t.boolean   :club_points, default: false
      
      t.timestamps
    end
  end
end
