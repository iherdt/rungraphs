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
    @men_results = @projected_race.men_results
    @women_results = @projected_race.women_results

    if @men_results.count < 20
      @men_teams_to_display = @men_results.count
    else
      @men_teams_to_display = 20
    end
    if @women_results.count < 20
      @women_teams_to_display = @women_results.count
    else
      @women_teams_to_display = 20
    end
  end

  def get_projected_race_results
    projected_race = ProjectedRace.friendly.find_by_slug!(params[:id])
    projected_results = projected_race.projected_results.includes(:runner).where("projected_results.runner_id IS NOT NULL").order('net_time')

    projected_results.each_with_index do |pr, i|
      pr.overall_place = i + 1
    end
    projected_results.select{|pr| pr.sex == 'M'}.each_with_index do |pr, i|
      pr.gender_place = i + 1
    end
    projected_results.select{|pr| pr.sex == 'F'}.each_with_index do |pr, i|
      pr.gender_place = i + 1
    end

    render json: { data: projected_results.as_json(include: :runner) }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_projected_race
        @projected_race = ProjectedRace.friendly.find_by_slug!(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def projected_race_params
      params[:projected_race]
    end
end
