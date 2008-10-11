require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommentsController do

  #Delete these examples and add some real ones
  it "should use CommentsController" do
    controller.should be_an_instance_of(CommentsController)
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

  describe "GET 'add'" do
    it "should be successful" do
      get 'add'
      response.should be_success
    end
  end

  describe "GET 'create'" do
    it "should be successful" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "should be successful" do
      get 'edit'
      response.should be_success
    end
  end

  describe "GET 'update'" do
    it "should be successful" do
      get 'update'
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
