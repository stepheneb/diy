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

set :mydebug, false

set(:subroot_pass) do
  Capistrano::CLI.password_prompt( "Enter the subroot mysql password: ")
end

set(:start_port) do
  Capistrano::CLI.ui.ask "Enter the starting port number: "
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

task :copy_configs, :roles => :app do
  run "cp #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "cp #{shared_path}/config/environment.rb #{release_path}/config/environment.rb"
  run "cp #{shared_path}/config/sds.yml #{release_path}/config/sds.yml"
  run "cp #{shared_path}/config/mailer.yml #{release_path}/config/mailer.yml"
  run "cp #{shared_path}/config/exception_notifier_recipients.yml #{release_path}/config/exception_notifier_recipients.yml"
end

task :chown_folders, :roles => :app do
  sudo "chown -R mongrel.users #{deploy_to}"
  sudo "chmod -R g+w #{deploy_to}"
end

task :production do
  set :version, "production"
  set_vars
end

task :staging do
  set :version, "staging"
  set_vars
end

task :set_vars do
  # If you aren't deploying to /u/apps/#{application} on the target
   # servers (which is the default), you can specify the actual location
  # via the :deploy_to variable:
  set :deploy_to, "/web/#{version}/#{application}"
  
  set :mongrel_conf, "/etc/mongrel_cluster/#{version}-#{application}.conf"
  
  depend :remote, :file, "#{shared_path}/config/database.yml"
  depend :remote, :file, "#{shared_path}/config/environment.rb"
  depend :remote, :file, "#{shared_path}/config/sds.yml"
  depend :remote, :file, "#{shared_path}/config/mailer.yml"
  depend :remote, :file, "#{shared_path}/config/exception_notifier_recipients.yml"
end

task :chown_to_current_user, :roles => :app do
  sudo "chown -R #{user}.users #{deploy_to}"
  sudo "chmod -R g+w #{deploy_to}"
end

task :copy_current_config, :roles => :app do
  set :config_dir, "#{shared_path}/config"
  run "mkdir -p #{config_dir}"
  set_db_vars
  create_local_dbs
  write_database_conf
  write_sds_conf
  write_environment
  write_mongrel_conf
  write_apache_conf
  write_mailer_conf
  write_exception_notifier_config
end

task :write_mongrel_conf, :roles => :app do
  set :num_servers, version == "staging" ? 3 : 6
  
  file = %Q!
---
cwd: /web/#{version}/#{application}/current
log_file: log/mongrel.log
port: "#{start_port}"
environment: production
address: 127.0.0.1
pid_file: tmp/pids/mongrel.pid
servers: #{num_servers}
user: mongrel
group: users
!

  put file, "#{shared_path}/config/mongrel_cluster.conf"
  sudo "cp #{shared_path}/config/mongrel_cluster.conf /etc/mongrel_cluster/#{version}-#{application}.conf"
end

task :write_apache_conf, :roles => :app do
  file = %Q~
# This sets up a mongrel balancer (name should be servername-cluster)

<Proxy balancer://#{application}-#{version}-cluster>
\tBalancerMember http://127.0.0.1:#{start_port.to_i + 0}
\tBalancerMember http://127.0.0.1:#{start_port.to_i + 1}
\tBalancerMember http://127.0.0.1:#{start_port.to_i + 2}
\tBalancerMember http://127.0.0.1:#{start_port.to_i + 3}
\tBalancerMember http://127.0.0.1:#{start_port.to_i + 4}
\tBalancerMember http://127.0.0.1:#{start_port.to_i + 5}
\tBalancerMember http://127.0.0.1:#{start_port.to_i + 6}
\tBalancerMember http://127.0.0.1:#{start_port.to_i + 7}
\tBalancerMember http://127.0.0.1:#{start_port.to_i + 8}
\tBalancerMember http://127.0.0.1:#{start_port.to_i + 9}

\t# if you want to affect traffic to the proxied machines
\t# add a " loadfactor=n" parameter at the end of one of the above line
</Proxy>

<VirtualHost *:80 *:8080 *:443>
\t### Basic Configuration ###

\tServerAdmin webmaster@concord.org
\tServerName #{application}#{version == "staging" ? ".staging" : ".diy"}.concord.org
\t#{version == "production" ? ("ServerAlias " + application + ".test.concord.org") : ""}
\tDocumentRoot /web/#{version}/#{application}/current/public

\t### Logging Configuration ###

