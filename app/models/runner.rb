class Runner < ActiveRecord::Base
  
  has_many :results, inverse_of: :runner
  has_many :races, through: :results
end
