require File.dirname(__FILE__) + '/../spec_helper'

describe Spec do
  before(:each) do
    @spec = Spec.new
  end

  it "should be valid" do
    @spec.should be_valid
  end
end
