class RacesController < ApplicationController
  before_action :set_race, only: [:show, :edit, :update, :destroy]

  # GET /races
  # GET /races.json
  def index
    @races = Race.all.order(:date => :desc)
  end

  # GET /races/1
  # GET /races/1.json
  def show
    @race_time_array = get_race_time_title_and_type(@race)
    @results = @race.results.limit(3000).includes(:runner).order('overall_place')

    team_scores = get_projected_team_results(@results)
    @men_scores = team_scores[0]
    @women_scores = team_scores[1]

    if @men_scores.count < 20
      @men_teams_to_display = @men_scores.count
    else
      @men_teams_to_display = 20
    end
    if @women_scores.count < 20
      @women_teams_to_display = @women_scores.count
    else
      @women_teams_to_display = 20
    end
  end

  # GET /races/new
  def new
    @race = Race.new
  end

  # GET /races/1/edit
  def edit
  end

  # POST /races
  # POST /races.json
  def create
    @race = Race.new(race_params)

    respond_to do |format|
      if @race.save
        format.html { redirect_to @race, notice: 'Race was successfully created.' }
        format.json { render :show, status: :created, location: @race }
      else
        format.html { render :new }
        format.json { render json: @race.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /races/1
  # PATCH/PUT /races/1.json
  def update
    respond_to do |format|
      if @race.update(race_params)
        format.html { redirect_to @race, notice: 'Race was successfully updated.' }
        format.json { render :show, status: :ok, location: @race }
      else
        format.html { render :edit }
        format.json { render json: @race.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /races/1
  # DELETE /races/1.json
  def destroy
    @race.destroy
    respond_to do |format|
      format.html { redirect_to races_url, notice: 'Race was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_race
        @race = Race.includes(:results).friendly.find_by_slug!(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def race_params
      params[:race]
    end

    def get_race_time_title_and_type(race)
      if race.results.first.net_time
        ["Net Time", "net_time"]
      elsif race.results.first.finish_time
        ["Finish Time", "finish_time"]
      else
        ["Gun Time", "gun_time"]
      end
    end

    def get_projected_team_results(projected_results)
      team_rosters = {}

      projected_results.select{|pr| pr.team != '---' && !pr.team.blank?}.each do |pr|
        net_time_date = DateTime.parse(pr.net_time)
        net_time_in_seconds = net_time_date.hour * 60 * 60 + net_time_date.min * 60 + net_time_date.sec
        net_time = "#{sprintf "%02d",(net_time_in_seconds / 3600).floor}:#{sprintf "%02d", ((net_time_in_seconds % 3600) / 60).floor}:#{sprintf "%02d", ((net_time_in_seconds % 3600) % 60).round}"

        if team_rosters.include? pr.team
          if pr.sex == 'm'
            team_rosters[pr.team]['m'] << {name: pr.full_name, net_time_in_seconds: net_time_in_seconds, net_time: net_time }
          else
            team_rosters[pr.team]['f'] << {name: pr.full_name, net_time_in_seconds: net_time_in_seconds, net_time: net_time }
          end
        else
          team_rosters[pr.team] = {'m' => [], 'f' => []}
          if pr.sex == 'm'
            team_rosters[pr.team]['m'] << {name: pr.full_name, net_time_in_seconds: net_time_in_seconds, net_time: net_time }
          else
            team_rosters[pr.team]['f'] << {name: pr.full_name, net_time_in_seconds: net_time_in_seconds, net_time: net_time }
          end
        end
      end

      male_team_scores = []
      female_team_scores = []

      team_rosters.each do |team, runners|
        runners['m'].sort_by!{ |r| r[:net_time_in_seconds] }
        if runners['m'].count > 5
          total_time_in_seconds = runners['m'].take(5).inject(0) { |total_time, runner| total_time + runner[:net_time_in_seconds] }
          total_time = "#{sprintf "%02d",(total_time_in_seconds / 3600).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) / 60).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) % 60).round}"
          male_team_scores << { team: team, total_time_in_seconds: total_time_in_seconds, total_time: total_time, runners: runners['m'].take(10) }
        end
        runners['f'].sort_by!{ |r| r[:net_time_in_seconds] }
        if runners['f'].count > 5
          total_time_in_seconds = runners['f'].take(5).inject(0) { |total_time, runner| total_time + runner[:net_time_in_seconds] }
          total_time = "#{sprintf "%02d",(total_time_in_seconds / 3600).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) / 60).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) % 60).round}"
          female_team_scores << { team: team, total_time_in_seconds: total_time_in_seconds, total_time: total_time, runners: runners['f'].take(10) }
        end
      end

      male_team_scores.sort_by!{ |team| team[:total_time_in_seconds] }
      female_team_scores.sort_by!{ |team| team[:total_time_in_seconds] }

      [male_team_scores, female_team_scores]
    end
end
