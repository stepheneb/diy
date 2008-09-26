# http://rubyreports.org
# require 'ruport'

# see: http://github.com/mislav/will_paginate/wikis/installation
require 'will_paginate'

path = if Dir.getwd =~ /\/public$/ then "../" else "" end 
APP_PROPERTIES =  YAML::load(ERB.new(IO.read("#{path}config/#{RAILS_APPLICATION_KEY}.yml")).result)

unless APP_PROPERTIES[:external_otrunk_activities_title]
  APP_PROPERTIES[:external_otrunk_activities_title] = "Otrunk Activity"
end

CGI::Session::ActiveRecordStore::Session.table_name = "#{RAILS_DATABASE_PREFIX}sessions"

# If you want to use overlays, define OVERLAY_SERVER_ROOT
# You MUST create this root directory manually!
require 'socket'
require 'open-uri'
server_root = "http://rails.dev.concord.org/webdav/#{Socket::gethostname}/#{RAILS_APPLICATION_KEY}"
begin
  doc = open(server_root)
  OVERLAY_SERVER_ROOT = server_root
rescue => e
  $stderr.puts "Asking for the OVERLAY_SERVER_ROOT (#{server_root}) returned an error (#{e})!\nNot using overlays..."
  OVERLAY_SERVER_ROOT = false
end
# otherwise, make OVERLAY_SERVER_ROOT = false
# OVERLAY_SERVER_ROOT = false

module ActiveRecord
  class Migrator
    def Migrator.schema_info_table_name
      Base.table_name_prefix + "#{RAILS_DATABASE_PREFIX}schema_info" + Base.table_name_suffix
    end
  end
end

# application key specific layouts, if they exist, otherwise use the default layout
module ActionController
  module Layout
    module ClassMethods
      def layout(template_name, conditions = {}, auto = false)
        add_layout_conditions(conditions)
        # custom code here
          possible_layouts = layout_list.select{|path| path =~ /#{template_name}-#{RAILS_APPLICATION_KEY}/}
          if possible_layouts.size > 0
            template_name = "#{template_name}-#{RAILS_APPLICATION_KEY}"
          end
        # end custom code
        write_inheritable_attribute "layout", template_name
        write_inheritable_attribute "auto_layout", auto
      end
    end
  end
end

# To enable the Exception Notifier plugin look at sample configurations in config/ and:
# 1) Create config/mailer.yml with the smtp host settings for sending mail.
# 2) Create config/exception_notifier_recipients.yml with the list of address to receive mails.
MAILER_CONFIG_EXISTS = File.exists?("#{RAILS_ROOT}/config/mailer.yml")
if MAILER_CONFIG_EXISTS
  EXCEPTION_NOTIFIER_CONFIGS_EXISTS = File.exists?("#{RAILS_ROOT}/config/exception_notifier_recipients.yml")
else
  EXCEPTION_NOTIFIER_CONFIGS_EXISTS = nil
end
if EXCEPTION_NOTIFIER_CONFIGS_EXISTS
  ExceptionNotifier.exception_recipients = YAML::load(IO.read("#{RAILS_ROOT}/config/exception_notifier_recipients.yml"))
  # Sender address: defaults to exception.notifier@default.com
  ExceptionNotifier.sender_address = %("[DIY ERROR]: #{APP_PROPERTIES[:application_name]}" <#{RAILS_DATABASE_PREFIX}error@concord.org>)
  # defaults to "[ERROR] "
  ExceptionNotifier.email_prefix = "[DIY ERROR]: #{APP_PROPERTIES[:application_name]} "
end

# Load included libraries.

require 'redcloth'

require 'uuidtools'

require 'sds_connect'
SdsConnect::Connect.setup

require 'diff/lcs'
require 'diff/lcs/string'
require 'htmldiff'
require 'symboldiff'

require 'open-uri'
require 'open_uri_hack_https'
OpenSSL::SSL::VERIFY_NONE
