# This controller handles the login/logout function of the site.  
class <%= controller_class_name %>Controller < ApplicationController
  include OpenidFu::ControllerMethods
  # XXX: Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # Obtain personal identity from OP. If OP accomodates the OpenID Attributes Exchange(AX) or SREG, 
  # then use AX or SREG, unfortunately if both OpenID Extensions aren't supported then input ones in RP.
  #
  # == Examples:
  #   # Email and nickname are required, gender and birth date are obtained if these are available.
  #   open_id_consumer :required => [:email, :nickname], :if_available => [:gender, :birth_date]
  #
  open_id_consumer :required => [:email, :nickname]

  # XXX: If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  rescue_from OpenID::DiscoveryFailure, :with => :begin_error

  def new
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])
  end

  def create
    self.current_<%= file_name %> = <%= class_name %>.authenticate(params[:email], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_<%= file_name %>.remember_me
        cookies[:auth_token] = { :value => self.current_<%= file_name %>.remember_token , :expires => self.current_<%= file_name %>.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      flash[:notice] = "Login failed"
      render :action => 'new'
    end
  end

  def destroy
    self.current_<%= file_name %>.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  def begin
    # If the URL was unusable (either because of network conditions, a server error, 
    # or that the response returned was not an OpenID identity page), the library 
    # will return HTTP_FAILURE or PARSE_ERROR. Let the user know that the URL is unusable.
    case open_id_request.status
      when OpenID::Consumer::SUCCESS
        # The URL was a valid identity URL. Now we just need to send a redirect
        # to the server using the redirect_url the library created for us.

        # redirect to the server
        redirect_to open_id_request.redirect_url((request.protocol + request.host_with_port + "/"), complete_<%= controller_file_name %>_url)
      else
        flash[:error] = "Unable to find OpenID server for <q>#{params[:open_id_claimed_id]}</q>"
        render :action => :new
    end
  end

  def begin_error
    flash[:error] =
      "Unable to find OpenID server for <q>#{params[:open_id_claimed_id]}</q>"
    render :action => :new
  end

  def complete
    case open_id_response.status
      when OpenID::Consumer::FAILURE
        # In the case of failure, if info is non-nil, it is the URL that we were verifying. 
        # We include it in the error message to help the user figure out what happened.
        flash[:notice] = if open_id_response.identity_url
          "Verification of #{open_id_response.identity_url} failed. "
        else
          "Verification failed. "
        end
        flash[:notice] += open_id_response.msg.to_s
      when OpenID::Consumer::SUCCESS
        # Success means that the transaction completed without error. If info is nil, 
        # it means that the user cancelled the verification.
        flash[:notice] = "You have successfully verified #{open_id_response.identity_url} as your identity."
        if open_id_fields.any?
          @<%= file_name %>   = <%= class_name %>.find_by_claimed_id(open_id_response.identity_url)
          @<%= file_name %> ||= <%= class_name %>.new(:claimed_id => open_id_response.identity_url)
          @<%= file_name %>.email = open_id_fields['email']    if open_id_fields['email']
          @<%= file_name %>.nickname = open_id_fields['nickname'] if open_id_fields['nickname']
          if @<%= file_name %>.save
            self.current_<%= file_name %> = @<%= file_name %>
            if params[:remember_me] == "1"
              self.current_<%= file_name %>.remember_me
              cookies[:auth_token] = { :value => self.current_<%= file_name %>.remember_token , :expires => self.current_<%= file_name %>.remember_token_expires_at }
            end
            flash[:notice] = "You have successfully verified #{open_id_response.identity_url} as your identity."
            return redirect_back_or_default('/')
          else
            flash[:notice] = @<%= file_name %>.errors.full_messages.join('<br />')
            render :action => 'new' and return
          end
        end
      when OpenID::Consumer::CANCEL
        flash[:notice] = "Verification cancelled."
      else
        flash[:notice] = "Unknown response status: #{open_id_response.status}"
    end
    redirect_to :action => 'new'
  end
end
