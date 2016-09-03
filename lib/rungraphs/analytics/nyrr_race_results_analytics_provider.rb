module Rungraphs
  module Analytics
    class NYRRRaceResultsAnalyticsProvider
      MIN_AG_PERCENTAGE = 70

      def initialize(start_date, end_date)
        @start_date = start_date
        @end_date = end_date
      end

      def get_local_competitive_race_results
        races = []
        Race.where(:date => @start_date..@end_date).order(:date => :desc).each do |race|
          lc_results = race.results.where(:ag_percent => 70..100, :team => 0, :city => "brooklyn").order(:net_time)
          if lc_results.length == 0
            next
          end
          race_info = {
            :name => race.name,
            :race_slug => race.slug,
            :date => race.date,
            :distance => race.distance
          }
          results = lc_results.map do |result|
            {
              :name => "#{result.first_name} #{result.last_name}",
              :gender => result.sex,
              :age => result.age,
              :ag_percent => result.ag_percent,
              :net_time => result.net_time,
              :pace => result.pace_per_mile,
              :runner_slug => Runner.find(result.runner_id).slug,
              :city => result.city,
              :state => result.state,
              :country => result.country
            }
          end
          races << [race_info, results]
        end

        return races
      end

      def get_team_race_results(team_name, team_champs = false)
        races = []
        Race.where(:date => @start_date..@end_date).order(:date => :desc).each do |race|
          team_results = race.results.where(:team => team_name).order(:net_time)
          male_team_results = race.results.where(:team => team_name, :sex => 'm').order(:net_time)
          female_team_results = race.results.where(:team => team_name, :sex => 'f').order(:net_time)
          if male_team_results.length == 0 && female_team_results == 0
            next
          end
          race_info = {
            :name => race.name,
            :race_slug => race.slug,
            :date => race.date,
            :distance => race.distance
          }
          male_results = male_team_results.map do |result|
            {
              :name => "#{result.first_name} #{result.last_name}",
              :gender => result.sex,
              :age => result.age,
              :ag_percent => result.ag_percent,
              :net_time => result.net_time,
              :pace => result.pace_per_mile,
              :runner_slug => Runner.find(result.runner_id).slug,
              :city => result.city,
              :state => result.state,
              :country => result.country,
              :overall_place => result.overall_place,
              :gender_place => result.gender_place,
              :ag_gender_place => result.ag_gender_place,
              :age_place => result.age_place
            }
          end

          female_results = female_team_results.map do |result|
            {
              :name => "#{result.first_name} #{result.last_name}",
              :gender => result.sex,
              :age => result.age,
              :ag_percent => result.ag_percent,
              :net_time => result.net_time,
              :pace => result.pace_per_mile,
              :runner_slug => Runner.find(result.runner_id).slug,
              :city => result.city,
              :state => result.state,
              :country => result.country,
              :overall_place => result.overall_place,
              :gender_place => result.gender_place,
              :ag_gender_place => result.ag_gender_place,
              :age_place => result.age_place
            }
          end

          ag_award_results = []
          team_results.each do |result|
            if result.age_place <= 10
              ag_award_results << {
                :name => "#{result.first_name} #{result.last_name}",
                :time => result.net_time,
                :age_place => result.age_place,
                :age => result.age,
                :gender => result.sex
              }
            end
          end

          prs = []
          first_team_race = []
          first_race_in_distance = []
          team_results.each do |result|
            runner = Runner.find(result.runner_id)
            other_results_in_distance = runner.results.where(:distance => result.distance).where("date < ?", result.date)
            if !other_results_in_distance.empty? && other_results_in_distance.all? do |other_result|
                if other_result.net_time? && other_result.net_time > result.net_time
                  true
                elsif other_result.finish_time? && other_result.finish_time > result.net_time
                  true
                elsif other_result.gun_time? && other_result.gun_time > result.net_time
                  true
                else
                  false
                end
              end
              other_results_by_time = {}
              other_results_in_distance.each do |result|
                if result.net_time
                  other_results_by_time[result.net_time] = result
                elsif result.finish_time
                  other_results_by_time[result.finish_time] = result
                elsif result.gun_time
                  other_results_by_time[result.gun_time] = result
                else
                  next
                end
              end
              previous_best_result_array = other_results_by_time.sort.first
              previous_best_result = previous_best_result_array[1]
              previous_best_time = previous_best_result_array[0]
              previous_best_race = Race.find(previous_best_result.race_id)
              prs << {
                :name => "#{result.first_name} #{result.last_name}",
                :pr_time => result.net_time,
                :old_pr_race => previous_best_race.name,
                :old_pr_date => previous_best_race.date,
                :old_pr_time => previous_best_time
              }
            end

            other_results_with_team = runner.results.where(:team => team_name).where("date < ?", result.date)
            if other_results_with_team.empty?
              first_team_race << {
                :name => "#{result.first_name} #{result.last_name}"
              }
            end
            if other_results_in_distance.empty?
              first_race_in_distance <<  {
                :name => "#{result.first_name} #{result.last_name}"
              }
            end
          end
          team_results = {}
          team_result_types = {
            "Open Men" => race.men_results,
            "Open Women" => race.women_results,
            "40+ Men" => race.men_40_results,
            "40+ Women" => race.women_40_results,
            "50+ Men" => race.men_50_results,
            "50+ Women" => race.women_50_results,
            "60+ Men" => race.men_60_results,
            "60+ Women" => race.women_60_results
          }

          team_result_types.each do |type, results|         
            if results
              team_place = 1
              results.each do |result|
                if result["team"] == team_name
                  if type == "Open Men" || type == "Open Women"
                    if team_champs
                      number_of_scoring_runners = 10
                    else
                      number_of_scoring_runners = 5
                    end
                  else
                    if team_champs && type == "40+ Men"
                      number_of_scoring_runners = 5
                    else
                      number_of_scoring_runners = 3
                    end
                  end

                  team_results[type] = {
                    :team_place => team_place,
                    :runners => result["runners"],
                    :total_time => result["total_time"],
                    :number_of_scoring_runners => number_of_scoring_runners
                  }
                else
                  team_place += 1
                end
              end
            end
          end

          races << [race_info, male_results, female_results, prs, first_team_race, first_race_in_distance, ag_award_results, team_results]
        end

        return races
      end
    end
  end
end