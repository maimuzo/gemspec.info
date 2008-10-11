require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AbstractsController do

  #Delete these examples and add some real ones
  it "should use AbstractsController" do
    controller.should be_an_instance_of(AbstractsController)
  end


  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end
  end

  describe "GET 'plus_useful'" do
    it "should be successful" do
      get 'plus_useful'
      response.should be_success
    end
  end

  describe "GET 'minus_useful'" do
    it "should be successful" do
      get 'minus_useful'
      response.should be_success
    end
  end

  describe "GET 'reset_useful'" do
    it "should be successful" do
      get 'reset_useful'
      response.should be_success
    end
  end

  describe "GET 'create'" do
    it "should be successful" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'destroy'" do
    it "should be successful" do
      get 'destroy'
      response.should be_success
    end
  end
end
