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

    @men_results = @race.men_results
    @women_results = @race.women_results

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

  def get_race_results
    race = Race.friendly.find_by_slug!(params[:id])
    results = race.results.order('overall_place').as_json(include: :runner)

    render json: { data: results}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_race
        @race = Race.friendly.find_by_slug!(params[:id])
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


end
