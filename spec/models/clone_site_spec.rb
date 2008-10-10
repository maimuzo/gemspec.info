require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CloneSite do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :domain => "value for domain",
      :country => "value for country"
    }
  end

  it "should create a new instance given valid attributes" do
    CloneSite.create!(@valid_attributes)
  end
end
