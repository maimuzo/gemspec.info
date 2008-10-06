# use unpacked gems from vender directory.
require 'ruby-openid-2.1.2/lib/openid'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery #:secret => 'f06beab18f0a0798ab325cb90cac37ff'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  layout :default
  
  # 未ログイン状態でログインが必要なページに入ろうとすると、元のページに戻される
  # ログイン専用ページがない場合など
  def block_until_authorized
    unless login?
      flash[:notice] = "Please log in"
      redirect_to(request.refferer)
    end
  end

  # ログインが必要なページならば認証ページをはさみ、認証したらそのページに誘導する
  # ログイン専用ページがある場合など
  # 一部
  # http://japan.internet.com/column/developer/20080627/26.html
  # を参考に書き換え必要
  def go_through_authorized
    unless login?
      flash[:notice] = "Please log in"
      # save the URL the user requested so we can hop back to it
      # after login
      session[:jumpto] = request.parameters
      redirect_to("/login")
    end
  end

  def login?
    session[:user_id]
  end

  def logined_user
    User.find(session[:user_id])
  end

  
end
