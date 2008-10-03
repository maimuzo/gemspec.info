require File.dirname(__FILE__) + '/../spec_helper'

describe GeneralPoint do
  before(:each) do
    @general_point = GeneralPoint.new
  end

  it "should be valid" do
    @general_point.should be_valid
  end
end
