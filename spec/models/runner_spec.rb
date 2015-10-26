require 'rails_helper'

RSpec.describe Runner, :type => :model do

	before(:each) do
		@runner = Runner.new(
			first_name: "Logan",
			last_name: "Yu",
			birth_year: 1985	
		)
	end

  describe ".search" do
  	it "should return the runner that is searched for" do
  		search_result_name = Runner.search('logan yu')[0].as_json["fields"]["full_name"][0]
  		search_result_name.should eq("logan yu")
  	end
  end

  describe "#full_name" do
		it "should return the full name" do
  		expect(@runner.full_name).to eq("Logan Yu")
  	end
  end
end
