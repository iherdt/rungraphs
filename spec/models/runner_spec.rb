require 'rails_helper'

RSpec.describe Runner, :type => :model do

  describe "associations" do
    it { should have_many(:results)}
    it { should have_have(:races)}
  end

  it "has no required attributes" do
    FactoryGirl.build(:runner).should be_valid
  end
end
