# === Module OTrunkSystem
#
# include OtrunkSystem in any model that is the basis for an
# OTrunk document. This means that OTrunkSystem must be included
# in all runnable object classes.
#
module OtrunkSystem
  include ActionController::UrlWriter

  # The short_name is used as part of the jnlp filename.
  # It should be run whenever the name of the runnable changes.
  def generate_short_name
    self.short_name = self.name.strip.downcase.gsub(/\W+/, '_').gsub(/^_+|_+$/, '')
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

  # Figure out the codebase of the otml file
  # nil is returned if a codebase is not necessary
  # this method assumes the save method has been called so the otml is updated
  def otml_codebase
    # does the otml file set an explicit codebase?
    existing_codebase = otml[/<otrunk.*?codebase=["'](.*?)["'']>/, 1]
    if existing_codebase
      return nil
    end

    if external_otml_always_update
      # set the codebase to the dir on the external web server that delivered the otml
      File.dirname(external_otml_url)
    elsif (APP_PROPERTIES[:cache_external_otrunk_activities] == true) && (self.kind_of? ExternalOtrunkActivity)
      # this won't be a reasonable codebase unless we first run a script
      # which creates a local cache directory and copies all the resources there.
      # in that case the :cache_external_otrunk_activities property should be true
      # currently this approach is only used for ExternalOtrunkActivityS 
      File.dirname(cached_otml_url)
    else
      # if always update is false and there is no cache of resrouces then return nil
      #  indicating a codebase doesn't need to be set
      nil
    end
  end

  # If external_otml_url is not nil and either
  # * the otml attribute is empty or
  #   the external_otml_always_update is set
  # then cache a local copy of the otml
  # referenced by the utl.
  def check_for_external_otml
    unless self.external_otml_url.blank?
      if self.otml.blank? || self.external_otml_always_update
        begin
          open(self.external_otml_url, :ssl_verify => false) do |f|
            self.otml = f.read
            self.external_otml_last_modified = f.last_modified
            self.external_otml_filename = File.basename(self.external_otml_url)
            true
          end
        rescue SocketError # getaddrinfo?
        rescue OpenURI::HTTPError
        end
      else
        nil
      end
    else
      nil
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