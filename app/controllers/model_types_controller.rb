class ModelTypesController < ApplicationController
  # GET /model_types
  # GET /model_types.xml
  
  access_rule 'admin', :only => :destroy
  access_rule 'admin || manager', :only => [:new, :edit, :create, :update, :copy]
  access_rule 'admin || manager || teacher || member', :only => [:index, :show]
  
  layout "standard"
  
  before_filter :setup_vars
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy, :otml, :sail_jnlp ]

  protected
  
  def setup_vars
    @class_name = ModelType.to_s.underscore
    @class_name_titleized = @class_name.titleize
    @searchable_attributes = ModelType.searchable_attributes
  end
  
  def setup_object
    if params[:id]
      @model_type = ModelType.find(params[:id])
    elsif params[:model_type]
      @model_type = ModelType.new(params[:model_type])
    else
      @model_type = ModelType.new
    end
  end

  def find_collections
    @all_viewable_model_types = ModelType.find(:all)
    @all_editable_model_types = ModelType.find_all_by_user_id(current_user.id)
  end

  public
  
  def index
    @model_types = ModelType.search(params[:search], params[:page], current_user)
    @paginated_objects = @model_types
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @all_viewable_model_types.to_xml }
    end
  end

  # GET /model_types/1
  # GET /model_types/1.xml
  def show
    @model_type = ModelType.find(params[:id])
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @model_type.to_xml }
    end
  end

  # GET /model_types/new
  def new
    @model_type = ModelType.new
    @model_type.user = current_user
  end

  # GET /model_types/1/edit
  def edit
    @model_type = ModelType.find(params[:id])
  end

  # POST /model_types
  # POST /model_types.xml
  def create
    @model_type = ModelType.new(params[:model_type])
    @model_type.user = current_user
    respond_to do |format|
      if @model_type.save
        flash[:notice] = 'ModelType was successfully created.'
        format.html { redirect_to model_type_url(@model_type) }
        format.xml  { head :created, :location => model_type_url(@model_type) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @model_type.errors.to_xml }
      end
    end
  end

  # PUT /model_types/1
  # PUT /model_types/1.xml
  def update
    @model_type = ModelType.find(params[:id])
    respond_to do |format|
      if @model_type.update_attributes(params[:model_type])
        flash[:notice] = 'ModelType was successfully updated.'
        format.html { redirect_to model_type_url(@model_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @model_type.errors.to_xml }
      end
    end
  end

  # DELETE /model_types/1
  # DELETE /model_types/1.xml
  def destroy
    @model_type = ModelType.find(params[:id])
    @model_type.destroy

    respond_to do |format|
      format.html { redirect_to model_types_url }
      format.xml  { head :ok }
    end
  end
  
  def copy
    @model_type = ModelType.find(params[:id]).clone
    @model_type.user = current_user
    @model_type.name << " (copy)"
    render :action => 'new'
  end
end
