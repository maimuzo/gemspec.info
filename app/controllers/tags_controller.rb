class TagsController < ApplicationController
  def show
    @tag = Tag.find(params[:id])
    #@gems = Rubygem.find_tagged_with(@tag.name)
    sql_cond = {
      :conditions => ["taggings.tag_id = :tag_id", {:tag_id => params[:id]}],
      :joins => "LEFT JOIN taggings on rubygems.id = taggings.taggable_id AND taggings.taggable_type = 'Rubygem'",
      :order => "taggings.rating_total DESC"
    }
    @gems = Rubygem.find(:all, sql_cond)
  end

end
