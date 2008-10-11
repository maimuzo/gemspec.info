require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RubygemsController do

  #Delete these examples and add some real ones
  it "should use RubygemsController" do
    controller.should be_an_instance_of(RubygemsController)
  end


  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end
  end

  describe "GET 'plus_love'" do
    it "should be successful" do
      get 'plus_love'
      response.should be_success
    end
  end

  describe "GET 'minus_love'" do
    it "should be successful" do
      get 'minus_love'
      response.should be_success
    end
  end

  describe "GET 'reset_love'" do
    it "should be successful" do
      get 'reset_love'
      response.should be_success
    end
  end
end
