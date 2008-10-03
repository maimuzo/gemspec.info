require File.dirname(__FILE__) + '/../spec_helper'

describe Dependency do
  before(:each) do
    @dependency = Dependency.new
  end

  it "should be valid" do
    @dependency.should be_valid
  end
end
