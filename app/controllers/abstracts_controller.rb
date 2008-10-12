class AbstractsController < ApplicationController
#  def show
#  end

  # POST   /rubygems/:rubygem_id/(what/strength/weakness)/plus_useful
  def plus_useful
    @gem = Rubygem.find(params[:rubygem_id])
    case controller_name
    when 'what'
      @abstract = @gem.what.find(params[:id])
    when 'strength'
      @abstract = @gem.strength.find(params[:id])
    when 'weakness'
      @abstract = @gem.weakness.find(params[:id])
    else
      flash[:notice] = "なんかへん"
      redirect_to(rubygem_path(@gem))
      return
    end

    @abstract.rate(1, current_user)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "＋評価しました"
        redirect_to(rubygem_path(@gem))
      end
    end
  end

  # POST   /rubygems/:rubygem_id/(what/strength/weakness)/minus_useful
  def minus_useful
    @gem = Rubygem.find(params[:rubygem_id])
    case controller_name
    when 'what'
      @abstract = @gem.what.find(params[:id])
    when 'strength'
      @abstract = @gem.strength.find(params[:id])
    when 'weakness'
      @abstract = @gem.weakness.find(params[:id])
    else
      flash[:notice] = "なんかへん"
      redirect_to(rubygem_path(@gem))
      return
    end

    @abstract.rate(-1, current_user)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "−評価しました"
        redirect_to(rubygem_path(@gem))
      end
    end
  end

  # POST   /rubygems/:rubygem_id/(what/strength/weakness)/reset_useful
  def reset_useful
    @gem = Rubygem.find(params[:rubygem_id])
    case controller_name
    when 'what'
      @abstract = @gem.what.find(params[:id])
    when 'strength'
      @abstract = @gem.strength.find(params[:id])
    when 'weakness'
      @abstract = @gem.weakness.find(params[:id])
    else
      flash[:notice] = "なんかへん"
      redirect_to(rubygem_path(@gem))
      return
    end

    @abstract.unrate(current_user)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "評価を取り消しました"
        redirect_to(rubygem_path(@gem))
      end
    end
  end

  # POST   /rubygems/:rubygem_id/(what/strength/weakness)
  def create
    @gem = Rubygem.find(params[:rubygem_id])
    case controller_name
    when 'what'
      @abstract = @gem.what.build(params[:what])
    when 'strength'
      @abstract = @gem.strength.build(params[:strength])
    when 'weakness'
      @abstract = @gem.weakness.build(params[:weakness])
    else
      flash[:notice] = "なんかへん"
      redirect_to(rubygem_path(@gem))
      return
    end
    @abstract.user_id = current_user.id
    respond_to do |format|
      if @abstract.save
#        flash[:notice] = 'Tag was successfully added.'
        format.html { redirect_to(rubygem_path(@gem)) }
      else
        format.html { redirect_to(rubygem_path(@gem)) }
      end
    end
  end

  # DELETE   /rubygems/:rubygem_id/(what/strength/weakness)
  def destroy
    @gem = Rubygem.find(params[:rubygem_id])
    cond = {
      :user_id => current_user.id,
      :id => params[:id]
    }
    case controller_name
    when 'what'
      @abstract = @gem.what.find(:first, :conditions => cond)
    when 'strength'
      @abstract = @gem.strength.find(:first, :conditions => cond)
    when 'weakness'
      @abstract = @gem.weakness.find(:first, :conditions => cond)
    else
      flash[:notice] = "なんかへん"
      redirect_to(rubygem_path(@gem))
      return
    end
    respond_to do |format|
      unless @abstract.nil?
        @abstract.destroy
#        flash[:notice] = 'Tag was successfully added.'
        format.html { redirect_to(rubygem_path(@gem)) }
      else
        format.html { redirect_to(rubygem_path(@gem)) }
      end
    end
  end
  
end
