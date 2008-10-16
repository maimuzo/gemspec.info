class GemcastsController < ApplicationController

  # GET    /rubygems/:rubygem_id/gemcasts/:id
  def show
    setup_for_spec(params[:rubygem_id])
    @title = "gemcast for " + @gem.name
    @comment = @gem.gemcasts.find(params[:id])
  end

  # GET    /rubygems/:rubygem_id/gemcasts/new
  def new
    setup_for_spec(params[:rubygem_id])
    @title = "add gemcast for " + @gem.name
    @comment = @gem.gemcasts.build
  end

  # POST   /rubygems/:rubygem_id/gemcasts
  def create
    setup_for_spec(params[:rubygem_id])   
    @comment = @gem.gemcasts.build(params[:gemcast])
    @comment.user_id = current_user.id
    @comment.method = 'posted'
    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Gemcast was successfully created.'
        format.html { redirect_to(rubygem_path(@gem)) }
      else
        @title = "add gemcast for agein " + @gem.name
        format.html { render :action => "new" }
      end
    end
  end
  
  # GET    /rubygems/:rubygem_id/gemcasts/:id/edit
  def edit
    setup_for_spec(params[:rubygem_id])
    @title = "Edit gemcast for " + @gem.name
    @comment = @gem.gemcasts.find_by_id_and_user_id(params[:id], current_user.id)
    raise "User id is not match" if @comment.nil?
  end
  
  # PUT    /rubygems/:rubygem_id/gemcasts/:id
  def update
    setup_for_spec(params[:rubygem_id])   
    @comment = @gem.gemcasts.find_by_id_and_user_id(params[:id], current_user.id)
    raise "User id is not match" if @comment.nil?
    @comment.user_id = current_user.id
    respond_to do |format|
      if @comment.update_attributes(params[:gemcast])
        flash[:notice] = 'Gemcast was successfully updated.'
        format.html { redirect_to(rubygem_path(@gem)) }
      else
        @title = "edit gemcast for agein " + @gem.name
        format.html { render :action => "edit" }
      end
    end
  end
  
  # DELETE /rubygems/:rubygem_id/gemcasts/:id 
  def destroy
    @gem = Rubygem.find(params[:rubygem_id])
    @comment = @gem.gemcasts.find_by_id_and_user_id(params[:id], current_user.id)
    errors.add_to_base("User id is not match") if @comment.nil?
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to(rubygem_path(@gem)) }
    end
  end
  
  # POST   /rubygems/:rubygem_id/gemcasts/:id/plus_useful
  def plus_useful
    @gem = Rubygem.find(params[:rubygem_id])
    @comment = @gem.gemcasts.find(params[:id])
    raise("comment id is not found") if @comment.nil?
    @comment.rate(1, current_user)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "＋評価しました"
        redirect_to(rubygem_path(@gem))
      end
    end
  end
  
  # POST   /rubygems/:rubygem_id/gemcasts/:id/minus_useful 
  def minus_useful
    @gem = Rubygem.find(params[:rubygem_id])
    @comment = @gem.gemcasts.find(params[:id])
    raise("comment id is not found") if @comment.nil?
    @comment.rate(-1, current_user)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "−評価しました"
        redirect_to(rubygem_path(@gem))
      end
    end
  end
  
  # POST   /rubygems/:rubygem_id/gemcasts/:id/reset_useful 
  def reset_useful
    @gem = Rubygem.find(params[:rubygem_id])
    @comment = @gem.gemcasts.find(params[:id])
    raise("comment id is not found") if @comment.nil?
    @comment.unrate(current_user)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "評価を取り消しました"
        redirect_to(rubygem_path(@gem))
      end
    end
  end
end
