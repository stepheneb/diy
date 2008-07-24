class SubjectsController < ApplicationController
  
  access_rule 'admin', :only => :destroy
  access_rule 'admin || manager', :only => [:new, :edit, :create, :update, :copy]
  
  
  before_filter :setup_object
  before_filter :find_collections, :except => [:destroy, :otml, :sail_jnlp ]

  protected
  
  def setup_object
    if params[:id]
      @subject = Subject.find(params[:id])
    elsif params[:subject]
      @subject = Subject.new(params[:subject])
    else
      @subject = Subject.new
    end
    @class_name = @subject.class.to_s.underscore
    @class_name_titleized = @class_name.titleize
  end

  def find_collections
    @all_viewable_subjects = Subject.find(:all)
    @all_editable_subjects = @all_viewable_subjects
  end

  public
  
  # GET /subjects
  # GET /subjects.xml
  def index
#    @subjects = Subject.find(:all)
    @subjects = Subject.paginate :page => params[:page]
    @paginated_objects = @subjects
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subjects }
    end
  end

  # GET /subjects/1
  # GET /subjects/1.xml
  def show
    @subject = Subject.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subject }
    end
  end

  # GET /subjects/new
  # GET /subjects/new.xml
  def new
    @subject = Subject.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subject }
    end
  end

  # GET /subjects/1/edit
  def edit
    @subject = Subject.find(params[:id])
  end

  # POST /subjects
  # POST /subjects.xml
  def create
    @subject = Subject.new(params[:subject])

    respond_to do |format|
      if @subject.save
        flash[:notice] = 'Subject was successfully created.'
        format.html { redirect_to(@subject) }
        format.xml  { render :xml => @subject, :status => :created, :location => @subject }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subject.errors }
      end
    end
  end

  # PUT /subjects/1
  # PUT /subjects/1.xml
  def update
    @subject = Subject.find(params[:id])

    respond_to do |format|
      if @subject.update_attributes(params[:subject])
        flash[:notice] = 'Subject was successfully updated.'
        format.html { redirect_to(@subject) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @subject.errors }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.xml
  def destroy
    @subject = Subject.find(params[:id])
    @subject.destroy

    respond_to do |format|
      format.html { redirect_to(subjects_url) }
      format.xml  { head :ok }
    end
  end
end
