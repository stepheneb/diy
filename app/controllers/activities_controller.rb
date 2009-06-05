require 'open-uri'
class ActivitiesController < ApplicationController

  access_rule 'admin || manager || teacher || member', :only => [:create, :edit, :copy, :destroy, :usage]
  
  layout "standard", :except => [:otml, :sail_jnlp, :check_xhtml, :save_draft]

  before_filter :login_required

  # before_filter do |controller|
  #       debugger
  #   @class_name = Activity.to_s.underscore
  #   @class_name_titleized = @class_name.titleize
  # end
  
  before_filter :setup_vars
  before_filter :setup_object, :except => [:index]
  before_filter :find_collections, :except => [:destroy, :otml, :sail_jnlp ]
  before_filter :get_learner, :only => [:show, :edit, :update]

  # caches_page :index
  
  protected

  def setup_vars
    @class_name = Activity.to_s.underscore
    @class_name_titleized = @class_name.titleize
    @searchable_attributes = Activity.searchable_attributes
  end
  
  def setup_object
    if params[:id]
      if params[:id].length == 36
        @activity = Activity.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @activity = Activity.find(params[:id])
      end
    elsif params[:activity]
      @activity = Activity.new(params[:activity])
    else
      @activity = Activity.new
    end
  end

  def find_collections
    if params[:user_id]
      user = User.find(params[:user_id])
      @all_viewable_activities = user.activities
      @all_editable_activities = @all_viewable_activities
    elsif params[:unit_id]
      unit = Unit.find(params[:unit_id])
      @all_viewable_activities = unit.activities
      @all_editable_activities = @all_viewable_activities
    else
      @all_viewable_activities = Activity.find(:all, :conditions => "public=true or user_id='#{current_user.id}'", :order => 'name')
      @all_editable_activities = @all_viewable_activities.find_all{|a| a.user_id == current_user.id}
    end
  end
  
  def get_learner
    @learner = @activity.find_or_create_learner(current_user)
  end

  public
  
  # GET /learners/1/ot_learner_data.xml
  def ot_learner_data
    @learners = @activity.learners
    # setup overlay folder. These overlay files hold per-user customizations to the activity.
    @useOverlays = setup_overlay_folder(@activity.id)
    
    if @useOverlays && params[:overlay_root]
      @overlay_root = params[:overlay_root]
    end
    
    if @useOverlays && params[:overlay_params]
      @overlay_params = params[:overlay_params]
    end
    
    render(:template => "shared/ot_learner_data.builder", :layout => false)
  end
  
  # GET /activities
  # GET /activities.xml
  def index
    @activities = Activity.search(params[:search], params[:page], current_user, [{:learners => :learner_sessions}])
    @paginated_objects = @activities
    current_user.vendor_interface ||= VendorInterface.find(6)
    params[:list_conditions] = 'all'
    session[:page] = params[:page] || 1
    respond_to do |format|
      format.html do # index.rhtml
        params[:list_conditions] = 'all'
        session[:page] = params[:page] || 1
      end
      format.xml  { render :xml => @all_viewable_activities.to_xml }
    end
  end

  # GET /activities/1
  # GET /activities/1.xml
  def show
    @learner = @activity.find_or_create_learner(current_user)
    respond_to do |format|
