class DataFiltersController < ApplicationController

  access_rule 'admin', :only => :destroy
  access_rule 'admin || manager', :only => [:new, :edit, :create, :update, :copy]
  access_rule 'admin || manager || teacher || member', :only => [:index, :show]

  layout "standard"
  
  before_filter :setup_vars
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy, :otml, :sail_jnlp ]

  protected
  
  def setup_vars
    @class_name = DataFilter.to_s.underscore
    @class_name_titleized = @class_name.titleize
    @searchable_attributes = DataFilter.searchable_attributes
  end

  def setup_object
    if params[:id]
      @data_filter = DataFilter.find(params[:id])
    elsif params[:data_filter]
      @data_filter = DataFilter.new(params[:data_filter])
    else
      @data_filter = DataFilter.new
    end
  end

  def find_collections
    @all_viewable_data_filters = DataFilter.find(:all)
    @all_editable_data_filters = @all_viewable_data_filters
  end

  public

  # GET /data_filters
  # GET /data_filters.xml
  def index
    @data_filters = DataFilter.search(params[:search], params[:page], current_user)
    @paginated_objects = @data_filters
    params[:list_conditions] = 'all'
    session[:page] = params[:page] || 1   
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @all_viewable_data_filters }
    end
  end

  # GET /data_filters/1
  # GET /data_filters/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @data_filter }
    end
  end

  # GET /data_filters/new
  # GET /data_filters/new.xml
  def new
    @data_filter.user = current_user
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @data_filter }
    end
  end

  # GET /data_filters/1/edit
  def edit
  end

  # POST /data_filters
  # POST /data_filters.xml
  def create
    @data_filter.user = current_user
    respond_to do |format|
      if @data_filter.save
        flash[:notice] = 'DataFilter was successfully created.'
        format.html { redirect_to(@data_filter) }
        format.xml  { render :xml => @data_filter, :status => :created, :location => @data_filter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @data_filter.errors }
      end
    end
  end

  # PUT /data_filters/1
  # PUT /data_filters/1.xml
  def update
    @data_filter.user = current_user
    respond_to do |format|
      if @data_filter.update_attributes(params[:data_filter])
        flash[:notice] = 'DataFilter was successfully updated.'
        format.html { redirect_to(@data_filter) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @data_filter.errors }
      end
    end
  end

  # DELETE /data_filters/1
  # DELETE /data_filters/1.xml
  def destroy
    @data_filter = DataFilter.find(params[:id])
    @data_filter.destroy
    respond_to do |format|
      format.html { redirect_to(data_filters_url) }
      format.xml  { head :ok }
    end
  end
  
  def copy
    @data_filter = @data_filter.clone
    @data_filter.user = current_user
    @data_filter.name << " (copy)"
    render :action => 'new'
  end
  
end
