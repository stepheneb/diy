# For restarting apps, there are 2 ways to do it:
# 
# if you have the diy or sds code checked out, and have sudo privileges on seymour:
#   cd to your checked out code
#   run 'cap production deploy:restart'
#   type in the name of the instance you want to restart (if it's a diy)
#   type in your password when prompted
# 
# eg
# aunger:~ aunger$ cd ~/Documents/workspaces/rails-workspace/diy
# aunger:~/Documents/workspaces/rails-workspace/diy aunger$ cap production deploy:restart
#   * executing `production'
#   * executing `ask_instance'
#   * executing `set_vars'
# Enter the instance name (eg itsi, udl, capa): udl
#   * executing `deploy:restart'
#   * executing `mongrel:cluster:restart'
#   * executing "sudo -p 'sudo password: ' mongrel_rails cluster::restart -C /etc/mongrel_cluster/production-udl.yml"
#     servers: ["seymour.concord.org"]
#     [seymour.concord.org] executing command
# Password:
# *** [err :: seymour.concord.org]
#  ** [out :: seymour.concord.org] stopping port 4200
#  ** [out :: seymour.concord.org] stopping port 4201
#  ** [out :: seymour.concord.org] stopping port 4202
#  ** [out :: seymour.concord.org] stopping port 4203
#  ** [out :: seymour.concord.org] stopping port 4204
#  ** [out :: seymour.concord.org] stopping port 4205
#  ** [out :: seymour.concord.org] starting port 4200
#  ** [out :: seymour.concord.org] starting port 4201
#  ** [out :: seymour.concord.org] starting port 4202
#  ** [out :: seymour.concord.org] starting port 4203
#  ** [out :: seymour.concord.org] starting port 4204
#  ** [out :: seymour.concord.org] starting port 4205
#     command finished
# aunger:~/Documents/workspaces/rails-workspace/diy aunger$
# 
# If you don't have the code checked out, you can:
#   ssh to seymour
#   run 'sudo mongrel_rails cluster::restart -C /etc/mongrel_cluster/production-udl.yml'
# 
# Be sure to replace the yml filename with the appropriate names -- [production|staging]-[instanceName].yml

# maybe use these recipes because we are using mongrel_cluster on the server
# where are they documented?
require 'mongrel_cluster/recipes'

set :stages, %w(staging production)
require 'capistrano/ext/multistage'

set :mydebug, false

set :erb_templates_folder, "lib/capistrano/recipes/templates"

set(:subroot_pass) do
  Capistrano::CLI.password_prompt( "Enter the subroot mysql password: ")
end

set(:application) do
  Capistrano::CLI.ui.ask "Enter the instance name (eg itsi, udl, capa): "
end

set(:sds_host) do
  Capistrano::CLI.ui.ask( "Enter the sds host url (including portal id): ")
end
set(:sds_jnlp_id) do
  Capistrano::CLI.ui.ask( "Enter the sds jnlp id: ")
end
set(:sds_curnit_id) do
  Capistrano::CLI.ui.ask( "Enter the sds curnit id: ")
end

set(:email_addresses) do
  Capistrano::CLI.ui.ask( "Enter a semi-colon delimited list of email notification recipients: ")
end

set :repository,  "https://svn.concord.org/svn/diy/trunk"
set :mongrel_user, "mongrel"
set :mongrel_group, "users"
set :use_passenger, false

# Caches the svn co in shared and just does a svn up before copying the code to a new release
# see: http://blog.innerewut.de/tags/capistrano%20deployment%20webistrano%20svn%20subversion%20cache
set :deploy_via, :remote_cache

# set :ssh_options, { :forward_agent => true }

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

# set :user, "httpd"
# if SSH user defined in ~/.ssh/config use that name as the user
# otherwise use the user defined in ENV
set :user, File.open("#{ENV['HOME']}/.ssh/config", 'r') {|f| f.read}[/User (.*)/, 1] || ENV['USER']

role :app, "seymour.concord.org"
role :web, "seymour.concord.org"
role :db,  "seymour.concord.org", :primary => true

after "deploy:setup", :chown_to_current_user
after "deploy:setup", :copy_current_config
after "deploy:cold", :setup_new_diy
after "deploy:update_code", :copy_configs
after "deploy:symlink", :chown_folders
before "deploy", :verify_action
before "verify_action", :set_server_type

task :copy_configs, :roles => :app do
  files = %w(database.yml environment.rb sds.yml mail.yml exception_notifier_recipients.yml newrelic.yml)
  files.each do |file|
    src =  "#{shared_path}/config/#{file}"
    dst = "#{release_path}/config/#{file}"
    run "if [ -r #{src} ]; then cp #{src} #{dst}; fi"
  end
  
  run "ln -sf #{shared_path}/xls #{release_path}/tmp/xls"
end

task :chown_folders, :roles => :app do
  if use_passenger
    sudo "chown -R apache.users #{deploy_to}"
  else
    sudo "chown -R mongrel.users #{deploy_to}"
  end
  sudo "chmod -R g+w #{deploy_to}"
end

