# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

if RUBY_PLATFORM =~ /java/
   require 'rubygems'
   RAILS_CONNECTION_ADAPTERS = %w(jdbc)
end

# This key is used to select the look and feel of the application
RAILS_APPLICATION_KEY = 'diy'

USE_OVERLAYS = false

# # set to true if you want to use per-student and per-group overlays (customizations) with your activities
# USE_OVERLAYS = true
# 
# # if you need to authenticate to your overlay server uncomment and modify the next two lines
# # OVERLAY_SERVER_USERNAME = "user"
# # OVERLAY_SERVER_PASSWORD = "password"
# 
# require 'socket'
# # If you want to use overlays, define OVERLAY_SERVER_ROOT
# # You MUST create this root directory manually!
# OVERLAY_SERVER_ROOT = "http://webdav.diy.concord.org/seymour.concord.org/#{RAILS_APPLICATION_KEY}/"
# # otherwise, make OVERLAY_SERVER_ROOT = false
# # OVERLAY_SERVER_ROOT = false


# require 'rubygems'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  # You have to specify the :lib option for libraries, where the Gem name (sqlite3-ruby) differs from the file itself (sqlite3)
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  
  config.gem 'RedCloth'
  config.gem 'diff-lcs', :version => '1.1.2', :lib => 'diff/lcs'
  config.gem 'uuidtools', :version => '1.0.3'
  config.gem 'will_paginate', :version => '2.2.2'

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
  config.time_zone = 'UTC'

  # The internationalization framework can be changed to have another default locale (standard is :en) or more load paths.
  # All files from config/locales/*.rb,yml are added automatically.
  # config.i18n.load_path << Dir[File.join(RAILS_ROOT, 'my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  # config.action_controller.session = {
  #   :session_key => '_test22_session',
  #   :secret      => '34babf2f0f98ed159b0bd4386b937627b5c486c9077b847b072842691d671f653778621b3d48cf3c574956529960e8e31ba77f202fd2221f21080138e99acd91'
  # }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # Please note that observers generated using script/generate observer need to have an _observer suffix
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  
  # Disable request forgery protection for now ...
  # needs to be fixed ...
  # see: http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection/ClassMethods.html#M000300
  config.action_controller.allow_forgery_protection = false
  

  # Before we add the gems unpacked into vendor/gems first see if there 
  # is a newer version of RedCloth installed and get it on the load path first.    
  # begin
  #   gem 'RedCloth', '> 3.0.4' 
  #   require 'redcloth'
  # rescue Gem::LoadError 
  #   # If this fails we'll use the RedCloth v3.0.4 in vendor/gems
  # end

  # This adds any Gems that may have been unpacked into vendor/gems to the load path
  # see: http://errtheblog.com/posts/50-vendor-everything
  # config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
  #   File.directory?(lib = "#{dir}/lib") ? lib : dir
  # end
  
  config.action_controller.perform_caching = true
end
