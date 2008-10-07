class RootsController < ApplicationController
  # GET "/"
  def index
    @new_gems = Rubygem.find(:all, :order => "updated_at DESC", :limit => 5)
    @gemcasts = Gemcast.find(:all, :order => "updated_at DESC", :limit => 5)
    @unchikus = Unchiku.find(:all, :order => "updated_at DESC", :limit => 5)
  end
end
