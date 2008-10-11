require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/rubygems/reset_love" do
  before(:each) do
    render 'rubygems/reset_love'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/rubygems/reset_love])
  end
end
