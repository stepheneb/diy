require 'hpricot'
require 'open-uri'

class ReportsController < ApplicationController

  access_rule 'admin || manager', :only => [:new, :edit, :create, :update, :copy, :destroy]

  layout "standard"
 
  before_filter :setup_vars
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy]

  protected
  
  def setup_vars
    @class_name = Report.to_s.underscore
    @class_name_titleized = @class_name.titleize
    @searchable_attributes = Report.searchable_attributes
  end
  
  def setup_object
    if params[:id]
      if params[:id].length == 36
        @report = Report.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @report = Report.find(params[:id])
      end
    elsif params[:model]
      @report = Report.new(params[:model])
    else
      @report = Report.new
    end
  end

  def find_collections
    @all_viewable_reports = Report.find(:all)
    @all_editable_reports = Report.find_all_by_user_id(current_user.id)
  end
  
  public
  
  # GET /reports
  # GET /reports.xml
  def index
    @reports = Report.search(params[:search], params[:page], current_user)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reports }
    end
  end

  # GET /reports/1
  # GET /reports/1.xml
  def show
    @report = Report.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @report }
    end
  end

  # GET /reports/new
  # GET /reports/new.xml
  def new
    @report = Report.new
    @ort = OtrunkReportTemplate.find(:all).map {|ort| [ort.name, ort.id]}
    @report.public = true
    @report.user = current_user
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @report }
    end
  end

  # GET /reports/1/edit
  def edit
    @report = Report.find(params[:id])
  end

  # POST /reports
  # POST /reports.xml
  def create
    # debugger
    # reportable = params[:report][:reportable].split(',').collect {|s| s.strip}
    #
    # at this point params might be:
    #
    # {"commit"=>"Create", "action"=>"create", "controller"=>"reports", 
    #  "report"=>{"name"=>"third report", "public"=>"0", "reportable_id"=>"1", "description"=>"another description", "otrunk_report_template_id"=>"1"}}
    #
    # we can just create a new @report instance like this:
    #
    @report = Report.new(params[:report])
    # 
    # This way all the parameters are set that are present in the
    # hash value for "report" in params.
    #
    # but do need to handle hard-coding the reportable_type because
    # it isn't handled more generally yet by the view or the DIY
    #
    @report.reportable_type = "ExternalOtrunkActivity"
    #
    # eot_id = params[:report][:reportable_id]
    # ort_id = params[:report][:otrunk_report_template_id]
    # @report = Report.new(:reportable_type => "ExternalOtrunkActivity", :reportable_id => eot_id, :otrunk_report_template_id => ort_id)
    #
    @report.user = current_user
    respond_to do |format|
      if @report.save
        flash[:notice] = 'Report was successfully created.'    
        format.html { redirect_to reports_url }
        format.xml  { render :xml => @report, :status => :created, :location => @report }
      else
        flash[:notice] = 'Errors creating Report.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @report.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reports/1
  # PUT /reports/1.xml
  def update
    # debugger
    @report = Report.find(params[:id])

    respond_to do |format|
      if @report.update_attributes(params[:report])
        flash[:notice] = 'Report was successfully updated.'
        format.html { redirect_to(@report) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @report.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.xml
  def destroy
    @report = Report.find(params[:id])
    @report.destroy

    respond_to do |format|
      format.html { redirect_to(reports_url) }
      format.xml  { head :ok }
    end
  end
  
  def copy
    @report = Report.find(params[:id]).clone
    @report.user = current_user
    @report.public = false
    @report.name << " (copy)"
    @report.uuid = nil
    render :action => 'new'
  end
  
  
  def sail_jnlp
    @report = Report.find(params[:id])
    reportable = @report.reportable
    
    # render :text => "#{@report.short_name}: #{@report.reportable.id}, #{@report.otrunk_report_template.id}"
    if params[:users].blank?
      report_url_var = otml_report_url      
    else
      report_url_var = otml_report_url :users => params[:users]
    end
 
    # authoring is enabled so the current user is not added to the list of users
    # that the OTrunk activity sees.  this is not clean because we aren't
    # really doing authoring just reporting.  However the way Sail/OTrunk currently 
    # works this is the only way to do it.  
    redirect_to reportable.sds_url(current_user, self, {
      :otml_url => report_url_var, :nobundles => false, :savedata => false,
      :authoring => true})

  end
  
  def report_template_otml
    # the save is required so the otml will be updated
    # there is an otml method in the otrunk_report_template which does this same thing
    # but we don't have that controller here.
    @report.otrunk_report_template.save
    @report.otrunk_report_template.otml
  end
  
  def otml
    begin
      @report = Report.find(params[:id])
      otml_report_template = Hpricot.XML(report_template_otml)
      if @report.otrunk_report_template.external_otml_always_update
        codebase = File.dirname(@report.otrunk_report_template.external_otml_url)
      else
        codebase = File.dirname(@report.otrunk_report_template.cached_otml_url)
      end
      
      activity = otml_report_template.search("//*[@local_id='external_activity_url']")
      activity.first[:href] = otml_external_otrunk_activity_report_url(@report.reportable) unless activity.blank?
      
      if params[:users].blank? 
        learner_list_url = ot_learner_data_external_otrunk_activity_url(@report.reportable)
      else 
        learner_list_url = ot_learner_data_external_otrunk_activity_url(@report.reportable, :users => params[:users])      
      end
      
      external_user_list = otml_report_template.search("//*[@local_id='external_user_list_url']")
      if external_user_list.blank?
        raise "Need to have a user_list object with a local_id='external_user_list_url'"
      end
      external_user_list.first[:href] = learner_list_url
      
      otml_activity = Hpricot.XML(@report.reportable.otml)
      otml_activity_uuid = otml_activity.search("/otrunk[@id]").first[:id]
      
      script_object = otml_report_template.search("//*[@local_id='script_object']")
      script_object.first[:id] = otml_activity_uuid + "!/activity_script" unless script_object.blank?
      
      # why is this messing with the codebase?
      unless codebase.empty?
        otml_report_template.search("/otrunk").set(:codebase,  codebase)
      end
      
      rubric_include_element = otml_activity.search("//*[@local_id='external_rubric_url']")
      unless rubric_include_element.blank?
        rubric_uri = URI.parse(rubric_include_element.first[:href])
        unless rubric_uri.host
          rubric_uri = URI.join(codebase + '/', rubric_uri.path)
        end
        rubric_url = rubric_uri.to_s
        logger.info("rubric_url: #{rubric_url}")
        rubric_otml = Hpricot.XML(open(rubric_url))
        rubric_uuid = rubric_otml.search("/otrunk[@id]").first[:id]
        rubric_id_mapping = otml_report_template.search("//*[@local_id='rubric']")
        rubric_id_mapping.first[:id] = rubric_uuid
      end
      
      render :xml => otml_report_template
    rescue
      render :xml => $!, :layout => "otml_message"
    end
  end  
end
