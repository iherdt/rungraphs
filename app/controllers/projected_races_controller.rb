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
    @projected_results = @projected_race.projected_results.includes(:runner).order("net_time")
    @projected_results.each_with_index do |pr, i|
      pr.overall_place = i + 1
    end
    @projected_results.select{|pr| pr.sex == 'M'}.each_with_index do |pr, i|
      pr.gender_place = i + 1
    end
    @projected_results.select{|pr| pr.sex == 'F'}.each_with_index do |pr, i|
      pr.gender_place = i + 1
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_projected_race
        @projected_race = ProjectedRace.includes(:projected_results).friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def projected_race_params
      params[:projected_race]
    end
end
