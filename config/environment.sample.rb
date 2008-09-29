# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'rubygems'

if RUBY_PLATFORM =~ /java/
   RAILS_CONNECTION_ADAPTERS = %w(jdbc)
end

# This key is prefixed onto all the database tablenames.
RAILS_DATABASE_PREFIX = ''

# This key is used to select the look and feel of the application
RAILS_APPLICATION_KEY = 'diy'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  # config.action_controller.session = {
  #   :session_key => '_diy_rails_2.0.2_session',
  #   :secret      => 'c097d3c72e2c1310f862dd1980b296039c76a13051404be6b36970bd750563c60a9ff31b87f912e89b91fa29af333492f6ac03826d3c20a48455bb21dd0ebbd7'
  # }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # Disable request forgery protection for now ...
  # needs to be fixed ...
  # see: http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection/ClassMethods.html#M000300
  config.action_controller.allow_forgery_protection = false

  # Before we add the gems unpacked into vendor/gems first see if there 
  # is a newer version of RedCloth installed and get it on the load path first.    
  begin
    gem 'RedCloth', '> 3.0.4' 
    require 'redcloth'
  rescue Gem::LoadError 
    # If this fails we'll use the RedCloth v3.0.4 in vendor/gems
  end

  # This adds any Gems that may have been unpacked into vendor/gems to the load path
  # see: http://errtheblog.com/posts/50-vendor-everything
  config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
    File.directory?(lib = "#{dir}/lib") ? lib : dir
  end
end

# if you want to set your cookie domain to something other than the request host, uncomment the line below
# ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS[:session_domain] =  '.concord.org'  

# uncomment this line if this application is served from a directory with other rails applications
# ActionController::AbstractRequest.relative_url_root = '/' + RAILS_DATABASE_PREFIX.chomp('_')

# If you are using a relative_url_root and running rails through a fcgi process set
# this envirnment variable so that urls (like a background-image in css) have the
# right path. This hack isn't needed when serving from mongrel.
# See: http://inodes.org/blog/2007/04/04/mongrel-rails-and-the-theory-of-relativity/
# ENV['RAILS_RELATIVE_URL_ROOT'] = ActionController::AbstractRequest.relative_url_root

# If you want to transfer data from another DIY and also want to transfer associated
# learner data stored in an SDS uncomment the following Constant and set the value appropriately
# OLD_SDS_HOST = "http://saildataservice.concord.org/7"

# set to true if you want to use per-student and per-group overlays (customizations) with your activities
USE_OVERLAYS = false

# if you need to authenticate to your overlay server uncomment and modify the next two lines
# OVERLAY_SERVER_USERNAME = "user"
# OVERLAY_SERVER_PASSWORD = "password"

# If you want to use overlays, define OVERLAY_SERVER_ROOT
# You MUST create this root directory manually!
require 'socket'
require 'open-uri'
server_root = "https://rails.dev.concord.org/webdav/#{Socket::gethostname}/#{RAILS_APPLICATION_KEY}/"
begin
  use_http_auth = false
  begin
    use_http_auth = OVERLAY_SERVER_USERNAME && OVERLAY_SERVER_PASSWORD
    $stderr.puts "using auth"
  rescue Exception => e
    # don't use auth
    $stderr.puts "not using auth: #{e}"
  end
  if use_http_auth
    doc = open(server_root, { :ssl_verify => false, :http_basic_authentication => [OVERLAY_SERVER_USERNAME, OVERLAY_SERVER_PASSWORD] }).read
  else
    doc = open(server_root, :ssl_verify => false).read
  end
  OVERLAY_SERVER_ROOT = server_root
rescue => e
  $stderr.puts "Asking for the OVERLAY_SERVER_ROOT (#{server_root}) returned an error (#{e})!\n\nNot using overlays...\n"
  OVERLAY_SERVER_ROOT = false
end
# otherwise, make OVERLAY_SERVER_ROOT = false
# OVERLAY_SERVER_ROOT = false
