class LevelsController < ApplicationController
  
  access_rule 'admin', :only => :destroy
  access_rule 'admin || manager', :only => [:new, :edit, :create, :update, :copy]

    access_rule 'admin || manager', :only => [:edit, :destroy]

#  layout "standard"
  before_filter :login_required
  before_filter :setup_object
  before_filter :find_collections, :except => :destroy

  protected

  def setup_object
    if params[:id]
      @level = Level.find(params[:id])
    elsif params[:level]
      @level = Level.new(params[:level])
    else
      @level = Level.new
    end
    @class_name = @level.class.to_s.underscore
    @class_name_titleized = @class_name.titleize
  end

  def find_collections
    if params[:unit]
      unit = Unit.find(params[:unit_id])
      @all_viewable_levels = unit.levels
      @all_editable_levels = @all_viewable_levels
    elsif params[:activity_id]
      activity = Activity.find(params[:activity_id])
      @all_viewable_levels = activity.levels
      @all_editable_levels = @all_viewable_levels
    else
      @all_viewable_levels = Level.find(:all)
      @all_editable_levels = @all_viewable_levels
    end
  end

  public

  
  # GET /levels
  # GET /levels.xml
  def index
#    @levels = Level.find(:all)
    @levels = Level.paginate :page => params[:page]
    @paginated_objects = @levels
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @levels }
    end
  end

  # GET /levels/1
  # GET /levels/1.xml
  def show
    @level = Level.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @level }
    end
  end

  # GET /levels/new
  # GET /levels/new.xml
  def new
    @level = Level.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @level }
    end
  end

  # GET /levels/1/edit
  def edit
    @level = Level.find(params[:id])
  end

  # POST /levels
  # POST /levels.xml
  def create
    @level = Level.new(params[:level])

    respond_to do |format|
      if @level.save
        flash[:notice] = 'Level was successfully created.'
        format.html { redirect_to(@level) }
        format.xml  { render :xml => @level, :status => :created, :location => @level }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @level.errors }
      end
    end
  end

  # PUT /levels/1
  # PUT /levels/1.xml
  def update
    @level = Level.find(params[:id])

    respond_to do |format|
      if @level.update_attributes(params[:level])
        flash[:notice] = 'Level was successfully updated.'
        format.html { redirect_to(@level) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @level.errors }
      end
    end
  end

  # DELETE /levels/1
  # DELETE /levels/1.xml
  def destroy
    @level = Level.find(params[:id])
    @level.destroy

    respond_to do |format|
      format.html { redirect_to(levels_url) }
      format.xml  { head :ok }
    end
  end
end
