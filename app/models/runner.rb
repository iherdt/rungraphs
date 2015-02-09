require 'elasticsearch/model'

class Runner < ActiveRecord::Base
	include Elasticsearch::Model
 	include Elasticsearch::Model::Callbacks
 	extend FriendlyId
  friendly_id :generate_custom_slug, :use => :slugged
  
  has_many :results, inverse_of: :runner
  has_many :races, through: :results

  settings index: {
		number_of_shards: 1
		},
		analysis: {
			filter: {
			    autocomplete_filter: {
			      type: "edge_ngram",
			      min_gram: 3,
			      max_gram: 4
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
	          fields: ['first_name', 'last_name', 'team']
	        }
	      },
	      fields: ['first_name', 'last_name', 'team', 'id', 'slug']
	    }
	  )
	end

	def generate_custom_slug
    "#{self.first_name} #{self.last_name}"
  end
end

# Delete the previous runners index in Elasticsearch
Runner.__elasticsearch__.client.indices.delete index: Runner.index_name rescue nil
 
# Create the new index with the new mapping
Runner.__elasticsearch__.client.indices.create \
  index: Runner.index_name,
  body: { settings: Runner.settings.to_hash, mappings: Runner.mappings.to_hash }
 
# Index all races records from the DB to Elasticsearch
Runner.import
