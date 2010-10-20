  
module ReportableController
  # GET /learners/1/ot_learner_data.xml
  def ot_learner_data
    reportable = get_reportable
    @learners = reportable.learners      
    if params.has_key? :users
      users_array = params[:users].split ',' 
      # @learners = @learners.find(:all, :conditions => { :user_id => users_array})
      
      # inorder to support running reports for users that haven't run this activity
      # passed in users that don't have learners should either get learners created
      # or temporary learners should be created.
      
      # we should create real learners so that we can permanently create things like an overlay file for that user/learner
      @learners = []
      users_array.each do |uid|
        if user = User.find(:first, :conditions => {:id => uid})
          @learners << reportable.find_or_create_learner(user)
        end
      end
    end
    # setup overlay folder. These overlay files hold per-user customizations to the activity.
    @useOverlays = setup_overlay_folder(reportable.id)
    
    if @useOverlays && params[:overlay_root]
      @overlay_root = params[:overlay_root]
    end
    
    if @useOverlays && params[:overlay_params]
      @overlay_params = params[:overlay_params]
    end
      
    render(:template => "shared/ot_learner_data.builder", :layout => false)
  end
end
