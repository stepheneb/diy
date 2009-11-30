# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/web/production/#{application}"

set :version, "production"

set :mongrel_conf, "/etc/mongrel_cluster/production-#{application}.conf"
set :num_servers, 6

set :clean_app_name, application.gsub('-', '_')
  
set :local_username, "#{clean_app_name}"
set :local_password, "#{clean_app_name}"
set :local_database_prefix, "production_#{clean_app_name}"
set :local_production_database_prefix, "production_#{clean_app_name}"
set :local_staging_database_prefix, "staging_#{clean_app_name}"

