class TeamsController < ApplicationController
	before_action :set_team, only: [:show]

  def index
  	@teams = Team.all.sort_by(&:name)
  end

  def show
    @runners = Runner.where(team: @team.name)
  end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
        @team = Team.friendly.find_by_slug!(params[:id])
    end

    def team_params
      params[:team]
    end
end
