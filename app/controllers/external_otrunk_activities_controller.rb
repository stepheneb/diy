require 'hpricot'

class ExternalOtrunkActivitiesController < ApplicationController
  include ReportableController 
  # GET /external_otrunk_activities
  # GET /external_otrunk_activities.xml
  access_rule 'admin || manager || teacher || member', :only => [:new, :edit, :create, :update, :copy, :destroy]
  access_rule 'admin', :only => [:usage]

  layout "standard"

  before_filter :setup_vars
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy, :otml, :sail_jnlp, :run_report ]
  before_filter :get_learner, :only => [:show, :edit, :update]

  protected

  def setup_vars
    @class_name = ExternalOtrunkActivity.to_s.underscore
    @class_name_titleized = APP_PROPERTIES[:external_otrunk_activities_title].singularize
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

  def get_reportable
    return @external_otrunk_activity
  end

  public
    

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
    exceptions = []
    if params[:except]
      exceptions = params[:except].split(",")
    end
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @external_otrunk_activity.to_xml(:except => exceptions) }
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
    find_vendor_interface
    activity = @external_otrunk_activity
    learner = activity.find_or_create_learner(@user)
    group_id = params[:group_id]
    group_list_url = params[:group_list_url]
    group_list = params[:group_list]
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
    if setup_default_overlay(learner.runnable.id, learner.id)
      @learner_overlay_url = "#{get_overlay_server_root}/#{learner.runnable.id}/#{learner.id}.otml"
    end
    
    @learners = [learner]
    # if we have a group_list_url, use it and don't bother setting up the @learners array
    if group_list_url
      @userListURL = group_list_url
    else
      if (group_list && ! group_list.empty?)
        uids = group_list.split(",")
        uids.each do |uid|
          begin
            @learners << activity.find_or_create_learner(User.find(uid))
          rescue
            # ignore it for now
          end
        end
      end
    end
    
    @learners.uniq!
    
    setup_overlay_requirements(activity.otml)
    
    if @learners.size > 0 || @userListURL
      @imports << "org.concord.otrunk.view.OTGroupListManager"
      @imports << "org.concord.otrunk.view.OTGroupMember"
      @imports << "org.concord.otrunk.user.OTUserObject"
    end
    
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
    useOverlay = USE_OVERLAYS && get_overlay_server_root
        
    redirect_to @external_otrunk_activity.sds_url(@user, self, {:use_overlay => useOverlay, :nobundles => nobundles, :reporting => reporting, :savedata => savedata, :authoring => authoring, :group_id => params[:group_id], :group_list => params[:group_list], :group_list_url => params[:group_list_url]})
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
  
  def run_report
    if params[:type]
      @reports = @external_otrunk_activity.reports.select{|r| r.report_types.select{|rt| rt.uri == params[:type] }.size > 0 }
    else
      @reports = @external_otrunk_activity.reports
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
        format.html {render :text => "Report not found", :status => 404 }
        format.xml {render :xml => "<report-not-found />", :status => 404 }
      end
    end
  end
  
  def find_vendor_interface
    unless defined? @vendor_interface
      if (params[:vid])
        @vendor_interface = VendorInterface.find(params[:vid])
      end
    end
  end

  
end
