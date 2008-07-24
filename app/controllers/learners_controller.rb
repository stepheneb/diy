class LearnersController < ApplicationController

  layout "standard"
  before_filter :login_required
  access_rule 'admin || manager', :only => [:edit, :destroy]
  
  before_filter :setup_object
  before_filter :find_collections, :except => :destroy

  protected

  def setup_object
    if params[:id]
      @learner = Learner.find(params[:id])
    elsif params[:activity]
      @learner = Learner.new(params[:learner])
    else
      @learner = Learner.new
    end
    @class_name = @learner.class.to_s.underscore
    @class_name_titleized = @class_name.titleize
  end

  def find_collections
    if params[:user_id]
      user = User.find(params[:user_id])
      @all_viewable_learners = user.learners
      @all_editable_learners = @all_viewable_learners
    elsif params[:activity_id]
      activity = Activity.find(params[:activity_id])
      @all_viewable_learners = activity.learners
      @all_editable_learners = @all_viewable_learners
    elsif params[:external_otrunk_activity_id]
      external_otrunk_activity = ExternalOtrunkActivity.find(params[:external_otrunk_activity_id])
      @all_viewable_learners = external_otrunk_activity.learners
      @all_editable_learners = @all_viewable_learners
    else
      @all_viewable_learners = Learner.find(:all)
      @all_editable_learners = Learner.find_all_by_user_id(current_user.id)
    end
  end

  public

  # GET /learners/1/ot_learner_data.xml
  def ot_learner_data
    otdata = @learner.ot_learner_data
    respond_to do |format|
      # format.html # show.html.erb
      format.xml  { render :xml => otdata }
    end
  end

  # GET /learners/1/sessions.xml
  def sessions
    @sessions = @learner.learner_sessions
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sessions }
    end
  end


  # GET /learners
  # GET /learners.xml
  def index
    @learners = Learner.paginate :page => params[:page]
    @paginated_objects = @learners
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @all_viewable_learners }
    end
  end

  # GET /learners/1
  # GET /learners/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @learner }
    end
  end

  # GET /learners/new
  # GET /learners/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @learner }
    end
  end

  # GET /learners/1/edit
  def edit
  end

  # POST /learners
  # POST /learners.xml
  def create
    respond_to do |format|
      if @learner.save
        flash[:notice] = 'Learner was successfully created.'
        format.html { redirect_to(@learner) }
        format.xml  { render :xml => @learner, :status => :created, :location => @learner }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @learner.errors }
      end
    end
  end

  # PUT /learners/1
  # PUT /learners/1.xml
  def update
    respond_to do |format|
      if @learner.update_attributes(params[:learner])
        flash[:notice] = 'Learner was successfully updated.'
        format.html { redirect_to(@learner) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @learner.errors }
      end
    end
  end

  # DELETE /learners/1
  # DELETE /learners/1.xml
  def destroy
    @learner.destroy
    respond_to do |format|
      format.html { redirect_to(learners_url) }
      format.xml  { head :ok }
    end
  end
end
