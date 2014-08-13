class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.string       :last_name
      t.string       :first_name
      t.string       :sex
      t.integer     :age
      t.integer     :bib
      t.string       :team
      t.string       :city
      t.string       :state
      t.string       :country
      t.integer     :overall_place
      t.integer     :gender_place
      t.integer     :age_place
      t.string       :net_time 
      t.string       :finish_time
      t.string       :gun_time
      t.string       :pace_per_mile 
      t.string     :ag_time 
      t.integer      :ag_gender_place
      t.float      :ag_percent
      t.boolean    :club_points, default: false
      
      t.integer     :runner_id
      t.integer     :race_id
      
      t.timestamps
    end
    
    add_index :results, :runner_id
    add_index :results, :race_id
  end
end
