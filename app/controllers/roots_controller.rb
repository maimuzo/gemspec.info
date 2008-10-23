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
  
  # GET "/search?keyword=key&tag=3&from=6mon&to=now"
  def search
    @title = "Search results"
    sql_base = []
    bind_base = {}
    @time_from = timing(params[:from])
    unless @time_from.nil? or @time_from[:time].nil?
      sql_base << ":from <= rubygems.updated_at"
      bind_base[:from] = @time_from[:time]
    end
    @time_to = timing(params[:to])
    unless @time_to.nil? or @time_to[:time].nil?
      sql_base << "rubygems.updated_at <= :to"
      bind_base[:to] = @time_to[:time]
    end
    unless params[:keyword].blank?
      sql_base << "rubygems.name like :keyword"
      bind_base[:keyword] = "%" + params[:keyword].strip + "%"
    end
    unless params[:tag].blank?
      sql_base << "taggings.tag_id = :tag_id"
      bind_base[:tag_id] = params[:id]
      sql_cond = {
        :joins => "LEFT JOIN taggings on rubygems.id = taggings.taggable_id AND taggings.taggable_type = 'Rubygem'",
      }
    else
      sql_cond = {}
    end
    if 0 < sql_base.size
      sql_cond[:conditions] = [sql_base.join(" AND "), bind_base]
    end
    sql_cond[:order] = "rubygems.rating_total DESC"
    unless params[:page].nil?
      sql_cond[:page] = {:size => 10, :current => params[:page]}
    else
      sql_cond[:page] = {:size => 10}
    end
    
    logger.debug sql_cond.inspect
    @gems = Rubygem.find(:all, sql_cond)
    begin
      @tag = Tag.find(params[:tag]) 
    rescue ActiveRecord::RecordNotFound => e
      @tag = nil
    end
  end
  
protected 

  def timing(param)
    time_hash = {
      "longago" => {:time => nil, :message => "大昔"},
      "1year" => {:time => 1.year.from_now, :message => "1年前"},
      "6mon" => {:time => 6.month.from_now, :message => "6ヶ月前"},
      "1mon" => {:time => 1.month.from_now, :message => "1ヶ月前"},
      "now" => {:time => nil, :message => "現在"}
    }
    time_hash.default = nil
    time_hash[param]
  end
end
