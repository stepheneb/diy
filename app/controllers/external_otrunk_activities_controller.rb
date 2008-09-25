require 'hpricot'

class ExternalOtrunkActivitiesController < ApplicationController
  # GET /external_otrunk_activities
  # GET /external_otrunk_activities.xml

  access_rule 'admin || manager || teacher || member', :only => [:new, :edit, :create, :update, :copy, :destroy]

  layout "standard"

  before_filter :setup_vars
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy, :otml, :sail_jnlp ]
  before_filter :get_learner, :only => [:show, :edit, :update]

  protected

  def setup_vars
    @class_name = ExternalOtrunkActivity.to_s.underscore
    @class_name_titleized = APP_PROPERTIES[:external_otrunk_activities_title]
    @searchable_attributes = ExternalOtrunkActivity.searchable_attributes
    @restricted_copy_and_create = true
  end
  
  def setup_object
    Thread.current[:request] = request
    if params[:id]
      if params[:id].length == 36
        @external_otrunk_activity = ExternalOtrunkActivity.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @external_otrunk_activity = ExternalOtrunkActivity.find(params[:id])
      end
    elsif params[:external_otrunk_activity]
      @external_otrunk_activity = ExternalOtrunkActivity.new(params[:external_otrunk_activity])
    else
      @external_otrunk_activity = ExternalOtrunkActivity.new
    end
  end

  def find_collections
    @all_viewable_external_otrunk_activities = ExternalOtrunkActivity.find(:all, :conditions => "public=true or user_id='#{current_user.id}'")
    @all_editable_external_otrunk_activities = ExternalOtrunkActivity.find_all_by_user_id(current_user.id)
  end
  
  def get_learner
    @learner = @external_otrunk_activity.find_or_create_learner(current_user)
  end

  public
    
  # GET /learners/1/ot_learner_data.xml
  def ot_learner_data
    @learners = @external_otrunk_activity.learners      
    if not params[:users].blank?
      users_array = params[:users].split ',' 
      @learners = @learners.find(:all, :conditions => { :user_id => users_array})
      
      # inorder to support running reports for users that haven't run this activity
      # passed in users that don't have learners should either get learnes created or
      # or temporary learners should be created.
    end
    # setup overlay folder. These overlay files hold per-user customizations to the activity.
    @useOverlays = setup_overlay_folder(@external_otrunk_activity.id)
    @learners.each do |l|
      setup_default_overlay(@external_otrunk_activity.id, l.id)
    end
    render(:template => "shared/ot_learner_data.builder", :layout => false)
  end

  def index
	  @external_otrunk_activities = ExternalOtrunkActivity.search(params[:search], params[:page], current_user)
    @paginated_objects = @external_otrunk_activities
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => ExternalOtrunkActivity.find(:all).to_xml(:except => ['otml']) }
    end
  end

  # GET /external_otrunk_activities/1
  # GET /external_otrunk_activities/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @external_otrunk_activity.to_xml }
    end
  end

  # GET /external_otrunk_activities/new
  def new
    @external_otrunk_activity.public = true
    @external_otrunk_activity.user = current_user
  end

  # GET /external_otrunk_activities/1/edit
  def edit
  end

  # POST /external_otrunk_activities
  # POST /external_otrunk_activities.xml
  def create
    @external_otrunk_activity.user = current_user
    respond_to do |format|
      if @external_otrunk_activity.save
        flash[:notice] = "#{@class_name_titleized}: #{@external_otrunk_activity.name} was successfully created."
        format.html do
          if params[:commit] == "Create and keep editing"
            redirect_to edit_external_otrunk_activity_url(@external_otrunk_activity)
          else
            redirect_to external_otrunk_activity_url(@external_otrunk_activity)
          end
        end
        format.xml  { head :created, :location => external_otrunk_activity_url(@external_otrunk_activity) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @external_otrunk_activity.errors.to_xml }
      end
    end
  end

  # PUT /external_otrunk_activities/1
  # PUT /external_otrunk_activities/1.xml
  def update
    respond_to do |format|
      if @external_otrunk_activity.update_attributes(params[:external_otrunk_activity])
        flash[:notice] = "#{@class_name_titleized}: #{@external_otrunk_activity.name} was successfully updated."
        format.html do 
          if params[:commit] == "Save and keep editing"
            redirect_to edit_external_otrunk_activity_url(@external_otrunk_activity)
          else
            redirect_to external_otrunk_activity_url(@external_otrunk_activity)
          end
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @external_otrunk_activity.errors.to_xml }
      end
    end
  end

  # DELETE /external_otrunk_activities/1
  # DELETE /external_otrunk_activities/1.xml
  def destroy
    @external_otrunk_activity.destroy
    respond_to do |format|
      format.html { redirect_to external_otrunk_activities_url }
      format.xml  { head :ok }
    end
  end
  
  def copy
    @external_otrunk_activity.user = current_user
    @external_otrunk_activity.public = true
    @external_otrunk_activity.name << " (copy)"
    @external_otrunk_activity.uuid = nil
    @external_otrunk_activity.parent_id = @external_otrunk_activity.id
    @external_otrunk_activity.parent_version = @external_otrunk_activity.version
    render :action => 'new'
  end

  def otml
    render :xml => @external_otrunk_activity.otml
  end

  def overlay_otml
    @user = User.find(params[:uid])
    activity = @external_otrunk_activity
    learner = activity.find_or_create_learner(@user)
    group_id = params[:group_id]
    savedata = params[:savedata]
    authoring = params[:authoring]
    reporting = params[:reporting]
    nobundles = ((params[:nobundles] && ! params[:nobundles].empty?) ? true : false)
    
    @activity_otml_url = activity.otml_url(@user, self, {:nobundles => nobundles, :reporting => reporting, :savedata => savedata, :authoring => authoring})
    if group_id
      if setup_default_overlay(learner.runnable.id, group_id)
        @group_overlay_url = "#{OVERLAY_SERVER_ROOT}/#{learner.runnable.id}/#{group_id}.otml"
      end
    end
    if setup_default_overlay(learner.runnable.id, learner.id)
      @learner_overlay_url = "#{OVERLAY_SERVER_ROOT}/#{learner.runnable.id}/#{learner.id}.otml"
    end
    
    setup_overlay_requirements(activity)
    
    # otherwise render the default template
    render(:template => 'shared/overlay_otml.builder', :layout => false)
  end

  def sail_jnlp
    if params[:run_activity]
      @user = current_user
    else
      @user = User.find(params[:uid])
    end
    savedata = params[:savedata]
    authoring = params[:authoring]
    reporting = params[:reporting]
    # params[:nobundles] == nil => false
    # params[:nobundles] == '' => false
    # params[:nobundles] == anything else => true
    nobundles = ((params[:nobundles] && ! params[:nobundles].empty?) ? true : false)
    useOverlay = USE_OVERLAYS && OVERLAY_SERVER_ROOT
    redirect_to @external_otrunk_activity.sds_url(@user, self, {:use_overlay => useOverlay, :nobundles => nobundles, :reporting => reporting, :savedata => savedata, :authoring => authoring, :group_id => params[:group_id]})
  end
  
  def html_export_jnlp
    if params[:run_activity]
      @user = current_user
    else
      @user = User.find(params[:uid])
    end
    savedata = params[:savedata]
    authoring = params[:authoring]
    reporting = params[:reporting]
    # params[:nobundles] == nil => false
    # params[:nobundles] == '' => false
    # params[:nobundles] == anything else => true
    nobundles = ((params[:nobundles] && ! params[:nobundles].empty?) ? true : false)
    
    redirect_to @external_otrunk_activity.html_export_url(@user, self, {:nobundles => nobundles, :reporting => reporting, :savedata => savedata, :authoring => authoring})
  end

  def usage
    @learners = @external_otrunk_activity.learners.select {|l| l.learner_sessions.count > 0 }
  end
  
  def compare
    @other_activity = ExternalOtrunkActivity.find(params[:other])
  end
  
end
