# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

set :version, "staging"
set :deploy_to,  "/web/#{version}/#{application}" 
set :shared_path, File.join(deploy_to, "shared")

set :mongrel_conf, "/etc/mongrel_cluster/staging-#{application}.conf"
set :num_servers, 3

set :clean_app_name, application.gsub('-', '_')
  
set :local_username, "#{clean_app_name}"
set :local_password, "#{clean_app_name}"
set :local_database_prefix, "staging_#{clean_app_name}"
set :local_production_database_prefix, "production_#{clean_app_name}"
set :local_staging_database_prefix, "staging_#{clean_app_name}"
set :use_passenger, true

desc "copies the production db over the staging db"
task :reset_staging_db, :roles => :db do
  if version == 'staging'
    # put the app into maintenance mode
    disable_web
    # dump the production db into the staging db
    run "mysqladmin -u subroot -p#{subroot_pass} -f drop #{local_database_prefix}_prod"
    run "mysqladmin -u subroot -p#{subroot_pass} create #{local_database_prefix}_prod"
    run "mysqldump -u subroot -p#{subroot_pass} --lock-tables=false --add-drop-table --quick --extended-insert #{local_production_database_prefix}_prod | mysql -u #{local_username} -p#{local_password} #{local_database_prefix}_prod"
    # put app into running mode
    enable_web
    puts "You'll probably want to run cap reset_staging_db on the SDS so that the database ids will match up correctly. Note that this can mess up references in other staging DIYs, so be careful!"
  else
    puts "You have to run in staging to execute this task."
  end
end
