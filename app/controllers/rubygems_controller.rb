class RubygemsController < ApplicationController

=begin

          destroy_tag_rubygem POST   /rubygems/:id/destroy_tag         {:controller=>"rubygems", :action=>"destroy_tag"}
formatted_destroy_tag_rubygem POST   /rubygems/:id/destroy_tag.:format {:controller=>"rubygems", :action=>"destroy_tag"}
            plus_love_rubygem POST   /rubygems/:id/plus_love           {:controller=>"rubygems", :action=>"plus_love"}
  formatted_plus_love_rubygem POST   /rubygems/:id/plus_love.:format   {:controller=>"rubygems", :action=>"plus_love"}
           minus_love_rubygem POST   /rubygems/:id/minus_love          {:controller=>"rubygems", :action=>"minus_love"}
 formatted_minus_love_rubygem POST   /rubygems/:id/minus_love.:format  {:controller=>"rubygems", :action=>"minus_love"}
           create_tag_rubygem POST   /rubygems/:id/create_tag          {:controller=>"rubygems", :action=>"create_tag"}
 formatted_create_tag_rubygem POST   /rubygems/:id/create_tag.:format  {:controller=>"rubygems", :action=>"create_tag"}
           reset_love_rubygem POST   /rubygems/:id/reset_love          {:controller=>"rubygems", :action=>"reset_love"}
 formatted_reset_love_rubygem POST   /rubygems/:id/reset_love.:format  {:controller=>"rubygems", :action=>"reset_love"}
                 edit_rubygem GET    /rubygems/:id/edit                {:controller=>"rubygems", :action=>"edit"}
       formatted_edit_rubygem GET    /rubygems/:id/edit.:format        {:controller=>"rubygems", :action=>"edit"}
              new_tag_rubygem GET    /rubygems/:id/new_tag             {:controller=>"rubygems", :action=>"new_tag"}
    formatted_new_tag_rubygem GET    /rubygems/:id/new_tag.:format     {:controller=>"rubygems", :action=>"new_tag"}
                      rubygem GET    /rubygems/:id                     {:controller=>"rubygems", :action=>"show"}
            formatted_rubygem GET    /rubygems/:id.:format             {:controller=>"rubygems", :action=>"show"}

=end

  # GET    /rubygems/:id
  def show
    @gem = Rubygem.find(params[:id])
    @title = @gem.name
    if params[:version]
      @version = @gem.versions.find(params[:version])
    else
      @version = @gem.lastest_version
    end
    @versions_for_select = @gem.versions
    @detail = @version.find_detail_and_check_empty
    @dependencies = @version.dependencies
    @obstacles = @version.obstacles
    respond_to do |format|
      format.html
    end
  end

  # POST   /rubygems/:id/plus_love
  def plus_love
    @gem = Rubygem.find(params[:id])
    @gem.rate(1, current_user)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "愛がまた1つ加わりました"
        redirect_to(rubygem_path(@gem))
      end
    end
  end

  # POST   /rubygems/:id/minus_love
  def minus_love
    @gem = Rubygem.find(params[:id])
    @gem.rate(-1, current_user)

    respond_to do |format|
      format.html do
        flash[:notice] = "愛が憎悪に変わりました"
        redirect_to(rubygem_path(@gem))
      end
    end
  end

  # POST   /rubygems/:id/reset_love
  def reset_love
    @gem = Rubygem.find(params[:id])
    @gem.unrate(current_user)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "愛が冷めました"
        redirect_to(rubygem_path(@gem))
      end
    end
  end
  
  # GET    /rubygems/:id/new_tag
  def new_tag
    @gem = Rubygem.find(params[:id])
    @title = "add tag for " + @gem.name
    if params[:version]
      @version = @gem.versions.find(params[:version])
    else
      @version = @gem.lastest_version
    end
    @versions_for_select = @gem.versions
    @detail = @version.find_detail_and_check_empty
    @dependencies = @version.dependencies
    @obstacles = @version.obstacles
    respond_to do |format|
      format.html
    end
  end
  
  # POST   /rubygems/:id/create_tag
  def create_tag
    @gem = Rubygem.find(params[:id])
    @title = "add tag for " + @gem.name
    if params[:version]
      @version = @gem.versions.find(params[:version])
    else
      @version = @gem.lastest_version
    end
    @versions_for_select = @gem.versions
    @detail = @version.find_detail_and_check_empty
    @dependencies = @version.dependencies
    @obstacles = @version.obstacles
    
    respond_to do |format|
#      new_tag = Tag.new(params[:tag])
#      unless new_tag.valid and new_tag.name.include?(" ")
#        format.html { redirect_to(new_tag_rubygem_path(@gem)) }
#        return
#      end
      @gem.user_id = current_user.id
      @gem.tag_list = @gem.tag_list + ", " + params[:tag][:name]
      if @gem.save
        flash[:notice] = 'Tag was successfully added.'
        format.html { redirect_to(rubygem_path(@gem)) }
      else
        format.html { redirect_to(new_tag_rubygem_path(@gem)) }
      end
    end
    
  end
  
  # POST   /rubygems/:id/destroy_tag
  def destroy_tag
    
  end

  # POST   /rubygems/:id/create_favorit
  def create_favorit
    @gem = Rubygem.find(params[:id])
    current_user.has_favorite(@gem)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "#{@gem.name}をお気に入りに追加しました。Mypageから参照可能です"
        redirect_to(rubygem_path(@gem))
      end
    end
  end
  
end
