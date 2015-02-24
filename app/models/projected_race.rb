class ProjectedRace < ActiveRecord::Base
  extend FriendlyId
   friendly_id :generate_custom_slug, :use => :slugged

   has_many :projected_results, inverse_of: :race, dependent: :destroy
   has_many :runners, through: :projected_results

   def generate_custom_slug
     self.name
   end
end
