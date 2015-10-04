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
    draw = params[:draw]
    race_slug = params[:id]
    limit = params[:length]
    offset = params[:start]
    columns = params[:columns]
    asc_or_desc = params[:order]["0"][:dir]
    order_by_column = columns[params[:order]["0"][:column]][:data]
    searches = {
      "team" => "",
      "sex" => "",
      "full_name" => "",
      "age_range" => params[:age_range]
    }

    columns.each do |col|
      if !col[1][:search][:value].empty?
        searches[col[1][:data]] = col[1][:search][:value].strip.downcase
      end
    end

    sql_results = " SELECT results.*, runner.slug, runner.full_name"
    sql_filtered_count = " SELECT COUNT(results)"
    sql_search =
      "
        FROM projected_results as results
        LEFT JOIN runners as runner
        ON results.runner_id = runner.id
        WHERE results.projected_race_id = (
          SELECT id
          FROM projected_races
          WHERE projected_races.slug = '#{race_slug}'
        )
      "
    if !searches["full_name"].blank?
      searches["full_name"].split(' ').each do |search_term|
        sql_search += "AND runner.first_name || runner.last_name LIKE '%#{search_term}%'"
      end
    end

    if !searches["team"].blank?
      sql_search += "AND results.team LIKE '#{searches["team"]}'"
    end

    if !searches["sex"].blank?
      sql_search += "AND results.sex LIKE '#{searches["sex"]}'"
    end

    if !searches["sex"].blank?
      sql_search += "AND results.sex LIKE '#{searches["sex"]}'"
    end

    if !searches["age_range"].blank?
      min_age = searches["age_range"][0..1]
      max_age = searches["age_range"][3..4]
      sql_search += "AND results.age BETWEEN #{min_age} AND #{max_age}"
    end

    sql_filtered_count += sql_search

    sql_search +=
    " 
      ORDER BY results.#{order_by_column} #{asc_or_desc}
        LIMIT #{limit}
        OFFSET #{offset};
    "

    sql_results += sql_search

    projected_results = Result.find_by_sql(sql_results)

    filtered_results_count = ActiveRecord::Base.connection.execute(sql_filtered_count)[0]["count"]

    response = {
      draw: draw,
      recordsTotal: ProjectedRace.find_by_slug(params[:id]).projected_results.count,
      recordsFiltered: filtered_results_count,
      data: projected_results.as_json
    }

    render json: response
  end

  def get_projected_teams
    teams = ProjectedRace.find_by_slug(params[:id]).projected_results.pluck(:team).uniq.sort

    render json: teams.as_json
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
