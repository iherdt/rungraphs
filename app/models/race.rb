require 'elasticsearch/model'

class Race < ActiveRecord::Base
	include Elasticsearch::Model
 	include Elasticsearch::Model::Callbacks
  
	has_many :results, inverse_of: :race, dependent: :destroy
	has_many :runners, through: :results

	settings index: { number_of_shards: 1 } do
	  mappings dynamic: 'false' do
	    indexes :name, analyzer: 'english'
	  end
	end

	def self.search(query)
	  __elasticsearch__.search(
	    {
	      query: {
	        multi_match: {
	          query: query,
	          fields: ['name^10']
	        }
	      }
	    }
	  )
	end
end
# Delete the previous races index in Elasticsearch
Race.__elasticsearch__.client.indices.delete index: Race.index_name rescue nil
 
# Create the new index with the new mapping
Race.__elasticsearch__.client.indices.create \
  index: Race.index_name,
  body: { settings: Race.settings.to_hash, mappings: Race.mappings.to_hash }
 
# Index all races records from the DB to Elasticsearch
Race.import