# This controller handles the login/logout function of the site.  
class SessionController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  # include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  # before_filter :login_from_cookie

  layout "standard"

  def new
  end

  # POST /session
  def create
    login = params[:login] || params[:email] || params[:username]
    self.current_user = User.authenticate(login, params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      if params[:redirect]
        begin
          new_params = convert_hash_values(parse_query_parameters(params[:redirect]).symbolize_keys)
          new_url = ActionController::Routing::Routes.generate(new_params)
					redirect_to("#{ActionController::AbstractRequest.relative_url_root}#{new_url}")
        rescue ActionController::RoutingError
          redirect_back_or_default(home_url)
          flash[:notice] = "Redirect unsuccessful"
        end
      else
        redirect_back_or_default(home_url)
        flash[:notice] = "Logged in successfully"
      end
    else
      flash[:notice]  = "Login unsuccessful, login or password incorrect."
      self.current_user = User.anonymous
      render :action => 'new'
    end
  end
  
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
#    redirect_to :controller => "home", :action => 'index' 
    redirect_back_or_default(home_url)
  end
end
