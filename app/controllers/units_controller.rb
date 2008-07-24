class UnitsController < ApplicationController
  
  access_rule 'admin', :only => :destroy
  access_rule 'admin || manager', :only => [:new, :edit, :create, :update, :copy]
  
  
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy, :otml, :sail_jnlp ]

  protected
  
  def setup_object
    if params[:id]
      @user = User.find(params[:id])
    elsif params[:user]
      @user = User.new(params[:user])
    else
      @user = User.new
    end
    @class_name = @user.class.to_s.underscore
    @class_name_titleized = @class_name.titleize
  end

  def find_collections
    @all_viewable_users = User.find(:all)
    @all_editable_users = @all_viewable_users
  end

  public
  
  # GET /units
  # GET /units.xml
  def index
#    @units = Unit.find(:all)
    @units = Unit.paginate :page => params[:page]
    @paginated_objects = @units
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @units }
    end
  end

  # GET /units/1
  # GET /units/1.xml
  def show
    @unit = Unit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @unit }
    end
  end

  # GET /units/new
  # GET /units/new.xml
  def new
    @unit = Unit.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @unit }
    end
  end

  # GET /units/1/edit
  def edit
    @unit = Unit.find(params[:id])
  end

  # POST /units
  # POST /units.xml
  def create
    @unit = Unit.new(params[:unit])

    respond_to do |format|
      if @unit.save
        flash[:notice] = 'Unit was successfully created.'
        format.html { redirect_to(@unit) }
        format.xml  { render :xml => @unit, :status => :created, :location => @unit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @unit.errors }
      end
    end
  end

  # PUT /units/1
  # PUT /units/1.xml
  def update
    @unit = Unit.find(params[:id])

    respond_to do |format|
      if @unit.update_attributes(params[:unit])
        flash[:notice] = 'Unit was successfully updated.'
        format.html { redirect_to(@unit) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @unit.errors }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.xml
  def destroy
    @unit = Unit.find(params[:id])
    @unit.destroy

    respond_to do |format|
      format.html { redirect_to(units_url) }
      format.xml  { head :ok }
    end
  end
end
