class UnchikusController < ApplicationController
  before_filter :block_until_authorized, :except => [:show, :create_trackback]
  protect_from_forgery :except => :create_trackback

  # GET    /rubygems/:rubygem_id/unchikus/:id
  def show
    setup_for_spec(params[:rubygem_id])
    @title = "unchiku for " + @gem.name
    @comment = @gem.unchikus.find(params[:id])
  end

  # GET    /rubygems/:rubygem_id/unchikus/new
  def new
    setup_for_spec(params[:rubygem_id])
    @title = "add unchiku for " + @gem.name
    @comment = Unchiku.new
  end

  # POST   /rubygems/:rubygem_id/unchikus
  def create
    setup_for_spec(params[:rubygem_id])   
    @comment = @gem.unchikus.build(params[:unchiku])
    @comment.user_id = current_user.id
    if params[:unchiku].blank? or params[:unchiku][:url].blank?
      @comment.method = 'posted'
    else
      @comment.url = params[:unchiku][:url]
      @comment.tried_times = 0
      @comment.foreign_content = "コンテンツ取得中...\n(お急ぎの方は直接リンクをクリックしてください)"
      @comment.method = 'referenced'
    end
    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Unchiku was successfully created.'
        format.html { redirect_to(rubygem_path(@gem)) }
      else
        @title = "add unchiku for agein " + @gem.name
        format.html { render :action => "new" }
      end
    end
  end
  
  # GET    /rubygems/:rubygem_id/unchikus/:id/edit
  def edit
    setup_for_spec(params[:rubygem_id])
    @title = "Edit unchiku for " + @gem.name
    @comment = @gem.unchikus.find_by_id_and_user_id(params[:id], current_user.id)
    raise "User id is not match" if @comment.nil?
  end
  
  # PUT    /rubygems/:rubygem_id/unchikus/:id
  def update
    setup_for_spec(params[:rubygem_id])   
    @comment = @gem.unchikus.find_by_id_and_user_id(params[:id], current_user.id)
    raise "User id is not match" if @comment.nil?
    begin
      @comment.user_id = current_user.id
      if @comment.method == 'posted'
        raise "Can not change post type" unless params[:unchiku][:url].blank?
      elsif @comment.method == 'referenced'
        raise "Can not change reference type" if params[:unchiku][:url].blank?
        @comment.url = params[:unchiku][:url]
        @comment.tried_times = 0
        @comment.foreign_content = "コンテンツ取得中...\n(お急ぎの方は直接リンクをクリックしてください)"        
      end
      respond_to do |format|
        if @comment.update_attributes(params[:unchiku])
          flash[:notice] = 'Unchiku was successfully updated.'
          format.html { redirect_to(rubygem_path(@gem)) }
        else
          @title = "edit unchiku for agein " + @gem.name
          format.html { render :action => "edit" }
        end
      end
    rescue => e
      flash[:error] += e.to_s
      @title = "Edit unchiku agein for " + @gem.name
      format.html { render :action => "edit" }
    end
  end
  
  # DELETE /rubygems/:rubygem_id/unchikus/:id 
  def destroy
    @gem = Rubygem.find(params[:rubygem_id])
    @comment = @gem.unchikus.find_by_id_and_user_id(params[:id], current_user.id)
    errors.add_to_base("User id is not match") if @comment.nil?
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to(rubygem_path(@gem)) }
    end
  end
  
  # POST   /rubygems/:rubygem_id/unchikus/:id/plus_useful
  def plus_useful
    @gem = Rubygem.find(params[:rubygem_id])
    @comment = @gem.unchikus.find(params[:id])
    raise("comment id is not found") if @comment.nil?
    @comment.rate(1, current_user)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "＋評価しました"
        redirect_to(rubygem_path(@gem))
      end
    end
  end
  
  # POST   /rubygems/:rubygem_id/unchikus/:id/minus_useful 
  def minus_useful
    @gem = Rubygem.find(params[:rubygem_id])
    @comment = @gem.unchikus.find(params[:id])
    raise("comment id is not found") if @comment.nil?
    @comment.rate(-1, current_user)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "−評価しました"
        redirect_to(rubygem_path(@gem))
      end
    end
  end
  
  # POST   /rubygems/:rubygem_id/unchikus/:id/reset_useful 
  def reset_useful
    @gem = Rubygem.find(params[:rubygem_id])
    @comment = @gem.unchikus.find(params[:id])
    raise("comment id is not found") if @comment.nil?
    @comment.unrate(current_user)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "評価を取り消しました"
        redirect_to(rubygem_path(@gem))
      end
    end
  end
  
  # POST   rubygems/:rubygem_id/unchiku/trackback/:user_key
  # パラメータ名	意味
  # url         記事のURL
  # blog_name	ブログ名
  # title	記事のタイトル
  # excerpt	記事の概要
  # ref:http://d.hatena.ne.jp/omochist/20060812/trackback_sikumi
  # ref:http://gdgdlog.net/log/show/206
  # ref:http://hippos-lab.com/blog/node/56
  def create_trackback
    setup_for_spec(params[:rubygem_id])   
    
    @user = User.find_by_user_key(params[:user_key].strip)
    raise "User not found" if @user.nil?
    @comment = @gem.unchikus.build
    @comment.user_id = @user.id
    @comment.url = params[:url]
    @comment.tried_times = 100 # TODO:
    @comment.title = params[:title]
    @comment.comment = params[:blog_name] + "からトラックバックにて登録されました。\n詳しくはリンクをクリックし、参照元をご確認ください。"
    @comment.foreign_content = params[:excerpt]
    @comment.method = 'sent trackback'
    respond_to do |format|
      if @comment.save
        logger.info "create trackback for #{params[:url]}"
        format.html { render_result_of_trackback(0, "added your trackback") }
      else
        format.html { 
          error_message = ""
          @comment.errors.each do |key, value| error_message << "#{key} : #{value}" end
          logger.info "error messages on unchiku trackback : [#{error_message}]"
          render_result_of_trackback(1, error_message)       
        }
      end
    end
  end

protected


  def render_result_of_trackback(error, message)
    str = '<?xml version="1.0" encoding="iso-8859-1"?>'
    str += '<response>'
    if error == 0
      str += '<error>0</error>'
    else
      str += '<error>1</error>'
      str += '<message>' + message + '</message>'
    end
    str += '</response>'
    headers["Content-Type"] = 'application/xml; charset=UTF-8'
    render :text => str, :layout => false
  end

end
