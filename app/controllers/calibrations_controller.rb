class CalibrationsController < ApplicationController

  access_rule 'admin', :only => :destroy
  access_rule 'admin || manager', :only => [:new, :edit, :create, :update, :copy]
  access_rule 'admin || manager || teacher || member', :only => [:index, :show]

  layout "standard"

  before_filter :setup_vars  
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy, :otml, :sail_jnlp ]

  protected
  
  def setup_vars
    @class_name = Calibration.to_s.underscore
    @class_name_titleized = @class_name.titleize
    @searchable_attributes = Calibration.searchable_attributes
  end
  
  def setup_object
    if params[:id]
      @calibration = Calibration.find(params[:id])
    elsif params[:calibration]
      @calibration = Calibration.new(params[:calibration])
    else
      @calibration = Calibration.new
    end
    @class_name = @calibration.class.to_s.underscore
    @class_name_titleized = @class_name.titleize
  end

  def find_collections
    @all_viewable_calibrations = Calibration.find(:all)
    @all_editable_calibrations = @all_viewable_calibrations
  end

  public

  # GET /calibrations
  # GET /calibrations.xml
  def index
    @calibrations = Calibration.search(params[:search], params[:page], current_user)
    @paginated_objects = @calibrations
    params[:list_conditions] = 'all'
    session[:page] = params[:page] || 1   
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @all_viewable_calibrations }
    end
  end

  # GET /calibrations/1
  # GET /calibrations/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @calibration }
    end
  end

  # GET /calibrations/new
  # GET /calibrations/new.xml
  def new
    @calibration = Calibration.new
    @calibration.user = current_user
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @calibration }
    end
  end

  # GET /calibrations/1/edit
  def edit
  end

  # POST /calibrations
  # POST /calibrations.xml
  def create
    @calibration.user = current_user
    respond_to do |format|
      if @calibration.save
        flash[:notice] = 'Calibration was successfully created.'
        format.html { redirect_to(@calibration) }
        format.xml  { render :xml => @calibration, :status => :created, :location => @calibration }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @calibration.errors }
      end
    end
  end

  # PUT /calibrations/1
  # PUT /calibrations/1.xml
  def update
    @calibration.user = current_user
    respond_to do |format|
      if @calibration.update_attributes(params[:calibration])
        flash[:notice] = 'Calibration was successfully updated.'
        format.html { redirect_to(@calibration) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @calibration.errors }
      end
    end
  end

  # DELETE /calibrations/1
  # DELETE /calibrations/1.xml
  def destroy
    @calibration.destroy
    respond_to do |format|
      format.html { redirect_to(calibrations_url) }
      format.xml  { head :ok }
    end
  end
  
  def copy
    @calibration = @calibration.clone
    @calibration.user = current_user
    @calibration.name << " (copy)"
    render :action => 'new'
  end
  
  def data_filter_parameters
    data_filter = DataFilter.find(params[:data_filter_id])
    render :partial => 'data_filter_parameters', :locals => { :data_filter => data_filter }
  end
end
