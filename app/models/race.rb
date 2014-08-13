class Race < ActiveRecord::Base
  
  has_many :race_entries, inverse_of: :race
  has_many :runners, through: :results
end
