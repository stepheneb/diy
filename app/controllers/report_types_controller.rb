class ReportTypesController < ApplicationController
  access_rule 'admin || manager', :only => [:new, :edit, :create, :update, :copy, :destroy]
    
  layout "standard"
  
  before_filter :setup_vars
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy]
  
  protected
  
  def setup_vars
    @class_name = ReportType.to_s.underscore
    @class_name_titleized = @class_name.titleize
    @searchable_attributes = ReportType.searchable_attributes
  end
  
  def setup_object
    if params[:id]
      if params[:id].length == 36
        @report_type = ReportType.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @report_type = ReportType.find(params[:id])
      end
    elsif params[:report_type]
      @report_type = ReportType.new(params[:report_type])
    else
      @report_type = ReportType.new
    end
  end

  def find_collections
    @all_viewable_report_types = ReportType.find(:all)
    @all_editable_report_types = @all_viewable_report_types
  end
  
  public
  
  # GET /report_types
  # GET /report_types.xml
  def index
    @report_types = ReportType.search(params[:search], params[:page], current_user)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @report_types }
    end
  end

  # GET /report_types/1
  # GET /report_types/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @report_type }
    end
  end

  # GET /report_types/new
  # GET /report_types/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @report_type }
    end
  end

  # GET /report_types/1/edit
  def edit
  end

  # POST /report_types
  # POST /report_types.xml
  def create
    @report_type.user = current_user
    respond_to do |format|
      if @report_type.save
        flash[:notice] = 'ReportType was successfully created.'
        format.html { redirect_to(@report_type) }
        format.xml  { render :xml => @report_type, :status => :created, :location => @report_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @report_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /report_types/1
  # PUT /report_types/1.xml
  def update
    respond_to do |format|
      if @report_type.update_attributes(params[:report_type])
        flash[:notice] = 'ReportType was successfully updated.'
        format.html { redirect_to(@report_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @report_type.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def copy
    @report_type = ReportType.find(params[:id]).clone
    @report_type.name << " (copy)"
    @report_type.uuid = nil
    render :action => 'new'
  end
  
  # DELETE /report_types/1
  # DELETE /report_types/1.xml
  def destroy
    @report_type.destroy

    respond_to do |format|
      format.html { redirect_to(report_types_url) }
      format.xml  { head :ok }
    end
  end
end
