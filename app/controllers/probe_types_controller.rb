class ProbeTypesController < ApplicationController
  # GET /probe_types
  # GET /probe_types.xml
  
  access_rule 'admin', :only => [:new, :edit, :create, :update, :destroy]
  access_rule 'admin || manager', :only => [:index, :show]
  
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy, :otml, :sail_jnlp ]

  protected
  
  def setup_object
    if params[:id]
      @probe_type = ProbeType.find(params[:id])
    elsif params[:probe_type]
      @probe_type = ProbeType.new(params[:probe_type])
    else
      @probe_type = ProbeType.new
    end
    @class_name = @probe_type.class.to_s.underscore
    @class_name_titleized = @class_name.titleize
  end

  def find_collections
    @all_viewable_probe_types = ProbeType.find(:all)
    @all_editable_probe_types = @all_viewable_probe_types
  end

  public
  
  def index
    @probe_types = ProbeType.paginate :page => params[:page]
    @paginated_objects = @probe_types
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @probe_types.to_xml }
    end
  end

  # GET /probe_types/1
  # GET /probe_types/1.xml
  def show
#    @probe_types = ProbeType.find(params[:id])
    @probe_types = ProbeType.paginate :page => params[:page]
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @probe_type.to_xml }
    end
  end

  # GET /probe_types/new
  def new
    @probe_type = ProbeType.new
  end

  # GET /probe_types/1/edit
  def edit
    @probe_type = ProbeType.find(params[:id])
  end

  # POST /probe_types
  # POST /probe_types.xml
  def create
    @probe_type = ProbeType.new(params[:probe_type])

    respond_to do |format|
      if @probe_type.save
        flash[:notice] = 'ProbeType was successfully created.'
        format.html { redirect_to probe_type_url(@probe_type) }
        format.xml  { head :created, :location => probe_type_url(@probe_type) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @probe_type.errors.to_xml }
      end
    end
  end

  # PUT /probe_types/1
  # PUT /probe_types/1.xml
  def update
    @probe_type = ProbeType.find(params[:id])

    respond_to do |format|
      if @probe_type.update_attributes(params[:probe_type])
        flash[:notice] = 'ProbeType was successfully updated.'
        format.html { redirect_to probe_type_url(@probe_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @probe_type.errors.to_xml }
      end
    end
  end

  # DELETE /probe_types/1
  # DELETE /probe_types/1.xml
  def destroy
    @probe_type = ProbeType.find(params[:id])
    @probe_type.destroy

    respond_to do |format|
      format.html { redirect_to probe_types_url }
      format.xml  { head :ok }
    end
  end
end
