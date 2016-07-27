require 'elasticsearch/model'

class Race < ActiveRecord::Base
	include Elasticsearch::Model
 	include Elasticsearch::Model::Callbacks
 	extend FriendlyId
  friendly_id :generate_custom_slug, :use => :slugged

	has_many :results, inverse_of: :race, dependent: :destroy
	has_many :runners, through: :results

	settings index: {
		number_of_shards: 1
		},
		analysis: {
			filter: {
			    autocomplete_filter: {
			      type: "edge_ngram",
			      min_gram: 6,
			      max_gram: 7
		    	}
			},
			analyzer: {
		    autocomplete: {
		      tokenizer: "lowercase",
		      filter: ["lowercase", "autocomplete_filter"],
		      type: "custom"
		    }
		  }
	  }	do
	  mappings dynamic: 'true' do
	    indexes :name, analyzer: 'autocomplete'
	  end

	end

	def self.search(query)
	  __elasticsearch__.search(
	    {
	      query: {
	        multi_match: {
	          query: query,
	          fields: ['name']
	        }
	      },
	      fields: ['name', 'id', 'date', 'slug']
	    }
	  )
	end

	def generate_custom_slug
    "#{self.name} #{self.date.year}"
  end

  def set_team_results(team_champs = false)
    puts 'setting_team_results'
    categories = ["open", "40", "50", "60"]

    categories.each do |category|
      if category == "open"
        scoring_results = results
        if team_champs
          scoring_count = 5
        else
          scoring_count = 5
        end
      else
        scoring_results = results.includes(:runner).where("age >= ?", category)
        if team_champs
          scoring_count = 5
        else         
          scoring_count = 3
        end
      end

      team_rosters = {}

      scoring_results.select{|pr| pr.team != '---' && !pr.team.blank?}.each do |pr|
        next if pr.team.blank? || pr.team == "0"

        if !pr.net_time.blank?
          runner_time = pr.net_time
        elsif !pr.finish_time.blank?
          runner_time = pr.finish_time
        else
          runner_time = pr.gun_time
        end

        if runner_time =~ /^\d\d:\d\d$/
          runner_time = "0:" + runner_time
        end

        next if (runner_time =~ /^(\d+:)?\d+:\d+$/).nil?

        net_time_date = DateTime.parse(runner_time)
        net_time_in_seconds = net_time_date.hour * 60 * 60 + net_time_date.min * 60 + net_time_date.sec
        net_time = "#{sprintf "%02d",(net_time_in_seconds / 3600).floor}:#{sprintf "%02d", ((net_time_in_seconds % 3600) / 60).floor}:#{sprintf "%02d", ((net_time_in_seconds % 3600) % 60).round}"

        if team_rosters.include? pr.team
          if pr.sex == 'm'
            team_rosters[pr.team]['m'] << {"name" => pr.full_name, "net_time_in_seconds" => net_time_in_seconds, "net_time" => net_time, "slug" => pr.runner.slug }
          else
            team_rosters[pr.team]['f'] << {"name" => pr.full_name, "net_time_in_seconds" => net_time_in_seconds, "net_time" => net_time, "slug" => pr.runner.slug }
          end
        else
          team_rosters[pr.team] = {'m' => [], 'f' => []}
          if pr.sex == 'm'
            team_rosters[pr.team]['m'] << {"name" => pr.full_name, "net_time_in_seconds" => net_time_in_seconds, "net_time" => net_time, "slug" => pr.runner.slug }
          else
            team_rosters[pr.team]['f'] << {"name" => pr.full_name, "net_time_in_seconds" => net_time_in_seconds, "net_time" => net_time, "slug" => pr.runner.slug }
          end
        end
      end

      male_team_scores = []
      female_team_scores = []

      team_rosters.each do |team, runners|
        runners['m'].sort_by!{ |r| r["net_time_in_seconds"] }
        if runners['m'].count > scoring_count
          total_time_in_seconds = runners['m'].take(scoring_count).inject(0) { |total_time, runner| total_time + runner["net_time_in_seconds"] }
          total_time = "#{sprintf "%02d",(total_time_in_seconds / 3600).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) / 60).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) % 60).round}"
          
          runners_hash = {}

          runners['m'].take(scoring_count*2).each_with_index do |value, index|
          	runners_hash[index.to_s] = value
          end

          male_team_scores << { team: team, total_time_in_seconds: total_time_in_seconds, total_time: total_time, runners: runners_hash }
        end
        runners['f'].sort_by!{ |r| r["net_time_in_seconds"] }
        if runners['f'].count > scoring_count
          total_time_in_seconds = runners['f'].take(scoring_count).inject(0) { |total_time, runner| total_time + runner["net_time_in_seconds"] }
          total_time = "#{sprintf "%02d",(total_time_in_seconds / 3600).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) / 60).floor}:#{sprintf "%02d", ((total_time_in_seconds % 3600) % 60).round}"
          
          runners_hash = {}

          runners['f'].take(scoring_count*2).each_with_index do |value, index|
          	runners_hash[index.to_s] = value
          end

          female_team_scores << { team: team, total_time_in_seconds: total_time_in_seconds, total_time: total_time, runners: runners_hash }
        end
      end

      male_team_scores.sort_by!{ |team| team[:total_time_in_seconds] }
      female_team_scores.sort_by!{ |team| team[:total_time_in_seconds] }

      case category
      when "40"
        self.men_40_results = male_team_scores
        self.women_40_results = female_team_scores
      when "50"
        self.men_50_results = male_team_scores
        self.women_50_results = female_team_scores
      when "60"
        self.men_60_results = male_team_scores
        self.women_60_results = female_team_scores
      when "open"
        self.men_results = male_team_scores
        self.women_results = female_team_scores
      end
    end
    self.save!
  end
end
