class Race < ActiveRecord::Base
  
  has_many :results, inverse_of: :race
  has_many :runners, through: :results
end
