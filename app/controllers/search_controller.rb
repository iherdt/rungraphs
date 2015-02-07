class SearchController < ApplicationController
	def search_races
	    results = Race.search params[:q]
	    races = parse_race_results(results)

	    render partial: 'results/search_races', locals: { races: races }
	end

	def search_runners
	    results = Runner.search params[:q]
	    runners = parse_runner_results(results)
	    render partial: 'results/search_runners', locals: { runners: runners }
	end
end

private

def parse_race_results(results)
	races = []
    results.as_json.each do |result|
    	races << {name: result["fields"]["name"][0], date: result["fields"]["date"][0], id: result["fields"]["id"][0] }
    end
    races
end

def parse_runner_results(results)
	runners = []
    results.as_json.each do |result|
    	runners << {first_name: result["fields"]["first_name"][0], last_name: result["fields"]["last_name"][0], team: result["fields"]["team"][0], id: result["fields"]["id"][0] }
    end
    runners
end