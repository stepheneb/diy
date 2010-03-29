# === Module OTrunkSystem
#
# include OtrunkSystem in any model that is the basis for an
# OTrunk document. This means that OTrunkSystem must be included
# in all runnable object classes.
#
module OtrunkSystem
  include ActionController::UrlWriter
  
  require 'hpricot'
  require 'concord_cacher'

  # The short_name is used as part of the jnlp filename.
  # It should be run whenever the name of the runnable changes.
  def generate_short_name
    self.short_name = self.name.strip.downcase.gsub(/\W+/, '_').gsub(/^_+|_+$/, '')
  end
  
  def otml_url(user, controller, options = {} )
    options.merge({:savedata => false, :nobundles => false, :author => false, :reporting => false}) {|k,o,n| o}
    learner = self.find_or_create_learner(user)
    if self.kind_of? ExternalOtrunkActivity
      unless (APP_PROPERTIES[:cache_external_otrunk_activities] == true)
        if (self.external_otml_url && ! self.external_otml_url.empty?)
          my_otml_url = self.external_otml_url
        else
          my_otml_url = controller.url_for(:only_path => false, :action => "otml", :vid => user.vendor_interface.id, :uid => user.id, :lid => learner.id, :savedata => options[:savedata])
        end
      else
        my_otml_url = self.cached_otml_url
      end
    else
      my_otml_url = controller.url_for(:only_path => false, :action => "otml", :vid => user.vendor_interface.id, :uid => user.id, :lid => learner.id, :savedata => options[:savedata])
    end
    my_otml_url
  end

  def external_otml_url
    if Thread.current[:request] && read_attribute(:external_otml_url) && ! read_attribute(:external_otml_url).blank?
      u = URI.parse("#{Thread.current[:request].protocol}#{Thread.current[:request].host}:#{Thread.current[:request].port}/#{Thread.current[:request].path}")
      u.merge(read_attribute(:external_otml_url)).to_s
    else
      read_attribute(:external_otml_url)
    end
  end

  def cached_otml_url
    if Thread.current[:request] && self.uuid
      u = URI.parse("#{Thread.current[:request].protocol}#{Thread.current[:request].host}:#{Thread.current[:request].port}/#{Thread.current[:request].path}")
      path = "/cache/#{self.uuid}/#{self.uuid}.otml"
      if ActionController::AbstractRequest.relative_url_root
        path = "#{ActionController::AbstractRequest.relative_url_root}#{path}"
      end
      path.gsub!(/^[\/]+/,"/")
      u.merge(path).to_s
    else
      read_attribute(:external_otml_url)
    end
  end
  
  def cache_external_otml
    if self.external_otml_url
      cache_dir = File.join("#{RAILS_ROOT}",'public','cache') + '/'
      cacher = Concord::DiyLocalCacher.new(:url => self.external_otml_url, :activity => self, :cache_dir => cache_dir)
      cacher.cache
    end
  end
  
  def otml=(otml)
    self[:otml] = otml
  end
  
  def otml
    check_for_external_otml if should_update_from_external_url?
    generated_otml = self[:otml]
    if use_cached_location? || ! existing_codebase?
      generated_codebase = generate_otml_codebase
      if generated_codebase
        otml_xml_doc = Hpricot.XML(generated_otml)
        otml_xml_doc.search("/otrunk").set(:codebase,  generated_codebase)
        generated_otml = otml_xml_doc.to_s
      end
    end
    generated_otml
  end
  
  def use_cached_location?
    return (APP_PROPERTIES[:cache_external_otrunk_activities] == true) && (self.kind_of?(ExternalOtrunkActivity) || self.kind_of?(OtrunkReportTemplate))
  end

  # Figure out the codebase of the otml file 
  # nil is returned if a codebase is not necessary 
  # this method assumes the save method has been called so the otml is updated 
  def generate_otml_codebase 
    if external_otml_always_update 
      # set the codebase to the dir on the external web server that delivered the otml 
      File.dirname(external_otml_url) 
    elsif use_cached_location?
      # this won't be a reasonable codebase unless we first run a script 
      # which creates a local cache directory and copies all the resources there. 
      # in that case the :cache_external_otrunk_activities property should be true 
      # currently this approach is only used for ExternalOtrunkActivityS  
      File.dirname(cached_otml_url) 
    else 
      # if always update is false and there is no cache of resources then return nil 
      #  indicating a codebase doesn't need to be set 
      nil
    end
  end

  def existing_codebase?
    existing_codebase = self[:otml][/<otrunk.*?codebase=["'](.*?)["']>/, 1] 
  end

  # If external_otml_url is not nil and either
  # * the otml attribute is empty or
  #   the external_otml_always_update is set
  # then cache a local copy of the otml
  # referenced by the utl.
  def check_for_external_otml
    if should_update_from_external_url?
      begin
        open(self.external_otml_url, :ssl_verify => false) do |f|
          self[:otml] = f.read
          self.external_otml_last_modified = f.last_modified
          self.external_otml_filename = File.basename(self.external_otml_url)
        end
        rescue SocketError # getaddrinfo?
        rescue OpenURI::HTTPError
      end
    end
    true
  end
  
  def should_update_from_external_url?
    case
    when self.external_otml_url.blank? : nil
    when self[:otml] && ! self.external_otml_always_update : nil
    else true
    end
  end

  # Using this method to check if the locally cached
  # otml needs to be updated is only useful if the cost 
  # of a round-trip network access with HTTP HEAD is a 
  # small fraction of the cost of an HTTP GET.
  def calc_external_otml_last_modified
    unless self.external_otml_url.blank?
      u = URI.parse(self.external_otml_url)
      Net::HTTP.start(u.host, u.port) {|http| http.head(u.path)}['last-modified'].to_time
    end
  end
end
