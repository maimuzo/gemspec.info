# use unpacked gems from vender directory.
# require 'ruby-openid-2.1.2/lib/openid'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include ApplicationHelper
  include ExceptionNotifiable


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :except => :create_trackback #:secret => 'f06beab18f0a0798ab325cb90cac37ff'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  layout "default"
  
  # 未ログイン状態でログインが必要なページに入ろうとすると、元のページに戻される
  # ログイン専用ページがない場合など
  # example : before_filter :block_until_authorized, :only => [ :new , :edit, :create, :update, :destroy]
  def block_until_authorized
    unless logged_in?
      flash[:notice] = "Please log in"
      begin
        redirect_to(request.referer)
      rescue
        # if request.referer is nil
        redirect_to('/')
      end
    end
  end

  # ログインが必要なページならば認証ページをはさみ、認証したらそのページに誘導する
  # ログイン専用ページがある場合など
  # 一部
  # http://japan.internet.com/column/developer/20080627/26.html
  # を参考に書き換え必要
  # example : before_filter :go_through_authorized, :only => [ :new , :edit, :create, :update, :destroy]
  def go_through_authorized
    unless logged_in?
      # save the URL the user requested so we can hop back to it
      # after login
      session[:jumpto] = request.parameters
      session[:jumpfrom] = nil
      # need a route in config/routes.rb
      redirect_to login_url
    end
  end

protected

  def setup_for_spec(rubygem_id)
    @gem = Rubygem.find(rubygem_id)
    if params[:version_id]
      @version = @gem.versions.find(params[:version_id])
    else
      @version = @gem.lastest_version
    end
    @versions_for_select = @gem.versions.reverse
    @detail = @version.find_detail_and_check_empty
    @dependencies = @version.dependencies
    @obstacles = @version.obstacles
  end

end
