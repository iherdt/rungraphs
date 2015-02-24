class ProjectedResult < ActiveRecord::Base
  belongs_to :runner, inverse_of: :results
  belongs_to :race, inverse_of: :results
end
