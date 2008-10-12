require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UnchikusController do

  #Delete these examples and add some real ones
  it "should use UnchikusController" do
    controller.should be_an_instance_of(UnchikusController)
  end


  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "should be successful" do
      get 'edit'
      response.should be_success
    end
  end
end
