class ProbesController < ApplicationController
  
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy, :otml, :sail_jnlp ]

  protected
  
  def setup_object
    if params[:id]
      @probe = Probe.find(params[:id])
    elsif params[:probe]
      @probe = Probe.new(params[:probe])
    else
      @probe = Probe.new
    end
    @class_name = @probe.class.to_s.underscore
    @class_name_titleized = @class_name.titleize
  end

  def find_collections
    @all_viewable_probes = probe.find(:all)
    @all_editable_probes = @all_viewable_probes
  end

  public
  
  # GET /probes
  # GET /probes.xml
  def index
#    @probes = Probe.find(:all)
    @probes = Probe.paginate :page => params[:page]
    @paginated_objects = @probes
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @probes }
    end
  end

  # GET /probes/1
  # GET /probes/1.xml
  def show
    @probe = Probe.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @probe }
    end
  end

  # GET /probes/new
  # GET /probes/new.xml
  def new
    @probe = Probe.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @probe }
    end
  end

  # GET /probes/1/edit
  def edit
    @probe = Probe.find(params[:id])
  end

  # POST /probes
  # POST /probes.xml
  def create
    @probe = Probe.new(params[:probe])

    respond_to do |format|
      if @probe.save
        flash[:notice] = 'Probe was successfully created.'
        format.html { redirect_to(@probe) }
        format.xml  { render :xml => @probe, :status => :created, :location => @probe }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @probe.errors }
      end
    end
  end

  # PUT /probes/1
  # PUT /probes/1.xml
  def update
    @probe = Probe.find(params[:id])

    respond_to do |format|
      if @probe.update_attributes(params[:probe])
        flash[:notice] = 'Probe was successfully updated.'
        format.html { redirect_to(@probe) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @probe.errors }
      end
    end
  end

  # DELETE /probes/1
  # DELETE /probes/1.xml
  def destroy
    @probe = Probe.find(params[:id])
    @probe.destroy

    respond_to do |format|
      format.html { redirect_to(probes_url) }
      format.xml  { head :ok }
    end
  end
end
