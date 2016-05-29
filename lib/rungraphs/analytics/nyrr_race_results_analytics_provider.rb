module Rungraphs
  module Analytics
    class NYRRRaceResultsAnalyticsProvider
      MIN_AG_PERCENTAGE = 70

      def initialize
        @end_date = Time.now.at_midnight
        @start_date = @end_date - 1.week
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
    end
  end
end