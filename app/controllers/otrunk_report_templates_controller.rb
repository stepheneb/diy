class OtrunkReportTemplatesController < ApplicationController

  access_rule 'admin || manager || teacher || member', :only => [:new, :edit, :create, :update, :copy, :destroy]

  layout "standard"

  before_filter :setup_vars
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy]

  protected
  
  def setup_vars
    @class_name = OtrunkReportTemplate.to_s.underscore
    @class_name_titleized = @class_name.titleize
    @searchable_attributes = OtrunkReportTemplate.searchable_attributes
    @restricted_copy_and_create = true
  end

  def setup_object
    Thread.current[:request] = request
    if params[:id]
      if params[:id].length == 36
        @otrunk_report_template = OtrunkReportTemplate.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @otrunk_report_template = OtrunkReportTemplate.find(params[:id])
      end
    elsif params[:otrunk_report_template]
      @otrunk_report_template = OtrunkReportTemplate.new(params[:otrunk_report_template])
    else
      @otrunk_report_template = OtrunkReportTemplate.new
    end
    # @otrunk_report_template.save
  end

  def find_collections
    @all_viewable_otrunk_report_templates = OtrunkReportTemplate.find(:all, :conditions => "public=true or user_id='#{current_user.id}'")
    @all_editable_otrunk_report_templates = OtrunkReportTemplate.find_all_by_user_id(current_user.id)
  end

  public

  # GET /otrunk_report_templates
  # GET /otrunk_report_templates.xml
  def index
    @otrunk_report_templates = OtrunkReportTemplate.search(params[:search], params[:page], current_user)
    @paginated_objects = @otrunk_report_templates
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @otrunk_report_templates }
    end
  end

  # GET /otrunk_report_templates/1
  # GET /otrunk_report_templates/1.xml
  def show
    @otrunk_report_template = OtrunkReportTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @otrunk_report_template }
    end
  end

  # GET /otrunk_report_templates/new
  # GET /otrunk_report_templates/new.xml
  def new
    @otrunk_report_template = OtrunkReportTemplate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @otrunk_report_template }
    end
  end

  # GET /otrunk_report_templates/1/edit
  def edit
    @otrunk_report_template = OtrunkReportTemplate.find(params[:id])
  end

  # POST /otrunk_report_templates
  # POST /otrunk_report_templates.xml
  def create
    @otrunk_report_template = OtrunkReportTemplate.new(params[:otrunk_report_template])
    @otrunk_report_template.user = current_user

    respond_to do |format|
      if @otrunk_report_template.save
        flash[:notice] = 'OtrunkReportTemplate was successfully created.'
        format.html { redirect_to(@otrunk_report_template) }
        format.xml  { render :xml => @otrunk_report_template, :status => :created, :location => @otrunk_report_template }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @otrunk_report_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /otrunk_report_templates/1
  # PUT /otrunk_report_templates/1.xml
  def update
    @otrunk_report_template = OtrunkReportTemplate.find(params[:id])

    respond_to do |format|
      if @otrunk_report_template.update_attributes(params[:otrunk_report_template])
        flash[:notice] = 'OtrunkReportTemplate was successfully updated.'
        format.html { redirect_to(@otrunk_report_template) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @otrunk_report_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /otrunk_report_templates/1
  # DELETE /otrunk_report_templates/1.xml
  def destroy
    @otrunk_report_template = OtrunkReportTemplate.find(params[:id])
    @otrunk_report_template.destroy

    respond_to do |format|
      format.html { redirect_to(otrunk_report_templates_url) }
      format.xml  { head :ok }
    end
  end

  def copy
    @otrunk_report_template.user = current_user
    @otrunk_report_template.public = true
    @otrunk_report_template.name << " (copy)"
    @otrunk_report_template.uuid = nil
    render :action => 'new'
  end

  def otml
    @otrunk_report_template.save
    render :xml => @otrunk_report_template.otml
  end

  def usage
    @reports = @otrunk_report_template.reports
  end
  
  def compare
    @other_otrunk_report_template = OtrunkReportTemplate.find(params[:other])
  end
  
end
