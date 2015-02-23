FactoryGirl.define do  factory :projected_result do
    
  end
  factory :projected_race do
    
  end

  factory :race do
    name "Sayville Brewery 10 Miler"
    Date Date.new(2015,1,10)
    distance 10.0
  end
  
	factory :result do
      first_name "Molly"
      last_name "Huddle"
      sex "F"
      age "29"
      bib "12"
      team "nbr"
      city "Brooklyn"
      state "NY"
      overall_place 3
      gender_place 10
      age_place 2
      net_time "60:01"
      pace_per_mile "6:00"
  end

  factory :runner do

  end

  factory :team do

	end
end