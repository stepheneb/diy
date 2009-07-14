class ModelsController < ApplicationController
  # GET /models
  # GET /models.xml 

  access_rule 'admin || manager || teacher || member', :only => [:new, :edit, :create, :update, :copy, :destroy]

  layout "standard"

  before_filter :setup_vars
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy, :otml, :sail_jnlp ]
  before_filter :get_learner, :only => [:show, :edit, :update]

  protected
  
  def setup_vars
    @class_name = Model.to_s.underscore
    @class_name_titleized = @class_name.titleize
    @searchable_attributes = Model.searchable_attributes
  end
  
  def setup_object
    if params[:id]
      if params[:id].length == 36
        @model = Model.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @model = Model.find(params[:id])
      end
    elsif params[:model]
      @model = Model.new(params[:model])
    else
      @model = Model.new
    end
  end

  def find_collections
    @all_viewable_models = Model.find(:all, :conditions => "public=true or user_id='#{current_user.id}'")
    @all_editable_models = Model.find_all_by_user_id(current_user.id)
  end
  
  def get_learner
    @learner = @model.find_or_create_learner(current_user)
  end

  public

  def ot_learner_data
    @learners = @model.learners
    # setup overlay folder. These overlay files hold per-user customizations to the activity.
    @useOverlays = setup_overlay_folder(@model.id)
    
    if @useOverlays && params[:overlay_root]
      @overlay_root = params[:overlay_root]
    end
    
    if @useOverlays && params[:overlay_params]
      @overlay_params = params[:overlay_params]
    end
    
    render(:template => "shared/ot_learner_data.builder", :layout => false)
  end

  def index
    @models = Model.search(params[:search], params[:page], current_user)
    @paginated_objects = @models
    current_user.vendor_interface ||= VendorInterface.find(6)
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @all_viewable_models.to_xml }
    end
  end

  # GET /models/1
  # GET /models/1.xml
  def show
    @model = Model.find(params[:id])
    @model_activities = @model.activities.select {|a| a.contains_active_model(@model) }
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @model.to_xml }
    end
  end

  # GET /models/new
  def new
    @model = Model.new
    @model.model_type = ModelType.find_by_authorable(true)
    @model.snapshot_active = true
    @model.textile = true
    @model.public = true
    @model.user = current_user
  end

  # GET /models/1/edit
  def edit
    @model = Model.find(params[:id])
  end

  # POST /models
  # POST /models.xml
  def create
    @model = Model.new(params[:model])
    @model.user = current_user
    respond_to do |format|
      if @model.save
        flash[:notice] = 'Model was successfully created.'
        format.html { redirect_to model_url(@model) }
        format.xml  { head :created, :location => model_url(@model) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @model.errors.to_xml }
      end
    end
  end

  # PUT /models/1
  # PUT /models/1.xml
  def update
    @model = Model.find(params[:id])
    respond_to do |format|
      if @model.update_attributes(params[:model])
        flash[:notice] = 'Model was successfully updated.'
        format.html { redirect_to model_url(@model) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @model.errors.to_xml }
      end
    end
  end

  # DELETE /models/1
  # DELETE /models/1.xml
  def destroy
    @model = Model.find(params[:id])
    @model.destroy

    respond_to do |format|
      format.html { redirect_to models_url }
      format.xml  { head :ok }
    end
  end
  
  def copy
    @parent = Model.find(params[:id])
    @model = @parent.clone
    @model.user = current_user
    @model.public = false
    @model.name << " (copy)"
    @model.uuid = nil
    @model.parent = @parent
    @model.parent_version = @parent.version
    render :action => 'new'
  end

  def otml
    @model = Model.find(params[:id])
    @vendor_interface = current_user.vendor_interface
    @probetypes = ProbeType.find(:all)
    if params[:lid]
      @learner = Learner.find(params[:lid])
    else
      @learner = @model.find_or_create_learner(current_user)
    end
    @savedata = params[:savedata]
    response.headers["Content-Type"] = "text/xml"
    render :layout => false
  end
  
  def overlay_otml
    @user = User.find(params[:uid])
    activity = @model
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

  def usage
    @learners = @model.learners.select {|l| l.learner_sessions.length > 0 }
  end

  def sail_jnlp
    if params[:run_activity]
      @user = current_user
    else
      @user = User.find(params[:uid])
    end
    savedata = params[:savedata]
    authoring = params[:authoring]
    # params[:nobundles] == nil => false
    # params[:nobundles] == '' => false
    # params[:nobundles] == anything else => true
    nobundles = ((params[:nobundles] && ! params[:nobundles].empty?) ? true : false)
    # public_group = Group.find_by_name('Public')
    # m = Membership.find(:first, :conditions => ["user_id = ? and group_id = ?", current_user, public_group.id])

    redirect_to @model.sds_url(@user, self, {:nobundles => nobundles, :reporting => false, :savedata => savedata, :authoring => authoring, :alternative_export => true})
  end
  
  def compare
    @other_model = Model.find(params[:other])
  end
  
end
