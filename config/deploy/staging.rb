# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/web/staging/#{application}"

set :mongrel_conf, "/etc/mongrel_cluster/staging-#{application}.conf"
set :num_servers, 3

set :clean_app_name, application.gsub('-', '_')
  
set :local_username, "#{clean_app_name}"
set :local_password, "#{clean_app_name}"
set :local_database_prefix, "staging_#{clean_app_name}"
set :local_production_database_prefix, "production_#{clean_app_name}"
set :local_staging_database_prefix, "staging_#{clean_app_name}"

desc "copies the production db over the staging db"
task :reset_staging_db, :roles => :db do
  set_db_vars
  
  # put the app into maintenance mode
  !deploy::web::disable
  # dump the production db into the staging db
  run "mysqladmin -u subroot -p#{subroot_pass} -f drop #{local_database_prefix}_prod"
  run "mysqladmin -u subroot -p#{subroot_pass} create #{local_database_prefix}_prod"
  run "mysqldump -u subroot -p#{subroot_pass} --lock-tables=false --add-drop-table --quick --extended-insert #{local_production_database_prefix}_prod | mysql -u #{local_username} -p#{local_password} #{local_database_prefix}_prod"
  # put app into running mode
  !deploy::web::enable
  puts "You'll probably want to run cap reset_staging_db on the SDS so that the database ids will match up correctly. Note that this can mess up references in other staging DIYs, so be careful!"
end

namespace :deploy do
  #############################################################
  #  Passenger
  #############################################################
      
  # Restart passenger on deploy
  desc "Restarting passenger with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    sudo "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with passenger"
    task t, :roles => :app do ; end
  end
end