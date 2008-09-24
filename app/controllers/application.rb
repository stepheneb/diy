# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  SdsConnect::Connect.setup
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # protect_from_forgery :secret => 'ace4fa914693f0739e588729756205e7'

  include ExceptionNotifiable if EXCEPTION_NOTIFIER_CONFIGS_EXISTS
  
  # Exception Notifier doesn't send emails when the ip address is local.
  # Uncomment the next line if you'd like no ip addreses to be considered local.
  # local_addresses.clear
  # Exception Notifier also only sends emails when you are running in production mode.
  # Uncomment the next line if you want to test in development mode.
  # alias :rescue_action_locally :rescue_action_in_public

  session :off, :if => proc { |request| (request.env['CONTENT_TYPE'] == "application/xml") || (request.env['HTTP_ACCEPT'] == "application/xml")}

  session :session_key => "_#{APP_PROPERTIES[:application_name]}_#{ Base64.encode64(Digest::MD5.digest(Socket.gethostname))}_session_id".gsub(/\W/, '_')
  
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  #  before_filter :login_from_cookie_or_basic_http

  before_filter :check_for_subdomains
  
  # see: http://weblog.rubyonrails.com/2006/8/21/filtered-parameter-logging
  filter_parameter_logging "password"
  before_filter :check_user
  
  # use the same behavior for permission_denied and access_denied
  alias :permission_denied :access_denied

  around_filter :log_memory_filter

  private

  def check_for_subdomains
    @subdomains = request.subdomains.join(', ')
  end
  
  def log_memory_filter
    GC.disable
    start_mem = log_memory("START")
    yield
    log_memory("END", start_mem)
    GC.enable
    GC.start
  end
  
  def log_memory(cust, smem = 0)
    pid = Process.pid
    str = `ps -o vsz -p #{pid}`
    req = request.env["REQUEST_URI"]
    mem = str[/[0-9]+/]
    if smem == 0
      logger.info("#{cust} -- PID: #{pid} -- MEM: #{mem} -- METHOD: #{request.method.to_s} -- REQ: #{req}")
    else
      logger.info("#{cust} -- PID: #{pid} -- MEM: #{mem} -- DELTA: #{mem.to_i - smem.to_i} -- METHOD: #{request.method.to_s} -- REQ: #{req}")
    end
    return mem
  end

  def check_user
    @anonymous_user = User.anonymous
    self.current_user = @anonymous_user unless login_from_basic_http || logged_in?
  end

  def check_authentication
    if self.current_user.email == "anonymous"
      session[:intended_action] = [controller_name, action_name] 
      flash[:warning]  = "You need to be logged in first."
      redirect_to login_url 
    end
  end

  # converts a hash's string values
  # into their connonical representations 
  def convert_hash_values(hash)
    new_hash = {}
    hash.each do |k, v|
      new_v = case
      when v == "true" : true
      when v == "nil" : nil
      when v == "0" : 0
      else
        if v.to_i != 0 
          v.to_i
        else
          v
        end
      end
      new_hash[k]=new_v
    end
    new_hash
  end
  # parse_query_parameters and the class UrlEncodedPairParser
  # are copied from action_controller/request.rb
  # because they made this method and class private!
  def parse_query_parameters(query_string)
    return {} if query_string.blank?

    pairs = query_string.split('&').collect do |chunk|
      next if chunk.empty?
      key, value = chunk.split('=', 2)
      next if key.empty?
      value = value.nil? ? nil : CGI.unescape(value)
      [ CGI.unescape(key), value ]
    end.compact

    UrlEncodedPairParser.new(pairs).result
  end
  
      
  def mkcol(uri)
    require 'net/http' 
    Net::HTTP.start(uri.host) do |http| 
      response = http.mkcol(uri.path)
      logger.info "response code: #{response.code}"
      if response.code.to_i < 200 || response.code.to_i >= 400
        raise "Error creating parent folder for overlay files"
      end
    end
  end
  
  def setup_overlay_folder(runnable_id)
    # make sure the webdav subfolder(s) exist first
    useOverlays = OVERLAY_SERVER_ROOT && true
    if useOverlays
      begin
        mkcol URI.parse("#{OVERLAY_SERVER_ROOT}/#{runnable_id}")
      rescue Exception => e
        useOverlays = false
        logger.warn "error in overlays: #{e}\n#{e.backtrace.join("\n")}"
      end
    end
    return useOverlays
  end
  
  def setup_default_overlay(runnable_id, overlay_id)
    # make sure the webdav subfolder(s) exist first
    if setup_overlay_folder(runnable_id)
      # if the file doesn't exist...
      uri = URI.parse("#{OVERLAY_SERVER_ROOT}/#{runnable_id}/#{overlay_id}.otml")
      res = Net::HTTP.get_response(uri)
      if res.code.to_i < 200 || res.code.to_i >= 400
        # create it
        uuid = UUID.timestamp_create().to_s
        otml = "<otrunk id='#{uuid}'><imports><import class='org.concord.otrunk.overlay.OTOverlay' /></imports><objects><OTOverlay /></objects></otrunk>"
        require 'net/http'
        Net::HTTP.start(uri.host) do |http| 
          response = http.put(uri.path, otml)
          logger.info "response code: #{response.code}"
          if response.code.to_i < 200 || response.code.to_i >= 400
            raise "Error creating default overlay file"
          end
        end
      end
    end
  end

  def getOtrunkID(node, root, num = -1)
    if node.has_attribute? "refid"
      node.get_attribute("refid")
    elsif node.has_attribute? "id"
      node.get_attribute("id")
    elsif node.has_attribute? "local_id"
      "#{root.get_attribute("id")}!/#{node.get_attribute("local_id")}"
    else
      node_id = ""
      case num
        when -1
          node_id = "/" + node.name
        when nil
          node_id = ""
        else
          node_id = "[#{num}]"
      end
      # cycle through the parents
      "#{getOtrunkID(node.parent, root)}#{node_id}"
    end
  end
  
  class UrlEncodedPairParser < StringScanner #:nodoc:
    attr_reader :top, :parent, :result

    def initialize(pairs = [])
      super('')
      @result = {}
      pairs.each { |key, value| parse(key, value) }
    end

    KEY_REGEXP = %r{([^\[\]=&]+)}
    BRACKETED_KEY_REGEXP = %r{\[([^\[\]=&]+)\]}

    # Parse the query string
    def parse(key, value)
      self.string = key
      @top, @parent = result, nil

      # First scan the bare key
      key = scan(KEY_REGEXP) or return
      key = post_key_check(key)

      # Then scan as many nestings as present
      until eos?
        r = scan(BRACKETED_KEY_REGEXP) or return
        key = self[1]
        key = post_key_check(key)
      end

      bind(key, value)
    end

    private
    # After we see a key, we must look ahead to determine our next action. Cases:
    #
    #   [] follows the key. Then the value must be an array.
    #   = follows the key. (A value comes next)
    #   & or the end of string follows the key. Then the key is a flag.
    #   otherwise, a hash follows the key.
    def post_key_check(key)
      if scan(/\[\]/) # a[b][] indicates that b is an array
        container(key, Array)
        nil
      elsif check(/\[[^\]]/) # a[b] indicates that a is a hash
        container(key, Hash)
        nil
      else # End of key? We do nothing.
        key
      end
    end

    # Add a container to the stack.
    def container(key, klass)
      type_conflict! klass, top[key] if top.is_a?(Hash) && top.key?(key) && ! top[key].is_a?(klass)
      value = bind(key, klass.new)
      type_conflict! klass, value unless value.is_a?(klass)
      push(value)
    end

    # Push a value onto the 'stack', which is actually only the top 2 items.
    def push(value)
      @parent, @top = @top, value
    end

    # Bind a key (which may be nil for items in an array) to the provided value.
    def bind(key, value)
      if top.is_a? Array
        if key
          if top[-1].is_a?(Hash) && ! top[-1].key?(key)
            top[-1][key] = value
          else
            top << {key => value}.with_indifferent_access
            push top.last
          end
        else
          top << value
        end
      elsif top.is_a? Hash
        key = CGI.unescape(key)
        parent << (@top = {}) if top.key?(key) && parent.is_a?(Array)
        return top[key] ||= value
      else
        raise ArgumentError, "Don't know what to do: top is #{top.inspect}"
      end

      return value
    end

    def type_conflict!(klass, value)
      raise TypeError, "Conflicting types for parameter containers. Expected an instance of #{klass} but found an instance of #{value.class}. This can be caused by colliding Array and Hash parameters like qs[]=value&qs[key]=value."
    end
  end

  # see: http://snippets.dzone.com/posts/show/1799
  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::DateHelper
  end
    
end
