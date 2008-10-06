require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do

  #Delete this example and add some real ones
  it "should use SessionsController" do
    controller.should be_an_instance_of(SessionsController)
  end
  
  it "should return arrayed symbol" do
    arrayed_hash_keys([:nickname => "nickname", :email => "email"]).should == [:nickname, :email]
  end

end
