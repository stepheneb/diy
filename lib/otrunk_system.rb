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