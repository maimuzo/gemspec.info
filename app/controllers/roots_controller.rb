class RootsController < ApplicationController
  # GET "/"
  def index
    @title = "Index"
    @newgems = Rubygem.find(:all, :order => "created_at DESC", :limit => 5)
    @gemcasts = Gemcast.find(:all, :order => "updated_at DESC", :limit => 5)
    @unchikus = Unchiku.find(:all, :order => "updated_at DESC", :limit => 5)
    @with_gem_name = true
    
    respond_to do |format|
      format.html
    end
  end
end
