require 'elasticsearch/model'

include Elasticsearch::Model
include Elasticsearch::Model::Callbacks
 
if ENV['BONSAI_URL']
  Elasticsearch::Model.client = Elasticsearch::Client.new({url: ENV['BONSAI_URL'], logs: true})
end