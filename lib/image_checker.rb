require 'net/http'
require 'uri'

class ImageChecker
  
  def self.valid?(url, do_response=true, size_limit=512000)
    valid = false
    begin
      uri = URI.parse(url)
      if do_response
        response = Net::HTTP.get_response(uri)
        if response && response.class == Net::HTTPOK &&
           response.main_type =~ /image/i &&
           response.content_length < size_limit
              valid = true
        end
      else
        valid = true
      end
    rescue Exception => error
      false
    end
    return valid
  end

end