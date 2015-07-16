class ProjectedRace < ActiveRecord::Base
  extend FriendlyId
   friendly_id :generate_custom_slug, :use => :slugged

   has_many :projected_results, inverse_of: :race, dependent: :destroy
   has_many :runners, through: :projected_results

   def generate_custom_slug
     self.name
   end

   def set_team_results
    puts 'setting_team_results'
    team_rosters = {}

    projected_results.select{|pr| pr.team != '---' && !pr.team.blank?}.each do |pr|
      next if pr.net_time.blank?
      runner_time = pr.net_time
      net_time_date = DateTime.parse(runner_time)
      net_time_in_seconds = net_time_date.hour * 60 * 60 + net_time_date.min * 60 + net_time_date.sec
      net_time = "#{sprintf "%02d",(net_time_in_seconds / 3600).floor}:#{sprintf "%02d", ((net_time_in_seconds % 3600) / 60).floor}:#{sprintf "%02d", ((net_time_in_seconds % 3600) % 60).round}"

      if team_rosters.include? pr.team
        if pr.sex == 'M'
          team_rosters[pr.team]['m'] << {"name" => pr.full_name, "net_time_in_seconds" => net_time_in_seconds, "net_time" => net_time }
        else
          team_rosters[pr.team]['f'] << {"name" => pr.full_name, "net_time_in_seconds" => net_time_in_seconds, "net_time" => net_time }
        end
      else
        team_rosters[pr.team] = {'m' => [], 'f' => []}
        if pr.sex == 'M'
          team_rosters[pr.team]['m'] << {"name" => pr.full_name, "net_time_in_seconds" => net_time_in_seconds, "net_time" => net_time }
        else
          team_rosters[pr.team]['f'] << {"name" => pr.full_name, "net_time_in_seconds" => net_time_in_seconds, "net_time" => net_time }
        end
      end
    end

    male_team_scores = []
    female_team_scores = []

    team_rosters.each do |team, runners|
      runners['m'].sort_by!{ |r| r["net_time_in_seconds"] }
      if runners['m'].count > 5
        total_time_in_seconds = runners['m'].take(5).inject(0) { |total_time, runner| total_time + runner["net_time_in_seconds"] }
        total_time = "#{sprintf "%02d",(total_time_in_seconds / 3600).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) / 60).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) % 60).round}"
        
        runners_hash = {}

        runners['m'].take(10).each_with_index do |value, index|
        	runners_hash[index.to_s] = value
        end

        male_team_scores << { team: team, total_time_in_seconds: total_time_in_seconds, total_time: total_time, runners: runners_hash }
      end
      runners['f'].sort_by!{ |r| r["net_time_in_seconds"] }
      if runners['f'].count > 5
        total_time_in_seconds = runners['f'].take(5).inject(0) { |total_time, runner| total_time + runner["net_time_in_seconds"] }
        total_time = "#{sprintf "%02d",(total_time_in_seconds / 3600).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) / 60).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) % 60).round}"
        
        runners_hash = {}

        runners['f'].take(10).each_with_index do |value, index|
        	runners_hash[index.to_s] = value
        end

        female_team_scores << { team: team, total_time_in_seconds: total_time_in_seconds, total_time: total_time, runners: runners_hash }
      end
    end

    male_team_scores.sort_by!{ |team| team[:total_time_in_seconds] }
    female_team_scores.sort_by!{ |team| team[:total_time_in_seconds] }

    self.men_results = male_team_scores
    self.women_results = female_team_scores

    self.save!
  end
end
