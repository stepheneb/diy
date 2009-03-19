class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  # include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  # before_filter :login_from_cookie

  before_filter :setup_vars
  before_filter :setup_object
  before_filter :find_collections, :except => :destroy 

  layout "standard"
  
  access_rule 'admin', :only => [:index, :new, :edit, :update, :destroy]
  access_rule 'admin || manager', :only => :index
  
  protected
  
  def setup_vars
    @class_name = User.to_s.underscore
    @class_name_titleized = @class_name.titleize
    @searchable_attributes = User.searchable_attributes
  end
  
  def setup_object
    if params[:id]
      @user = User.find(params[:id])
    elsif params[:user]
      @user = User.new(params[:user])
    else
      @user = User.new
    end
  end

  def find_collections
    @all_viewable_users = User.find(:all, :order=>'first_name asc')
    @all_editable_users = @all_viewable_users
  end

  public

  def index
#    @user_pages, @users = paginate(:users, :per_page => 8)
#    params[:list_conditions] = 'all'
#    session[:page] = params[:page] || 1   
    @users = User.search(params[:search], params[:page], current_user)
    @paginated_objects = @users
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @all_viewable_users.to_xml }
    end
  end

  # render new.rhtml
  def new
  end

  # POST /users
  # POST /users.xml
  def create
    respond_to do |format|
      if @user.save
        if @user.roles.size == 0
          @user.roles << Role.find(:first, :conditions => "title='member'")
          @user.save
        end
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to user_url(@user) }
        format.xml  { head :created, :location => user_url(@user) }
      else
        flash[:notice]  = "The username: \"#{@user.login}\", or the email \"#{@user.email}\" is already being used. Please pick another."
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    if params[:user][:password] && params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to users_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end
  
  # GET /users/1
  # GET /users/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @user.to_xml }
    end
  end

  # GET /users/1/edit
  def edit
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    if associated_resources = @user.any_has_manys?
      errors = "The user #{@user.name}, login: #{@user.login}, email: #{@user.email} can't be deleted yet. This user has these associated resources which must be either transferred to another users or deleted first: #{associated_resources}."
      flash[:notice] = errors
      respond_to do |format|
        format.html { redirect_to users_url }
        format.xml  { render :xml => errors, :status => :precondition_failed }
      end
    else
      if @user.destroy
        flash[:notice] = "The user #{@user.name}, login: #{@user.login}, email: #{@user.email} was successfully deleted."
        respond_to do |format|
          format.html { redirect_to users_url }
          format.xml  { head :ok }
        end
      else
      end
    end
  end
  
  
  def interface
    # Select the probeware vendor and interface to use when generating jnlps and otml
    # files. This redult is saved in a session variable and if the user is logged-in
    # the selection is also saved into their user record.
    # The result is expressed not only in the jnlp and otml files which are
    # downloaded to the users computer but the vendor_interface id (vid) which is 
    # also included in the contruction of the url
    if !@user.changeable?(current_user)
      flash[:warning]  = "You need to be logged in first."
      redirect_to login_url 
    else
      if params[:commit] == "Cancel"
        redirect_back_or_default(home_url)
      else
        if request.put?
          respond_to do |format|
            if @user.update_attributes(params[:user])
              format.html {  redirect_back_or_default(home_url) }
              format.xml  { head :ok }
            else
              format.html { render :action => "interface" }
              format.xml  { render :xml => @user.errors.to_xml }
            end
          end
        else
          # @vendor_interface = current_user.vendor_interface
          # @vendor_interfaces = VendorInterface.find(:all).map { |v| [v.name, v.id] }
          # session[:back_to] = request.env["HTTP_REFERER"]
          # render :action => "interface"
        end
      end
    end
  end
  
  def vendor_interface
    v_id = params[:vendor_interface]
    if v_id
      @vendor_interface = VendorInterface.find(v_id)
      render :partial=>'vendor_interface', :layout=>false 
    else
      render(:nothing => true) 
    end
  end
end
