ActionController::Routing::Routes.draw do |map|
  map.resources :report_types, :member => { :copy => :get }

  map.resources :reports, :member => { :copy => :get, :sail_jnlp => :get, :otml => :get }

  map.resources :otrunk_report_templates, :member => { :copy => :get, :usage => :get, :otml => :get }
  
  map.resources :calibrations, :member => { :copy => :get }
  map.calibrations '/calibrations/data_filter_parameters', :controller => "calibrations", :action => 'data_filter_parameters'
  map.resources :calibrations

  map.resources :data_filters, :member => { :copy => :get }

  map.resources :probes, :member => { :copy => :get }

  map.resources :physical_units, :member => { :copy => :get }

  map.resources :probe_types do |probe_types|
    probe_types.resources :calibrations, :member => { :copy => :get }
  end

  map.resources :model_types, :member => { :copy => :get }

  map.resources :learners, :member => { :sessions => :get }
  map.resources :learners, :member => { :ot_learner_data => :get }

  map.resources :units do |units|
    units.resources :activities, :name_prefix => "unit_"
  end

  map.resources :subjects do |subjects|
    subjects.resources :activities, :name_prefix => "subject_"
    subjects.resources :units, :name_prefix => "subject_"
  end
  
  map.resources :levels do |levels|
    levels.resources :activities, :name_prefix => "subject_"
    levels.resources :units, :name_prefix => "subject_"
  end

  map.resources :users, :member => { :interface => :get }
  map.resources :users, :member => { :interface => :put }
  map.resources :users, :member => { :roles => :get }
  map.resources :users, :member => { :roles => :put }
  
  map.resources :users do |users|
    users.resources :activities, :name_prefix => "user_"
    users.resources :learners, :name_prefix => "user_", :member => { :sessions => :get, :ot_learner_data => :get  }
  end

  map.login  'login', :controller => 'session', :action => 'new'
  map.logout 'logout', :controller => 'session', :action => 'destroy'
  map.resource :session, :controller => 'session'
  
  # WISE step-type needs to be able to issue a GET to start a new session
  map.session 'session/create', :controller => 'session', :action => 'create'

  map.with_options :action => 'compare' do |compare|
    compare.compare_view ':controller/:id/compare/:other'
  end

  map.with_options :action => 'sail_jnlp', :requirements => {:nobundles => /nobundles|/} do |jnlp|
    jnlp.sail_jnlp_view ':controller/:id/sail_jnlp/:vid/:uid/view', :savedata => nil, :authoring => nil
    jnlp.sail_jnlp_preview ':controller/:id/sail_jnlp/:vid/:uid/preview', :savedata => nil, :authoring => nil, :nobundles => 'nobundles'
    jnlp.sail_jnlp_authoring ':controller/:id/sail_jnlp/:vid/:uid/authoring', :savedata => nil, :authoring => true, :nobundles => 'nobundles'
    jnlp.sail_jnlp_run ':controller/:id/sail_jnlp/:vid/:uid/:nobundles', :savedata => true, :authoring => nil, :nobundles => ''
    jnlp.sail_jnlp_run_report ':runnable/:rid/reports/:id/sail_jnlp', :controller => 'reports', :savedata => nil, :authoring => nil
  end
  
  map.with_options :action => 'html_export_jnlp', :requirements => {:nobundles => /nobundles|/} do |jnlp|
    jnlp.html_export_jnlp_view ':controller/:id/html_export_jnlp/:vid/:uid/view', :savedata => nil, :authoring => nil
    jnlp.html_export_jnlp_preview ':controller/:id/html_export_jnlp/:vid/:uid/preview', :savedata => nil, :authoring => nil, :nobundles => 'nobundles'
    jnlp.html_export_jnlp_authoring ':controller/:id/html_export_jnlp/:vid/:uid/authoring', :savedata => nil, :authoring => true, :nobundles => 'nobundles'
    jnlp.html_export_jnlp_run ':controller/:id/html_export_jnlp/:vid/:uid/:nobundles', :savedata => true, :authoring => nil, :nobundles => ''
    jnlp.html_export_jnlp_run_report ':runnable/:rid/reports/:id/html_export_jnlp', :controller => 'reports', :savedata => nil, :authoring => nil
  end

  map.with_options :action => 'otml' do |otml|
    otml.otml_view ':controller/:id/otml/:vid/:uid/view', :savedata => nil, :authoring => nil
    otml.otml_preview ':controller/:id/otml/:vid/:uid/preview', :savedata => nil, :authoring => nil, :nobundles => "nobundles"
    otml.otml_authoring ':controller/:id/otml/:vid/:uid/authoring', :savedata => nil, :authoring => true, :nobundles => "nobundles"
    otml.otml_run ':controller/:id/otml/:vid/:uid/:nobundles', :savedata => true, :authoring => nil, :nobundles => ''
    otml.otml_learner_run ':controller/:id/otml/:vid/:uid/:lid', :savedata => true, :authoring => nil, :nobundles => ''
    otml.otml_external_otrunk_activity_report 'external_otrunk_activities/:id/otml', :controller => 'external_otrunk_activities', :reporting => true
  end
  
  map.with_options :action => 'overlay_otml' do |otml|
    otml.overlay_otml_view ':controller/:id/overlay_otml/:vid/:uid/view', :savedata => nil, :authoring => nil
    otml.overlay_otml_preview ':controller/:id/overlay_otml/:vid/:uid/preview', :savedata => nil, :authoring => nil, :nobundles => "nobundles"
    otml.overlay_otml_authoring ':controller/:id/overlay_otml/:vid/:uid/authoring', :savedata => nil, :authoring => true, :nobundles => "nobundles"
    otml.overlay_otml_run ':controller/:id/overlay_otml/:vid/:uid/:nobundles', :savedata => true, :authoring => nil, :nobundles => ''
    otml.overlay_otml_learner_run ':controller/:id/overlay_otml/:vid/:uid/:lid', :savedata => true, :authoring => nil, :nobundles => ''
    otml.overlay_otml_external_otrunk_activity_report 'external_otrunk_activities/:id/overlay_otml', :controller => 'external_otrunk_activities', :reporting => true
  end

  map.activities 'activities/check_xhtml', :controller => 'activities', :action => 'check_xhtml'

  map.resources :activities, :member => { :copy => :get }
  map.resources :activities, :member => { :usage => :get }
  map.resources :activities, :member => { :ot_learner_data => :get }
  map.resources :activities, :member => { :save_draft => :put }
  map.resources :activities do |activities|
    activities.resources :units, :name_prefix => "activity_"
    activities.resources :learners, :name_prefix => "activity_", :member => { :sessions => :get, :ot_learner_data => :get  }
    activities.resources :levels, :name_prefix => "activity_"
    activities.resources :subjects, :name_prefix => "activity_"
  end

  map.resources :models, :member => { :copy => :get }
  map.resources :models, :member => { :usage => :get }
  map.resources :models do |models|
    models.resources :units, :name_prefix => "model_"
    models.resources :learners, :name_prefix => "model_", :member => { :sessions => :get, :ot_learner_data => :get  }
    models.resources :levels, :name_prefix => "model_"
    models.resources :subjects, :name_prefix => "model_"
  end

  map.resources :external_otrunk_activities, :member => { :copy => :get, :usage => :get, :ot_learner_data => :get }
  map.resources :external_otrunk_activities do |external_otrunk_activities|
    external_otrunk_activities.resources :reports, :name_prefix => "external_otrunk_activity_"
    external_otrunk_activities.resources :units, :name_prefix => "external_otrunk_activity_"
    external_otrunk_activities.resources :learners, :name_prefix => "external_otrunk_activity_", :member => { :sessions => :get, :ot_learner_data => :get  }
    external_otrunk_activities.resources :levels, :name_prefix => "external_otrunk_activity_"
    external_otrunk_activities.resources :subjects, :name_prefix => "external_otrunk_activity_"
  end
  
  map.statistics 'statistics', :controller => 'statistics', :action => 'month', :months => 1
  map.statistics 'statistics/month/:months', :controller => 'statistics', :action => 'month'
  map.statistics 'statistics/:action', :controller => 'statistics'
  
  map.statistics 'scoring', :controller => 'scoring', :action => 'index'
  map.statistics 'scoring/:action', :controller => 'scoring'
  
  # Install the default route as the lowest priority.
#  map.connect ':controller/:action/:id'
#  map.connect ':controller/:action/:id.:format'

  # display the page#index controller for the default route
  map.home '', :controller => "home", :action => 'index'
  map.connect '', :controller => "home", :action => 'index'  

end