#      format.html { render :layout => 'layouts/show_activity' } # show.rhtml
      format.html # show.rhtml
      format.xml  { render :xml => @activity.to_xml }
    end
  end

  # GET /activities/new
  def new
    @activity.public = false
    @activity.textile = true
    @activity.user = current_user
  end

  # GET /activities/1/edit
  def edit
    activity_draft = session[:activity_draft]
    if activity_draft && activity_draft[:activity][:id] == params[:id]
      @activity.attributes = activity_draft[:activity]
      flash[:notice] = "Activity restored from a draft saved #{help.distance_of_time_in_words(activity_draft[:time], Time.now)} ago. Use either <b>Save</b> button to save your changes permanently." 
    end
    session[:activity_draft] = nil
  end

  # POST /activities
  # POST /activities.xml
  def create
    if params[:commit] == "Cancel"
      session[:activity_draft] = nil # delete any saved draft
      redirect_to activities_url
    else
      @activity.user = current_user
      respond_to do |format|
        if @activity.save
          flash[:notice] = "#{@class_name_titleized}: #{@activity.name} was successfully created."
          format.html do
            if params[:commit] == "Create and keep editing"
              redirect_to edit_activity_url(@activity)
            else
              redirect_to activity_url(@activity)
            end
          end
          format.xml  { head :created, :location => activity_url(@activity) }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @activity.errors.to_xml }
        end
      end
    end
  end

  # PUT /activities/1
  # PUT /activities/1.xml
  def update
    if params[:commit] == "Cancel"
      session[:activity_draft] = nil # delete any saved draft
      redirect_to activities_url
    else
      respond_to do |format|
        if @activity.update_attributes(params[:activity])
          session[:activity_draft] = nil # delete any saved draft
          format.html do 
            flash[:notice] = "#{@class_name_titleized}: #{@activity.name} was successfully updated."
            if params[:commit] == "Save and keep editing"
              redirect_to edit_activity_url(@activity)
            else
              redirect_to activity_url(@activity)
            end
          end
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @activity.errors.to_xml }
        end
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.xml
  def destroy
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to(:action => 'index', :page => params[:page] || 1) }
      format.xml  { head :ok }
    end
  end
  
  # You can also copy from another diy with this form of url:
  #   /activities/1/copy?copyfrom=http://another_diy_instance/page/show/1.xml
  # This would copy activity #1 from http://another_diy_instance
  def copy
    if params[:copyfrom]
      h = Hash.from_xml(open(params[:copyfrom]))
      if a = h['activity']
        @activity = Activity.new(a)
      end
    else
      id = params[:id]
      @parent = Activity.find(id)
      @activity = @parent.clone
    end
    @activity.user = current_user
    @activity.public = false
    @activity.name << " (copy)"
    @activity.uuid = nil
    unless params[:copyfrom]
      @activity.parent = @parent unless params[:copyfrom]
      @activity.parent_version = @parent.version
    end
    render :action => 'new'
  end
    
  def usage
    @learners = @activity.learners.select {|l| l.learner_sessions.length > 0 }
  end

  def save_draft
    activity = params[:activity]
    activity[:id] = params[:id] unless params[:id] == nil    
    activity[:user_id] = current_user.id
    session[:activity_draft] = {:activity => activity, :time => Time.now}
    render :text => "Draft saved at #{Time.now.strftime("at %I:%M%p")}. Use either <b>Save</b> button to save your changes permanently." 
  end
  
  def check_xhtml
    render :layout => false
  end
  
  # needs set_current_user_vendor_interface in controller

  def sail_jnlp
    @activity = Activity.find(params[:id])
    if params[:run_activity]
      @user = current_user
      @vendor_interface = current_user.vendor_interface    
    else
      @user = User.find(params[:uid])
      @vendor_interface = VendorInterface.find(params[:vid])
    end
    savedata = params[:savedata]
    authoring = params[:authoring]
    # params[:nobundles] == nil => false
    # params[:nobundles] == '' => false
    # params[:nobundles] == anything else => true
    nobundles = ((params[:nobundles] && ! params[:nobundles].empty?) ? true : false)

    redirect_to @activity.sds_url(@user, self, {:nobundles => nobundles, :reporting => false, :savedata => savedata, :authoring => authoring})
  end

  def otml
    # dynamically generate an activity otml file
    # here's the map from routes.rb:
    # map.jnlp 'page/otml/:vid/:id', :controller => 'page', :action => 'otml'
    # :vid is the vendor_interface id (see the model vendor_interface.rb)
    # :id is the activity id
    # this results in urls like the following:
    #   http://host.com/page/otml/4/2
    # the '4' is the vendor_interface id (in this case the Pasco AirLink SI)
    # the '2' is the id of the activity
    @probetypes = ProbeType.find(:all)
    response.headers["Content-Type"] = "text/xml"
    @activity = Activity.find(params[:id])
    @vendor_interface = VendorInterface.find(params[:vid])
    if params[:lid]
      @learner = Learner.find(params[:lid])
    else
      # when using the simplified otml route, don't set @learner so that the
      # activity preamble doesn't display
      # this is used for the Wise step-type converter to make a cleaner export
      @learner = nil
    end
    @savedata = params[:savedata]
    @nobundles = params[:nobundles] == 'nobundles'
    render :layout => false
  end
  
  def overlay_otml
    @user = User.find(params[:uid])
    activity = @activity
    learner = activity.find_or_create_learner(@user)
    group_id = params[:group_id]
    savedata = params[:savedata]
    authoring = params[:authoring]
    reporting = params[:reporting]
    nobundles = ((params[:nobundles] && ! params[:nobundles].empty?) ? true : false)
    
    @activity_otml_url = activity.otml_url(@user, self, {:nobundles => nobundles, :reporting => reporting, :savedata => savedata, :authoring => authoring})
    if group_id
      if setup_default_overlay(learner.runnable.id, group_id)
        @group_overlay_url = "#{get_overlay_server_root}/#{learner.runnable.id}/#{group_id}.otml"
      end
    end
    setup_default_overlay(learner.runnable.id, learner.id)
    @learner_overlay_url = "#{get_overlay_server_root}/#{learner.runnable.id}/#{learner.id}.otml"
    
    setup_overlay_requirements(activity)
    
    # otherwise render the default template
    render(:template => 'shared/overlay_otml.builder', :layout => false)
  end
  
  def probe_type_calibrations
    probe_type = ProbeType.find(params[:activity_probe_type_id])
    calibrations = probe_type.calibrations
    render :partial => 'probe_type_calibrations', :locals => { :calibrations => calibrations }
  end
  
  def compare
    @other_activity = Activity.find(params[:other])
  end
  
  def run_report
    if params[:type]
      @reports = @activity.reports.select{|r| r.report_type.uri == params[:type] }
    else
      @reports = @activity.reports
    end
    
    extras = params.clone
    extras.delete(:action)
    extras.delete(:controller)
    extras.delete(:id)
    extras.delete(:type)
    
    if @reports.size > 0
      redirect_to sail_jnlp_report_path(@reports[0], extras)
    else
      respond_to do |format|
        format.html { render :head, :status => 404 }
        format.xml { render :head, :status => 404 }
      end
    end
  end

end
