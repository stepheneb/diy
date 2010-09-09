require 'hpricot'
require 'open-uri'
require 'concord_cacher'

class ReportsController < ApplicationController

  access_rule 'admin || manager', :only => [:new, :edit, :create, :update, :copy, :destroy]

  layout "standard"
 
  before_filter :setup_vars
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy]
  before_filter :find_activities, :only =>[:new, :edit]
  protected
  
  def setup_vars
    @class_name = Report.to_s.underscore
    @class_name_titleized = @class_name.titleize
    @searchable_attributes = Report.searchable_attributes
  end
  
  def setup_object
    if params[:id]
      if params[:id].length == 36
        @report = Report.find_by_uuid(params[:id])
      else
        @report = Report.find(params[:id])
      end
    elsif params[:model]
      @report = Report.new(params[:model])
    elsif params[:report]
      @report = Report.new(params[:report])
    else
      @report = Report.new
    end
  end
  

  def update_reportable
    if params[:reportable]
      type,id = params[:reportable].split(reportable_split_char)
    end
  end
  
  def find_collections
    @all_viewable_reports = Report.find(:all)
    @all_editable_reports = Report.find_all_by_user_id(current_user.id)
  end
 
  def find_activities
    @activities = Activity.find(:all).collect                {|i| ["#{i.id}: #{i.name}", Report.serialize_reportable(i)]}
    @activities << ExternalOtrunkActivity.find(:all).collect {|i| ["#{i.id}: (external) #{i.name}", Rerport.serialize_reportable(i)]}
  end
  public
  
  # GET /reports
  # GET /reports.xml
  def index
    if params[:external_otrunk_activity_id]
      @reports = ExternalOtrunkActivity.find(params[:external_otrunk_activity_id]).reports
    else
      @reports = Report.search(params[:search], params[:page], current_user)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reports }
    end
  end

  # GET /reports/1
  # GET /reports/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @report }
    end
  end

  # GET /reports/new
  # GET /reports/new.xml
  def new
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
    # 
    # This way all the parameters are set that are present in the
    # hash value for "report" in params.
    #
    # but do need to handle hard-coding the reportable_type because
    # it isn't handled more generally yet by the view or the DIY
    #
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
    @report.destroy

    respond_to do |format|
      format.html { redirect_to(reports_url) }
      format.xml  { head :ok }
    end
  end
  
  def copy
    @report = @report.clone
    @report.user = current_user
    @report.public = false
    @report.name << " (copy)"
    @report.uuid = nil
    render :action => 'new'
  end
  
  
  def sail_jnlp
    reportable = @report.reportable
    
    # render :text => "#{@report.short_name}: #{@report.reportable.id}, #{@report.otrunk_report_template.id}"
    otml_report_hash = {:users => params[:users]}
   
    if USE_OVERLAYS && get_overlay_server_root && params[:group_id]
      otml_report_hash[:group_id] = params[:group_id]
      otml_report_hash[:group_list] = params[:group_list]
    end
    
    if params[:overlay_root]
      otml_report_hash[:overlay_root] = params[:overlay_root]
    end
    
    if params[:overlay_params]
      otml_report_hash[:overlay_params] = URI.escape(params[:overlay_params], /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)
    end
    
    report_url_var = otml_report_url(otml_report_hash)    

    system_properties = []
    params.each_key do |key|
      if match = /^system\.(.*)/.match(key) 
        system_properties << (match[1] + "=" + params[key]) 
      end
    end

    # set no_user to true since we're not authoring and shouldn't be trying to save learner or authored data
    redirect_to reportable.sds_url(current_user, self, {
      :otml_url => report_url_var, :nobundles => false, :savedata => false,
      :authoring => false, :no_user => true, :system_properties => system_properties, :custom_offering_id => @report.custom_offering_id, :custom_workgroup_id => @report.custom_workgroup_id})

  end
  
  def report_template_otml
    # the save is required so the otml will be updated
    # there is an otml method in the otrunk_report_template which does this same thing
    # but we don't have that controller here.
    @report.otrunk_report_template.save
    @report.otrunk_report_template.otml
  end
  
  def reference_list(list)
    out = []
    list.each do |b|
      out << "<object refid='#{b}' />"
    end
    return out.join("\n")
  end
  
  def otml
    begin
      report_template_xml = report_template_otml
      # see application controller
      setup_overlay_requirements(@report.reportable.otml) # initializes @bundles, @overlays, @rootObjectID
      report_template_xml.sub!(/<!-- BUNDLES -->/, reference_list(@bundles))
      report_template_xml.sub!(/<!-- OVERLAYS -->/, reference_list(@overlays))
      report_template_xml.sub!(/<!-- ROOT OBJECT -->/, "<object refid='#{@rootObjectID}' />")
      
      otml_report_template = REXML::Document.new(report_template_xml).root
      
      activity = otml_report_template.elements["//*[@local_id='external_activity_url']"]
      unless activity.blank?
        if ((@report.reportable.kind_of? ExternalOtrunkActivity) && ! @report.reportable.external_otml_url.blank?)
          if (APP_PROPERTIES[:cache_external_otrunk_activities] == true)
            activity.attributes["href"] = @report.reportable.cached_otml_url
          else
            activity.attributes["href"] = @report.reportable.external_otml_url
          end
        else 
          activity.attributes["href"] = otml_external_otrunk_activity_report_url(@report.reportable)
        end
      end
      
      learner_list_url_hash = {}
      if params.has_key? :users
        learner_list_url_hash[:users] = params[:users]
      end
      
      if params.has_key? :overlay_root
        learner_list_url_hash[:overlay_root] = params[:overlay_root]
      end
      
      if params.has_key? :overlay_params
        learner_list_url_hash[:overlay_root] = params[:overlay_root]
      end
      if (@report.reportable.kind_of? ExternalOtrunkActivity) 
        learner_list_url = ot_learner_data_external_otrunk_activity_url(@report.reportable, learner_list_url_hash)
      elsif (@report.reportable.kind_of? Activity)
        learner_list_url = ot_learner_data_activity_url(@report.reportable, learner_list_url_hash)
      end

      external_user_list = otml_report_template.elements["//*[@local_id='external_user_list_url']"]
      if external_user_list.blank?
        raise "Need to have a user_list object with a local_id='external_user_list_url'"
      end
      external_user_list.attributes["href"] = learner_list_url
      
      otml_activity = Hpricot.XML(@report.reportable.otml)
      otml_activity_uuid = otml_activity.search("/otrunk[@id]").first[:id]
      
      script_object = otml_report_template.elements["//*[@local_id='script_object']"]
      script_object.attributes["id"] = otml_activity_uuid + "!/activity_script" unless script_object.blank?
      
      # the codebase is set so any relative urls in the original report_template_will still work
      codebase = @report.otrunk_report_template.generate_otml_codebase
      unless codebase.nil?
        otml_report_template.elements["/otrunk"].attributes["codebase"] = codebase
      end
      
      # setup the group-wide overlay if a group_id has been set in
      if params[:group_id]
        group_id = params[:group_id]
        @groupOverlayURL = CGI.escapeHTML((params[:overlay_root] ? get_overlay_server_root(params[:overlay_root]) : get_overlay_server_root) + "/#{@report.reportable.id}/#{group_id}.otml" + (params[:overlay_params] ? "?#{params[:overlay_params]}" : "")) if group_id
        # make sure the group overlay exists
        setup_default_overlay(@report.reportable.id, group_id)
        
        # insert the overlay URL into the template
        multi_root = otml_report_template.elements["//OTMultiUserRoot"]
        multi_root.attributes["groupOverlayURL"] = @groupOverlayURL if multi_root
      end
      
      # insert the OTGroupListManager, OTGroupMember, OTProxyService imports
      imports = otml_report_template.elements["/otrunk/imports"]
      new_imports = []
      new_imports << "org.concord.otrunk.script.jruby.OTJRuby"      
      new_imports << "org.concord.otrunk.view.OTGroupListManager"
      new_imports << "org.concord.otrunk.view.OTGroupMember"
      new_imports << "org.concord.otrunk.user.OTUserObject"
      new_imports << "org.concord.otrunk.intrasession.proxy.OTProxyService" if ((defined? OTRUNK_USE_LOCAL_CACHE) && OTRUNK_USE_LOCAL_CACHE)
      new_imports << "org.concord.otrunk.intrasession.proxy.OTProxyConfig" if ((defined? OTRUNK_USE_LOCAL_CACHE) && OTRUNK_USE_LOCAL_CACHE)
      new_imports.each do |i|
        im = imports.add_element "import"
        im.attributes["class"] = i
      end
      # insert the OTGroupListManager object
      bundles = otml_report_template.elements["/otrunk/objects/OTSystem/bundles"]
      otglm_element = bundles.add_element "OTGroupListManager"
      if group_id
        otglm_element.attributes["groupDataURL"] = CGI.escapeHTML((params[:overlay_root] ? get_overlay_server_root(params[:overlay_root]) : get_overlay_server_root) + "/#{@report.reportable.id}/#{group_id}-data.otml" + (params[:overlay_params] ? "?#{params[:overlay_params]}" : ""))
      end
      
      #insert the OTProxyService, if using the Local Cache is enabled
      if ((defined? OTRUNK_USE_LOCAL_CACHE) && OTRUNK_USE_LOCAL_CACHE)
        ot_proxy_config = bundles.add_element("OTProxyService").add_element("proxyConfig").add_element("OTProxyConfig")
        # don't bother making this unique, as we'll shouldn't ever have 2 of these loaded at the same time
        ot_proxy_config.attributes["id"] = "327ced8d-0b78-4cd8-9f87-5d2308fa716f"
        ot_proxy_config.attributes["proxyMode"] = "SERVER"
        ot_proxy_config.attributes["proxyPort"] = "8080"
      end
      
      @learners = []
      if (params[:group_list] && ! params[:group_list].empty?)
        uids = params[:group_list].split(",")
        uids.each do |uid|
          begin
            @learners << @report.reportable.find_or_create_learner(User.find(uid))
          rescue
            # ignore it for now
          end
        end
      end
      
      @learners.uniq!
      
      if @learners.size > 0
        user_list = otglm_element.add_element "userList"
        @learners.each do |l|
          mem = user_list.add_element "OTGroupMember"
          mem.attributes["name"] = l.user.name
          mem.attributes["uuid"] = l.user.uuid
          mem.attributes["isCurrentUser"] = "false"
          mem.attributes["passwordHash"] = l.user.password_hash
          mem.attributes["dataURL"] = CGI.escapeHTML((params[:overlay_root] ? get_overlay_server_root(params[:overlay_root]) : get_overlay_server_root) + "/#{@report.reportable.id}/#{l.id}-data.otml" + (params[:overlay_params] ? "?#{params[:overlay_params]}" : ""))
          user = mem.add_element("userObject").add_element("OTUserObject")
          user.attributes["id"] = l.uuid
        end
      end
      
      render :xml => otml_report_template.to_s
      rescue => e
      render :xml => "#{$!}\n#{e.backtrace.join("\n")}", :layout => "otml_message"
    end
  end  
end