\tErrorLog /var/log/httpd/#{application}.#{version}.concord.org-error_log
\tCustomLog /var/log/httpd/#{application}.#{version}.concord.org-access_log combined
\tCustomLog "|/usr/bin/logger -p local2.info -t #{application}.#{version}.concord.org" combined

\t### ModRewrite Configuration ###

\tRewriteEngine On
        
\t# Should perhaps use modrewrite to fix the www issue instead of the vhost below
\tRewriteCond %{HTTP_HOST} ^www\\.#{application}#{version == "staging" ? ('\.' + version) : ".diy"}\\.concord\\.org$ [NC]
\tRewriteRule ^(.*)$ http://#{application}#{version == "staging" ? ('.' + version) : ".diy"}.concord.org/$1 [R=301,L]

\t# Uncomment for rewrite debugging
\t#RewriteLog logs/myapp_rewrite_log
\t#RewriteLogLevel 9

\t# Check for maintenance file and redirect all requests
\t# ( this is for use with Capistrano's disable_web task )
\tRewriteCond %{DOCUMENT_ROOT}/system/maintenance.html -f
\tRewriteCond %{SCRIPT_FILENAME} !maintenance.html
\tRewriteRule ^.*$ /system/maintenance.html [L]

\t# Rewrite index to check for static
\tRewriteRule ^/$ /index.html [QSA]

\t# Rewrite to check for Rails cached page
\tRewriteRule ^([^.]+)$ $1.html [QSA]

\t# Redirect all non-static requests to cluster
\tRewriteCond %{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f
\tRewriteRule ^/(.*)$ balancer://#{application}-#{version}-cluster%{REQUEST_URI} [P,QSA,L]

\t# Deflate
\tAddOutputFilterByType DEFLATE text/html text/plain text/css
\t# ... text/xml application/xml application/xhtml+xml text/javascript
\tBrowserMatch ^Mozilla/4 gzip-only-text/html
\tBrowserMatch ^Mozilla/4.0[678] no-gzip
\tBrowserMatch \\bMSIE !no-gzip !gzip-only-text/html

\t### SSL Configuration ###

\t# To use this server on SSL, copy this virtual host, change it to only have the :443
\t# part in the main directive and uncomment the following lines.

\t#SSLEngine on
\t#SSLCertificateFile /usr/share/ssl/certs/cc-wild-2006.crt
\t#SSLCertificateKeyFile /usr/share/ssl/certs/cc-wild-2006.key
\t#SSLCertificateChainFile /usr/share/ssl/certs/sf_issuing.crt

\t# to convince Rails (via mod_proxy_balancer) that we're actually using HTTPS.
\t#RequestHeader set X_FORWARDED_PROTO 'https'
</VirtualHost>
~
  put file, "/web/#{version}/conf/#{application}.conf"
end

task :write_environment, :roles => :app do
  contents = File.open("config/environment.sample.rb").read
  contents.gsub!(/'diy_'/, "'#{application}#{version == "staging" ? "stage" : ""}_'")
  contents.gsub!(/'diy'/, "'#{application}'")
  contents.gsub!(/\# ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS/, "ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS")
  put contents, "#{shared_path}/config/environment.rb"
end

task :set_db_vars, :roles => :db do
  clean_app_name = application.gsub('-', '_')
    
  set :local_username, "#{clean_app_name}"
  set :local_password, "#{clean_app_name}"
  set :local_database_prefix, "#{version}_#{clean_app_name}"end

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
    sds_conf[i]["password"] = ""  end
  
  put YAML::dump(sds_conf), "#{shared_path}/config/sds.yml"end

task :write_mailer_conf, :roles => :app do
  set :mailer_conf, {}
  mailer_conf["address"] = "internalsmtp.concord.org"
  mailer_conf["port"] = "25"
  mailer_conf["domain"] = "concord.org"
  
  put YAML::dump(mailer_conf), "#{shared_path}/config/mailer.yml"end

task :write_mailer_conf, :roles => :app do
  set :mailer_conf, {}
  mailer_conf["address"] = "internalsmtp.concord.org"
  mailer_conf["port"] = "25"
  mailer_conf["domain"] = "concord.org"
  
  put YAML::dump(mailer_conf), "#{shared_path}/config/mailer.yml"
end

task :write_exception_notifier_config, :roles => :app do
  set :the_addresses, email_addresses.split(";")
  
  put YAML::dump(email_addresses.split(";")), "#{shared_path}/config/exception_notifier_recipients.yml"end

desc "set up the database on a brand new diy"
task :setup_new_diy, :roles => :app do
  run "cd #{current_release}; RAILS_ENV=production rake diy:setup_new_database"end