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
			      min_gram: 1,
			      max_gram: 20
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

end
