class UnchikusController < ApplicationController

  # GET    /rubygems/:rubygem_id/unchikus/:id
  def show
    setup_for_spec
    @title = "unchiku for " + @gem.name
    @comment = @gem.unchikus.find(params[:id])
  end

  # GET    /rubygems/:rubygem_id/unchikus/new
  def new
    @title = "add unchiku for " + @gem.name
    @comment = @gem.unchikus.build
  end

  # POST   /rubygems/:rubygem_id/unchikus
  def create
    setup_for_spec   

    @comment = @gem.unchikus.build(params[:unchiku])
    if params[:unchiku][:url]
      @comment.url = params[:unchiku][:url]
      @comment.tried_times = 0
      @comment.foreign_content = "コンテンツ取得中...¥n(お急ぎの方は直接リンクをクリックしてください)"
      @comment.method = 'reference'
    else
      @comment.method = 'post'
    end
    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Unchiku was successfully created.'
        format.html { redirect_to(rubygem_path(@gem)) }
      else
        @title = "add unchiku for " + @gem.name + " agein"
        format.html { render :action => "new" }
      end
    end
    
  end
  
  # GET    /rubygems/:rubygem_id/unchikus/:id/edit
  def edit
  end
  
  # PUT    /rubygems/:rubygem_id/unchikus/:id
  def update
    
  end
  
  # DELETE /rubygems/:rubygem_id/unchikus/:id 
  def destroy
    
  end
  
  # POST   /rubygems/:rubygem_id/unchikus/:id/plus_useful
  def plus_useful
    
  end
  
  # POST   /rubygems/:rubygem_id/unchikus/:id/minus_useful 
  def minus_useful
    
  end
  
  # POST   /rubygems/:rubygem_id/unchikus/:id/reset_useful 
  def reset_useful
    
  end
  
  # POST   rubygems/:rubygem_id/unchiku/trackback/:user_key
  # パラメータ名	意味
  # url         記事のURL
  # blog_name	ブログ名
  # title	記事のタイトル
  # excerpt	記事の概要
  def create_trackback
    setup_for_spec   
    
    @user = User.find_by_user_key(params[:user_key])
    raise "User not found" unless 1 == @user.size
    @comment = @gem.unchikus.build
    @comment.url = params[:url]
    @comment.tried_times = 100 # TODO:
    @comment.title = params[:title]
    @comment.comment = params[:blog_name] + "からトラックバックにて登録されました。¥n詳しくはリンクをクリックし、参照元をご確認ください。"
    @comment.foreign_content = params[:excerpt]
    @comment.method = 'trackback'
    respond_to do |format|
      if @comment.save
        format.html { render :text => "OK" }
      else
        format.html { render :text => "NG" }
      end
    end
  end

protected

  def setup_for_spec
    @gem = Rubygem.find(params[:rubygem_id])
    if params[:version]
      @version = @gem.versions.find(params[:version])
    else
      @version = @gem.lastest_version
    end
    @versions_for_select = @gem.versions
    @detail = @version.find_detail_and_check_empty
    @dependencies = @version.dependencies
    @obstacles = @version.obstacles
  end
  
end
