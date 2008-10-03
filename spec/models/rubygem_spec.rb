require File.dirname(__FILE__) + '/../spec_helper'

describe Rubygem do
  before(:each) do
    @rubygem = Rubygem.new
  end

  it "should be valid" do
    @rubygem.should be_valid
  end
end
