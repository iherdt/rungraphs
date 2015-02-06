class SearchController < ApplicationController
	def search
	  if params[:q].nil?
	    @races = []
	  else
	    results = Race.search params[:q]
	    races = parse_search_results(results)

	    render partial: 'races/search_race', locals: { races: races }
	  end
	end
end

private

def parse_search_results(results)
	races = []
    results.as_json.each do |result|
    	races << {name: result["fields"]["name"][0], date: result["fields"]["date"][0], id: result["fields"]["id"][0] }
    end
    races
end