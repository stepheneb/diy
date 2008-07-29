# maybe use these recipes because we are using mongrel_cluster on the server
# where are they documented?
require 'mongrel_cluster/recipes'

set :application, "diy"
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
after "deploy:update_code", :copy_configs
after "deploy:symlink", :chown_folders

task :copy_configs, :roles => :app do
  run "cp #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "cp #{shared_path}/config/environment.rb #{release_path}/config/environment.rb"
  run "cp #{shared_path}/config/sds.yml #{release_path}/config/sds.yml"
end

task :chown_folders, :roles => :app do
  run "sudo chown -R mongrel.users #{release_path}"
end

task :production do
  set :version, "production"
  ask_instance
  set_vars
end

task :staging do
  set :version, "staging"
  ask_instance
  set_vars
end

task :ask_instance do
  if ! application || application == "diy"
    set(:application) do
      Capistrano::CLI.ui.ask "Enter the instance name (eg itsi, udl, capa): "
    end
  end
end

task :set_vars do
  # If you aren't deploying to /u/apps/#{application} on the target
   # servers (which is the default), you can specify the actual location
  # via the :deploy_to variable:
  set :deploy_to, "/web/#{version}/#{application}"
  
  set :mongrel_conf, "/etc/mongrel_cluster/#{version}-#{application}.yml"
  
  depend :remote, :file, "#{shared_path}/config/database.yml"
  depend :remote, :file, "#{shared_path}/config/environment.rb"
  depend :remote, :file, "#{shared_path}/config/sds.yml"
end

task :chown_to_current_user, :roles => :app do
  run "sudo chown -R #{user}.users #{deploy_to}"
  run "sudo chmod -R g+w #{deploy_to}"
end

task :copy_current_config, :roles => :app do
  set :config_dir, "#{shared_path}/config"
  set :otto_config, "/web/rails.dev.concord.org/#{application}diy/config"
  run "mkdir -p #{config_dir}"
  run "scp otto:#{otto_config}/database.yml #{config_dir}/database.yml"
  run "scp otto:#{otto_config}/sds.yml #{config_dir}/sds.yml"
  run "scp otto:#{otto_config}/environment.rb #{config_dir}/environment.rb"
  # write_environment
  write_mongrel_conf
  write_apache_conf
end

task :write_mongrel_conf, :roles => :app do
  if ! start_port
    set(:start_port) do
      Capistrano::CLI.ui.ask "Enter the starting port number: "
    end
  end
  file = %Q!
---
cwd: /web/#{version}/#{application}/current
log_file: log/mongrel.log
port: "#{start_port}"
environment: production
address: 127.0.0.1
pid_file: tmp/pids/mongrel.pid
servers: 10
!

  put file, "#{shared_path}/config/mongrel_cluster.yml"
  run "sudo cp #{shared_path}/config/mongrel_cluster.yml /etc/mongrel_cluster/#{version}-#{application}.yml"
end

task :write_apache_conf, :roles => :app do
  if ! start_port
    set(:start_port) do
      Capistrano::CLI.ui.ask "Enter the starting port number: "
    end
  end
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

\t### Proxy Configuration ###

\tProxyPass /images !
\tProxyPass /stylesheets !
\tProxyPass / balancer://#{application}-#{version}-cluster
\tProxyPassReverse / balancer://#{application}-#{version}-cluster

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
  put contents, "#{shared_path}/config/environment.rb"
end
