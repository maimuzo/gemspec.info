class MypagesController < ApplicationController
  before_filter :block_until_authorized

  # GET /mypagea
  def show
    @title = "Mypage"
    @user = current_user
    @favorites = @user.favorite_gems.find(:all, :page=>{:size=>20, :current=>params[:page]})

    respond_to do |format|
      format.html
    end
  end

  # GET /mypage/edit
  def edit
    @title = "Mypage編集"
    @user = current_user

    respond_to do |format|
      format.html
    end
  end
  
  # PUT /mypage
  def update
    @user = current_user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User profile was successfully updated.'
        format.html { redirect_to(mypage_path) }
      else
        @title = "Mypage再編集"
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /mypage
  def destroy
    # @testpage = current_user.destroy

    respond_to do |format|
      format.html { redirect_to(mypage_path) }
    end
  end
end
