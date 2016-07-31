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
            :date => race.date
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

      def get_team_race_results(team_name)
        races = []
        Race.where(:date => @start_date..@end_date).order(:date => :desc).each do |race|
          team_results = race.results.where(:team => team_name).order(:net_time)
          if team_results.length == 0
            next
          end
          race_info = {
            :name => race.name,
            :race_slug => race.slug,
            :date => race.date
          }
          results = team_results.map do |result|
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

          ag_award_results = []
          team_results.each do |result|
            if result.ag_gender_place <= 10
              ag_award_results << {
                :name => "#{result.first_name} #{result.last_name}",
                :time => result.net_time,
                :ag_place => result.ag_gender_place,
                :age => result.age,
                :gender => result.sex
              }
            end
          end

          prs = []
          first_team_race = []
          team_results.each do |result|
            runner = Runner.find(result.runner_id)
            other_results_in_distance = runner.results.where(:distance => result.distance).where("date < ?", result.date)
          if !other_results_in_distance.empty? && other_results_in_distance.all? {|other_result| !other_result.net_time.nil? && other_result.net_time > result.net_time}
              previous_best_result = other_results_in_distance.sort_by(&:net_time).first
              previous_best_race = Race.find(previous_best_result.race_id)
              prs << {
                :name => "#{result.first_name} #{result.last_name}",
                :pr_time => result.net_time,
                :old_pr_race => previous_best_race.name,
                :old_pr_date => previous_best_race.date,
                :old_pr_time => previous_best_result.net_time
              }
            end

            other_results_with_team = runner.results.where(:team => team_name).where("date < ?", result.date)
            if other_results_with_team.empty?
              first_team_race << {
                :name => "#{result.first_name} #{result.last_name}"
              }
            end
          end

          races << [race_info, results, prs, first_team_race, ag_award_results]
        end

        return races
      end
    end
  end
end