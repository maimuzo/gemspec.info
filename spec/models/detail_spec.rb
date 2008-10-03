require File.dirname(__FILE__) + '/../spec_helper'

describe Detail do
  before(:each) do
    @detail = Detail.new
  end

  it "should be valid" do
    @detail.should be_valid
  end
end
