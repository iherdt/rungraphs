class ProjectedRacesController < ApplicationController
  before_action :set_projected_race, only: [:show, :edit, :update, :destroy]

  # GET /projected_races
  # GET /projected_races.json
  def index
    @projected_races = ProjectedRace.all.order(:date => :desc)
  end

  # GET /projected_races/1
  # GET /projected_races/1.json
  def show
    @projected_results = @projected_race.projected_results.limit(1000).includes(:runner).order("net_time")
    @projected_results.each_with_index do |pr, i|
      pr.overall_place = i + 1
    end
    @projected_results.select{|pr| pr.sex == 'M'}.each_with_index do |pr, i|
      pr.gender_place = i + 1
    end
    @projected_results.select{|pr| pr.sex == 'F'}.each_with_index do |pr, i|
      pr.gender_place = i + 1
    end

    team_scores = get_projected_team_results(@projected_results)
    @men_scores = team_scores[0]
    @women_scores = team_scores[1]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_projected_race
        @projected_race = ProjectedRace.includes(:projected_results).friendly.find_by_slug!(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def projected_race_params
      params[:projected_race]
    end

    def get_projected_team_results(projected_results)
      team_rosters = {}

      projected_results.select{|pr| pr.team != '---' && !pr.team.blank?}.each do |pr|
        net_time_date = DateTime.parse(pr.net_time)
        net_time_in_seconds = net_time_date.hour * 60 * 60 + net_time_date.min * 60 + net_time_date.sec
        net_time = "#{sprintf "%02d",(net_time_in_seconds / 3600).floor}:#{sprintf "%02d", ((net_time_in_seconds % 3600) / 60).floor}:#{sprintf "%02d", ((net_time_in_seconds % 3600) % 60).round}"

        if team_rosters.include? pr.team
          if pr.sex == 'M'
            team_rosters[pr.team]['M'] << {name: pr.full_name, net_time_in_seconds: net_time_in_seconds, net_time: net_time }
          else
            team_rosters[pr.team]['F'] << {name: pr.full_name, net_time_in_seconds: net_time_in_seconds, net_time: net_time }
          end
        else
          team_rosters[pr.team] = {'M' => [], 'F' => []}
          if pr.sex == 'M'
            team_rosters[pr.team]['M'] << {name: pr.full_name, net_time_in_seconds: net_time_in_seconds, net_time: net_time }
          else
            team_rosters[pr.team]['F'] << {name: pr.full_name, net_time_in_seconds: net_time_in_seconds, net_time: net_time }
          end
        end
      end

      male_team_scores = []
      female_team_scores = []

      team_rosters.each do |team, runners|
        runners['M'].sort_by!{ |r| r[:net_time_in_seconds] }
        if runners['M'].count > 5
          total_time_in_seconds = runners['M'].take(5).inject(0) { |total_time, runner| total_time + runner[:net_time_in_seconds] }
          total_time = "#{sprintf "%02d",(total_time_in_seconds / 3600).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) / 60).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) % 60).round}"
          male_team_scores << { team: team, total_time_in_seconds: total_time_in_seconds, total_time: total_time, runners: runners['M'].take(10) }
        end
        runners['F'].sort_by!{ |r| r[:net_time_in_seconds] }
        if runners['F'].count > 5
          total_time_in_seconds = runners['F'].take(5).inject(0) { |total_time, runner| total_time + runner[:net_time_in_seconds] }
          total_time = "#{sprintf "%02d",(total_time_in_seconds / 3600).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) / 60).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) % 60).round}"
          female_team_scores << { team: team, total_time_in_seconds: total_time_in_seconds, total_time: total_time, runners: runners['F'].take(10) }
        end
      end

      male_team_scores.sort_by!{ |team| team[:total_time_in_seconds] }
      female_team_scores.sort_by!{ |team| team[:total_time_in_seconds] }

      [male_team_scores, female_team_scores]
    end
end
