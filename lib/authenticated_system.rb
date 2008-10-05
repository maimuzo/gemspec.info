module AuthenticatedSystem
protected
  # Returns true or false if the user is logged in.
  # Preloads @current_user with the user model if they're logged in.
  def logged_in?
    current_user != :false
  end
  
  # Accesses the current user from the session.
  def current_user
    @current_user ||= (session[:user] && User.find_by_id(session[:user])) || :false
  end
  
  # Store the given user in the session.
  def current_user=(new_user)
    session[:user] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
    @current_user = new_user
  end
  
  # Check if the user is authorized.
  #
  # Override this method in your controllers if you want to restrict access
  # to only a few actions or if you want to check if the user
  # has the correct rights.
  #
  # Example:
  #
  #  # only allow nonbobs
  #  def authorize?
  #    current_user.login != "bob"
  #  end
  def authorized?
    true
  end

  # Filter method to enforce a login requirement.
  #
  # To require logins for all actions, use this in your controllers:
  #
  #   before_filter :login_required
  #
  # To require logins for specific actions, use this in your controllers:
  #
  #   before_filter :login_required, :only => [ :edit, :update ]
  #
  # To skip this in a subclassed controller:
  #
  #   skip_before_filter :login_required
  #
  def login_required
    username, passwd = get_auth_data
    self.current_user ||= User.authenticate(username, passwd) || :false if username && passwd
    logged_in? && authorized? ? true : access_denied
  end
  
  # Redirect as appropriate when an access request fails.
  #
  # The default action is to redirect to the login screen.
  #
  # Override this method in your controllers if you want to have special
  # behavior in case the user is not authorized
  # to access the requested action.  For example, a popup window might
  # simply close itself.
  def access_denied
    respond_to do |accepts|
      accepts.html do
        store_location
        return auto_login if request.xhr?
        redirect_to :controller => 'sessions',
          :action => 'new', :open_id_claimed_id => params[:open_id_claimed_id]
      end
      accepts.xml do
        headers["Status"]           = "Unauthorized"
        headers["WWW-Authenticate"] = %(Basic realm="Web Password")
        render :text => "Could't authenticate you", :status => '401 Unauthorized'
      end
    end
    false
  end  

  def auto_login
    render :update do |page|
      page << <<-"EOH"
      (function(){
        var input, form = document.createElement('form');
        form.style.position = 'absolute';
        form.style.left = form.style.top = '-1000px';
        document.body.appendChild(form);
        input = form.appendChild(document.createElement('input'));
        input.name = 'open_id_claimed_id';
        input.value = #{params[:open_id_claimed_id].to_json};
        input = form.appendChild(document.createElement('input'));
        input.name = 'remember_me';
        input.value = #{params[:remember_me].to_json};
        input = form.appendChild(document.createElement('input'));
        input.name = 'authenticity_token';
        input.value = $$('input[name="authenticity_token"]')[0].value;
        form.action = #{begin_sessions_path.to_json};
        form.method = 'POST';
        form.submit();
      })();
      EOH
    end
    false
  end
  
  # Store the URI of the current request in the session.
  #
  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:stored_parameters] = params
    session[:return_to] = request.request_uri
    session[:return_to_method] = request.method
  end
  
  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.
  def redirect_back_or_default(default)
    if session[:return_to]
      render :action => 'restore_location'
    else
      redirect_to(default)
    end
    session[:return_to] = nil
    session[:return_to_method] = nil
  end
  
  # Inclusion hook to make #current_user and #logged_in?
  # available as ActionView helper methods.
  def self.included(base)
    base.send :helper_method, :current_user, :logged_in?
  end

  # When called with before_filter :login_from_cookie will check for an :auth_token
  # cookie and log the user back in if apropriate
  def login_from_cookie
    return unless cookies[:auth_token] && !logged_in?
    user = User.find_by_remember_token(cookies[:auth_token])
    if user && user.remember_token?
      user.remember_me
      self.current_user = user
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      flash[:notice] = "Logged in successfully"
    end
  end

private
  @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
  # gets BASIC auth info
  def get_auth_data
    auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
    auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
    return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
  end
end
