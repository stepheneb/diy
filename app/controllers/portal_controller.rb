class PortalController < ApplicationController
  layout "standard"
  
  before_filter :init
  before_filter :authenticate

  def init
    @login = params[:login] ? params[:login] : nil
    @password = params[:password] ? params[:password] : nil
    @activity = params[:id] ? Activity.find(params[:id]) : nil
  end
  
  def authenticate
    @user = User.authenticate(@login, @password)
    self.current_user = @user
    if @user
      @user.remember_me
      cookies[:auth_token] = { :value => @user.remember_token , :expires => @user.remember_token_expires_at } 
    else
      # render 401
      render(:text => "", :status => 401) # Unauthorised
    end
  end

  def edit
    redirect_to :controller => 'activities', :action => 'edit', :id => @activity.id
  end
  
  def create
    @new_activity = Activity.new
    @new_activity.user = @user
    @new_activity.public = false
    @new_activity.draft = false
    @new_activity.textile = true
    @new_activity.name = (params[:title] ? params[:title] : "New Activity")
    @new_activity.introduction = "New Activity"
    @new_activity.save
    render :xml => (@new_activity.to_xml(:only => ['id']))
  end
  
  def copy
    @activity.user = @user
    @activity.public = false
    @activity.draft = false
    @activity.name << " (copy)"
    @new_activity = @activity.clone
    @new_activity.save
    render :xml => (@new_activity.to_xml(:only => ['id']))
  end
  
  def run
    redirect_to :controller => 'activities', :action => 'sail_jnlp', :uid => @user.id, :vid => @user.vendor_interface.id, :id => @activity.id, :savedata => true, :authoring => nil
  end
  
  def view
    redirect_to :controller => 'activities', :action => 'sail_jnlp', :uid => @user.id, :vid => @user.vendor_interface.id, :id => @activity.id, :savedata => false, :authoring => nil
  end
  
  def publish
    if request.post?
      unless @activity
        render(:text => "", :status => 404) # Bad activity id
      else
        @activity.custom_otml = request.raw_post
        begin
          @activity.save!
          render(:text => "Success", :status => 200) # success
        rescue
          render(:text => "Success", :status => 400) # bad otml
        end
      end
    else
      render(:text => "", :status => 404) # Not a post
    end
  end

  def list_users
    @users = { }
    @activity.learner_sessions.each do |s|
      u = s.learner.user
      if ! @users[u.id] || @users[u.id][1] < s.created_at
        @users[u.id] = [u, s.created_at]
      end
    end
    
    render :layout => false
  end
  
  def list_runs
    @activities = { }
    @user.learners.each do |l|
      a = l.activity
      session = l.learner_sessions.find(:first, :order => 'created_at desc')
      @activities[session.created_at] = a
    end
    
    render :layout => false
  end
  
  def list_activities
    @activities = []
    # get all public activities
    public = Activity.find(:all, :conditions => "public='1'")
    # now get all of the authenticated user's private activities
    private = Activity.find(:all, :conditions => "public='0' and user_id='#{@user.id}'")

    public.each do |a|
      @activities << a
    end
    
    private.each do |a|
      @activities << a
    end
    
    render :layout => false
  end
  
  def create_user
    if request.post?
      if check_roles("admin")
        post = REXML::Document.new(request.raw_post).root
        if post
          email = REXML::XPath.first(post, "//email").text
          login = REXML::XPath.first(post, "//login").text
          
          if @new_user = User.find_by_login(login) || @new_user = User.find_by_email(email)
          else
            @new_user = User.new
          end
          
          @new_user.first_name = REXML::XPath.first(post, "//firstname").text
          @new_user.last_name = REXML::XPath.first(post, "//lastname").text
          @new_user.email = email
          @new_user.login = login
          @new_user.password = REXML::XPath.first(post, "//password").text
          @new_user.password_confirmation = REXML::XPath.first(post, "//password").text
          @new_user.vendor_interface_id = VendorInterface.find_by_short_name('vernier_goio').id
          @new_user.roles << Role.find(:first, :conditions => "title = 'member'") 
          
          @new_user.save!
          
          # render user
          # <user>
          #   <id>#{@new_user.id}</id>
          #   ...
          # </user>
          render :xml => (@new_user.to_xml(:except => ['created_at', 'updated_at', 'salt', 
                                                       'remember_token', 'remember_token_expires_at',
                                                       'crypted_password', 'password_hash', 'sds_sail_user_id'])) 
        else
          render(:text => "", :status => 401) # unauthorised
        end
      else
       # puts "Bad post: #{request.raw_post}"
        render(:text => "", :status => 400) # bad request  
      end
    else
      # puts "Not a post"
      render(:text => "", :status => 404) # Bad Request
    end
    
  end
    
  private
  
  def check_roles(role_str)
    role = Role.find(:first, :conditions => "title = '#{role_str}'")
    correct_role = false
    @user.roles.each do |r|
      if r.title == role_str
        correct_role = true
      end
    end
    return correct_role
  end
end
