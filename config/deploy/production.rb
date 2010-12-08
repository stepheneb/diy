# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

set :version, "production"
set :deploy_to,  "/web/#{version}/#{application}" 
set :shared_path, File.join(deploy_to, "shared")

set :mongrel_conf, "/etc/mongrel_cluster/production-#{application}.conf"
set :num_servers, 6

set :clean_app_name, application.gsub('-', '_')
  
set :local_username, "#{clean_app_name}"
set :local_password, "#{clean_app_name}"
set :local_database_prefix, "production_#{clean_app_name}"
set :local_production_database_prefix, "production_#{clean_app_name}"
set :local_staging_database_prefix, "staging_#{clean_app_name}"

set(:use_passenger) do
  # if ['itsisu_diy', 'itsi','capa'].index(application)
  # NP: everything does now
    true
  # else
    # Capistrano::CLI.ui.agree( "Use passenger for deployment? (y/n) ", false)
    # We could ask... but nothing else really uses passenger I think..
  # false
  # end
end
