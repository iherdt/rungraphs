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
    @projected_results = @projected_race.projected_results.order("net_time")
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
