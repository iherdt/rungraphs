class SearchController < ApplicationController
	def search
	  if params[:q].nil?
	    @races = []
	  else
	    @races = Race.search params[:q]
	  end
	end
end
