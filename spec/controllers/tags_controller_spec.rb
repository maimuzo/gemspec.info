require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TagsController do

  #Delete these examples and add some real ones
  it "should use TagsController" do
    controller.should be_an_instance_of(TagsController)
  end


  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end
end