depend :remote, :file, "#{shared_path}/config/database.yml"
depend :remote, :file, "#{shared_path}/config/environment.rb"
depend :remote, :file, "#{shared_path}/config/sds.yml"
depend :remote, :file, "#{shared_path}/config/mailer.yml"
depend :remote, :file, "#{shared_path}/config/exception_notifier_recipients.yml"

task :chown_to_current_user, :roles => :app do
  sudo "chown -R #{user}.users #{deploy_to}"
  sudo "chmod -R g+w #{deploy_to}"
end

task :copy_current_config, :roles => :app do
  set :config_dir, "#{shared_path}/config"
  run "mkdir -p #{config_dir}"
  create_local_dbs
  write_database_conf
  write_sds_conf
  write_environment
  write_apache_conf
  write_mailer_conf
  write_exception_notifier_config
end

task :write_apache_conf, :roles => :app do
  file = render "apache-conf.rhtml"
  put file, "/web/#{version}/conf/#{application}.conf"
end

task :write_environment, :roles => :app do
  contents = File.open("config/environment.sample.rb").read
  contents.gsub!(/'diy_'/, "'#{application}#{version == "staging" ? "stage" : ""}_'")
  contents.gsub!(/'diy'/, "'#{application}'")
  contents.gsub!(/\# ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS/, "ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS")
  put contents, "#{shared_path}/config/environment.rb"
end

task :create_local_dbs, :roles => :db do
  for i in ["prod", "test", "dev"] do
    cmd_str = "create database #{local_database_prefix}_#{i}; grant all on #{local_database_prefix}_#{i}.* to #{local_username}@'%' identified by '#{local_password}';"
    run "echo \"#{cmd_str}\" | mysql -u subroot -p#{subroot_pass}"
  end
end

task :write_database_conf, :roles => :app do
  real = {"prod" => "production", "test" => "test", "dev" => "development"}
  
  db_config = {}
  db_config["production"] = {}
  db_config["test"] = {}
  db_config["development"] = {}
  
  # pp db_config
  for i in ["prod", "test", "dev"] do
    db_config[real[i]]['adapter'] = "mysql"
    db_config[real[i]]['database'] = "#{local_database_prefix}_#{i}"
    db_config[real[i]]['username'] = local_username
    db_config[real[i]]['password'] = local_password
    db_config[real[i]]['host'] = "localhost"
  end

  put YAML::dump(db_config), "#{shared_path}/config/database.yml"
end

task :write_sds_conf, :roles => :app do
  set :sds_conf, {}
  sds_conf["development"] = {}
  sds_conf["production"] = {}
  
  for i in ["production", "development"] do
    sds_conf[i]["host"] = sds_host
    sds_conf[i]["jnlp_id"] = sds_jnlp_id
    sds_conf[i]["curnit_id"] = sds_curnit_id
    sds_conf[i]["username"] = ""
    sds_conf[i]["password"] = ""
  end
  
  put YAML::dump(sds_conf), "#{shared_path}/config/sds.yml"
end

task :write_mailer_conf, :roles => :app do
  set :mailer_conf, {}
  mailer_conf["address"] = "internalsmtp.concord.org"
  mailer_conf["port"] = "25"
  mailer_conf["domain"] = "concord.org"
  
  put YAML::dump(mailer_conf), "#{shared_path}/config/mailer.yml"
end

task :write_exception_notifier_config, :roles => :app do
  set :the_addresses, email_addresses.split(";")
  
  put YAML::dump(email_addresses.split(";")), "#{shared_path}/config/exception_notifier_recipients.yml"
end

desc "set up the database on a brand new diy"
task :setup_new_diy, :roles => :app do
  run "cd #{current_release}; RAILS_ENV=production rake diy:setup_new_database"
end

task :disable_web, :roles => :web do
  on_rollback { run "rm #{current_path}/public/system/maintenance.html" }

  put render("maintenance.rhtml"), "#{current_path}/public/system/maintenance.html"
end

task :enable_web, :roles => :web do
  run "rm #{current_path}/public/system/maintenance.html"
end

def render(template_file)
  require 'erb'
  template = File.read(erb_templates_folder + "/" + template_file)
  result = ERB.new(template).result(binding)  
end



desc "calls user.save for every user"
task :save_all_users, :roles => :app do
  run "cd #{current_release}; script/runner -e production 'User.find(:all).each{|u| u.save }'"
end

desc "verify the action"
task :verify_action, :roles => :app do
  puts <<-EOM
  *******************************************************************
  Running the #{version} stage
  Deploying to #{deploy_to}
  App name: #{clean_app_name}
  Server Type: #{server_type}
  *******************************************************************
  EOM
  abort unless Capistrano::CLI.ui.agree( "Does that sound right? (y/n) ",true)
end

desc "set the server type (passenger or mogrel)"
task :set_server_type do
  if use_passenger
    set :server_type, "passenger"
    
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
  else
    # this is the default, and the stages were defined elsewhere..
    # TODO: Where are the mongrel tasks defined?
    set :server_type, "mogrel"
  end
end
