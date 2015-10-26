require 'rails_helper'

RSpec.describe "Races", :type => :request do

  describe "GET /races" do

    it "list race from current year" do
      Race.create!(
        :name => "fun road race",
        :date => Time.now
        )
      visit races_url
      expect(page).to have_content("fun road race")
      
    end

  end
end
