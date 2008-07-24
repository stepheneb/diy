class PhysicalUnitsController < ApplicationController

  access_rule 'admin', :only => :destroy
  access_rule 'admin || manager', :only => [:new, :edit, :create, :update, :copy]
  access_rule 'admin || manager || teacher || member', :only => [:index, :show]

  layout "standard"
  
  before_filter :setup_vars
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy]

  protected
  
  def setup_vars
    @class_name = PhysicalUnit.to_s.underscore
    @class_name_titleized = @class_name.titleize
    @searchable_attributes = PhysicalUnit.searchable_attributes
  end
  
  def setup_object
    if params[:id]
      @physical_unit = PhysicalUnit.find(params[:id])
    elsif params[:physical_unit]
      @physical_unit = PhysicalUnit.new(params[:physical_unit])
    else
      @physical_unit = PhysicalUnit.new
    end
  end

  def find_collections
    @all_viewable_physical_units = PhysicalUnit.find(:all)
    @all_editable_physical_units = @all_viewable_physical_units
  end

  public

  # GET /physical_units
  # GET /physical_units.xml
  def index
    @physical_units = PhysicalUnit.search(params[:search], params[:page], current_user)   
    @paginated_objects = @physical_units
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @all_viewable_physical_units }
    end
  end

  # GET /physical_units/1
  # GET /physical_units/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @physical_unit }
    end
  end

  # GET /physical_units/new
  # GET /physical_units/new.xml
  def new
    @physical_unit.user = current_user
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @physical_unit }
    end
  end

  # GET /physical_units/1/edit
  def edit
  end

  # POST /physical_units
  # POST /physical_units.xml
  def create
    @physical_unit.user = current_user
    respond_to do |format|
      if @physical_unit.save
        flash[:notice] = 'PhysicalUnit was successfully created.'
        format.html { redirect_to(physical_units_path) }
        format.xml  { render :xml => @physical_unit, :status => :created, :location => @physical_unit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @physical_unit.errors }
      end
    end
  end

  # PUT /physical_units/1
  # PUT /physical_units/1.xml
  def update
    @physical_unit.user = current_user
    respond_to do |format|
      if @physical_unit.update_attributes(params[:physical_unit])
        flash[:notice] = 'PhysicalUnit was successfully updated.'
        format.html { redirect_to(physical_units_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @physical_unit.errors }
      end
    end
  end

  # DELETE /physical_units/1
  # DELETE /physical_units/1.xml
  def destroy
    @physical_unit.destroy
    respond_to do |format|
      format.html { redirect_to(physical_units_url) }
      format.xml  { head :ok }
    end
  end
  
  def copy
    @physical_unit = @physical_unit.clone
    @physical_unit.user = current_user
    @physical_unit.name << " (copy)"
    render :action => 'new'
  end 
end
