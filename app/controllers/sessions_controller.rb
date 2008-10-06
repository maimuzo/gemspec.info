class SessionsController < ApplicationController

  # TODO:change default page
  @@default_page = "/"

  # require property from a OpenID provider
  # [:(User model property) => "(OpenID provider property)"]
  @@required = {
    :nickname => "nickname",
    :email => "email"
  }

  # optional property from a OpenID provider (sreg)
  # [:(User model property) => "(OpenID provider property)"]
  @@optional = {
    :fullname => "fullname",
    :birth_day => "dob",
    :gender => "gender",
    :postcode => "postcode",
    :country => "country",
    :language => "language",
    :timezone => "timezone"
  }

  # TODO:if your app has an especialy login page, you can use this index action
  # GET /sessions/new
  def new
    #redirect_to :controller => "TODO::your_logined_user_controller" if login?
    redirect_to default_page
  end

  # POST /sessions
  def create
    if using_open_id?
      open_id_authentication
    else
      flash[:error] = "You must provide an OpenID URL"
      redirect_to tyied_page
    end
  end

  # DELETE /sessions
  # GET    /logout
  def destroy
    session[:user_id] = nil
    redirect_to default_page
  end

protected

  def open_id_authentication

    authenticate_with_open_id(params[:openid_url],
                              {:required => @@required.values.map {|str| str.to_sym},
                              :optional => @@optional.values.map {|str| str.to_sym}}) do
      |status, identity_url, registration|

      case status.result
      when :found_in_whitelist
        #TODO:
        #server_url = registration.endpoint.server_url
        #if not TrastedOpenidProvider.find_by_url(server_url)
          # 信頼していないOPでのログインは拒否する
          #failed_login "Sorry, untrusted OpenID provider: #{server_url}"
        failed_login "Sorry, the OpenID server is blocked"
      when :double_auth
        failed_login "Error, detect a double autentication"
      when :missing
        failed_login "Sorry, the OpenID server couldn't be found"
      when :canceled
        failed_login "OpenID verification was canceled"
      when :failed
        failed_login "Sorry, the OpenID verification failed"
      when :successful
        if @current_user = User.find_by_claimed_url(identity_url)
          failed_login "Sorry, this identity URL already exists"
        else
          @current_user = User.new
          assign_registration_attributes!(registration)
          @current_user.claimed_url = identity_url

          if @current_user.save
            successful_login
          else
            failed_login "Your OpenID profile registration failed: " +
              @current_user.errors.full_messages.to_sentence
          end
        end
      end

    end
  end

  def successful_login
    session[:user_id] = @current_user.id
    #jumpto = session[:jumpto] || default_page
    #session[:jumpto] = nil
    #redirect_to(jumpto)
    redirect_to(root_url)
  end

  def failed_login(message)
    flash[:error] = message
    redirect_to default_page
  end

   # if you don't use map.resource in config/routes.rb, you need to use root_url method:
#  def root_url
#    # TODO:check with config/routes.rb
#    open_id_complete
#  end
 
  def default_page
    @@default_page
  end

  def tyied_page
    request.referer
  end

  # registration is a hash containing the valid sreg keys given above
  # use this to map them to fields of your user model
  def assign_registration_attributes!(registration)
    model_to_registration_mapping.each do |model_attribute, registration_attribute|
      unless registration[registration_attribute].blank?
        @current_user.send("#{model_attribute}=", registration[registration_attribute])
      end
    end
  end

  # TODO:change this hash like your user model.
  def model_to_registration_mapping
    @@required.merge(@@optional)
  end
    
end
