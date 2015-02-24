class Result < ActiveRecord::Base

  belongs_to :runner, inverse_of: :results
  belongs_to :race, inverse_of: :results

  def date
    self.race.date
  end

  def distance
    self.race.distance
  end

end
