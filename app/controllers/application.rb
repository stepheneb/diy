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
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.port == 443
      http.use_ssl = true
    end
    http.start() do |conn|
      req = Net::HTTP::Mkcol.new(uri.path)
      begin
        if OVERLAY_SERVER_USERNAME && OVERLAY_SERVER_PASSWORD
          req.basic_auth(OVERLAY_SERVER_USERNAME, OVERLAY_SERVER_PASSWORD)
        end
      rescue Exception
        # don't use authentication
        logger.info("not using auth in mkcol")
      end
      response = conn.request(req)
      logger.info "response code: #{response.code}"
      # svndav returns 405 if a folder already exists
      if response.code.to_i < 200 || (response.code.to_i >= 400 && response.code.to_i != 405)
        raise "Error creating parent folder for overlay files"
      end
    end
  end
  
  def setup_overlay_folder(runnable_id)
    # make sure the webdav subfolder(s) exist first
    useOverlays = false
    begin
      useOverlays = USE_OVERLAYS && OVERLAY_SERVER_ROOT
    rescue Exception
      # don't use overlays
    end
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
      useHttpAuth = false
      begin
        useHttpAuth = OVERLAY_SERVER_USERNAME && OVERLAY_SERVER_PASSWORD
      rescue Exception
        # don't use auth
      end
      begin
        if useHttpAuth
          doc = open("#{OVERLAY_SERVER_ROOT}/#{runnable_id}/#{overlay_id}.otml", :ssl_verify => false, :http_basic_authentication => [OVERLAY_SERVER_USERNAME, OVERLAY_SERVER_PASSWORD] ).read
        else
          doc = open("#{OVERLAY_SERVER_ROOT}/#{runnable_id}/#{overlay_id}.otml", :ssl_verify => false).read
        end
      rescue => e
        logger.warn "Overlay file #{uri.to_s} doesn't exist. Creating it... \n#{e}"
        doc = nil
      end
      if ! doc
        # create it
        uuid = UUID.timestamp_create().to_s
        otml = "<otrunk id='#{uuid}'><imports><import class='org.concord.otrunk.overlay.OTOverlay' /></imports><objects><OTOverlay /></objects></otrunk>"
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.port == 443
          http.use_ssl = true
        end
        http.start() do |conn|
          logger.info("Path is #{uri.path}")
          req = Net::HTTP::Put.new(uri.path)
          req.body = otml
          if useHttpAuth
            req.basic_auth OVERLAY_SERVER_USERNAME, OVERLAY_SERVER_PASSWORD
          end
          response = conn.request(req)
          logger.info "response code: #{response.code}"
          if response.code.to_i < 200 || response.code.to_i >= 400
            return false
          end
        end
      end
      return true
    else
      return false
    end
  end

  def getOtrunkID(node, root, num = -1)
    if node.has_attribute? "refid"
      ref_id = node.get_attribute("refid")
      # if it's a reference to a local_id
      if ref_id =~ /^\$\{(.*)\}$/
        "#{root.get_attribute("id")}!/#{$1}"
      else
        ref_id
      end
    elsif node.has_attribute? "id"
      node.get_attribute("id")
    elsif node.has_attribute? "local_id"
      "#{root.get_attribute("id")}!/#{node.get_attribute("local_id")}"
    else
      node_id = ""
      if num == -1
        node_id = "/" + node.name
        # parent is an object
        num = node.parent.parent.children.select {|c| c.elem? }.index(node.parent)
      elsif num == nil
          node_id = ""
          # parent is an attribute name
          num = -1
      else
        node_id = "[#{num}]"
        # parent is an attribute name
        num = -1
      end
      # cycle through the parents
      pid = getOtrunkID(node.parent, root, num)
      
      # this is to get rid of the first level of attributes
      # e.g. instead of uuid/objects[0]/root it should be uuid//root
      # instead of uuid/objects[0]/bundles[1] it should be uuid//bundles[1]
      node_id =  "/" if (pid == root.get_attribute("id"))
      node_id = "" if (pid == root.get_attribute("id") + "/") && node_id =~ /\[[0-9]+\]/
      
      "#{pid}#{node_id}"
    end
  end
  
  def setup_overlay_requirements(activity)
    require 'hpricot'
      # setup the imports
    otmlDoc = Hpricot.XML(activity.otml)
    @imports = []
    @imports << "org.concord.otrunk.OTIncludeRootObject"
    @imports << "org.concord.otrunk.OTSystem"
    @imports << "org.concord.otrunk.OTInclude"
    
    # get the bundles from the original activity otml
    @bundles = []
    bundles_elem = otmlDoc.search("/otrunk/objects/OTSystem/bundles").first
    if bundles_elem
      bundles = bundles_elem.children.select {|c| c.elem? }
      bundles.each_with_index do |b, i|
        # get the object reference for this element
        @bundles << getOtrunkID(b, otmlDoc.root, i)
      end
    end
    
    # get the overlays from the original activity otml
    @overlays = []
    overlays_elem = otmlDoc.search("/otrunk/objects/OTSystem/overlays").first
    if overlays_elem
      overlays = overlays_elem.children.select {|c| c.elem? }
      overlays.each_with_index do |o, i|
        # get the object reference for this element
        @overlays << getOtrunkID(o, otmlDoc.root, i)
      end
    end
    
    # get root object
    @rootObjectID = nil
    otsystem_elem = otmlDoc.search("/otrunk/objects/OTSystem").first
    if otsystem_elem
      otsystem = otsystem_elem.children.select {|c| c.elem? && c.name == "root"}[0]
      if otsystem
        rootObj = otsystem.children.select {|c| c.elem? }[0]
        @rootObjectID = getOtrunkID(rootObj, otmlDoc.root, nil)
      end
    else
      objects_elem = otmlDoc.search("/otrunk/objects").first
      if objects_elem
        @rootObjectID = getOtrunkID(objects_elem.children.select {|c| c.elem? }[0], otmlDoc.root, 0)
      end
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
