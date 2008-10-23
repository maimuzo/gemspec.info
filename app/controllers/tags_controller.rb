class TagsController < ApplicationController
  before_filter :block_until_authorized, :except => [:show]

  # GET    /tags/:id
  def show
    @tag = Tag.find(params[:id])
    sql_cond = {
      :conditions => ["taggings.tag_id = :tag_id", {:tag_id => params[:id]}],
      :joins => "LEFT JOIN taggings on rubygems.id = taggings.taggable_id AND taggings.taggable_type = 'Rubygem'",
      :order => "taggings.rating_total DESC"
    }
    @gems = Rubygem.find(:all, sql_cond)
    @gems.each do |gem| gem.setup_tagging_for(params[:id]) end
    @with_tag_rate = true
  end

  # plus_useful_tag POST   /tags/:id/plus_useful/:rubygem_id
  def plus_useful
    @gem = Rubygem.find(params[:rubygem_id])
    tagging = @gem.setup_tagging_for(params[:id])
    raise("tagging is not found") if tagging.nil?
    tagging.rate(1, current_user)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "＋評価しました"
        redirect_to(tag_path(params[:id]))
      end
    end
  end
  
  # minus_useful_tag POST   /tags/:id/minus_useful/:rubygem_id
  def minus_useful
    @gem = Rubygem.find(params[:rubygem_id])
    tagging = @gem.setup_tagging_for(params[:id])
    raise("tagging is not found") if tagging.nil?
    tagging.rate(-1, current_user)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "−評価しました"
        redirect_to(tag_path(params[:id]))
      end
    end
  end
  
  # reset_useful_tag POST   /tags/:id/reset_useful/:rubygem_id 
  def reset_useful
    @gem = Rubygem.find(params[:rubygem_id])
    tagging = @gem.setup_tagging_for(params[:id])
    raise("tagging is not found") if tagging.nil?
    tagging.unrate(current_user)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "評価を取り消しました"
        redirect_to(tag_path(params[:id]))
      end
    end
  end
  
end
