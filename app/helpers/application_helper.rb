# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def boolean_to_yes_no(b)
    b ? 'yes' : 'no'
  end

  # st = YAML::load(`svn info #{RAILS_ROOT}`)["Last Changed Date"]
  #   => "2008-07-25 10:04:45 -0400 (Fri, 25 Jul 2008)"
  # gmt_time_from_svn_time(st)
  #   => "Fri, 25 Jul 2008 14:04:45 GMT"
  #
  def gmt_time_from_svn_time(svn_time)
    iso8601_time = "#{svn_time[/(.*) -/, 1].gsub(/ /, 'T')}"
    Time.xmlschema(iso8601_time).gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")
  end

  def fix_web_start_warning
    %{<p><b>Mac OS X Note: </b>If you are using Java 1.5 on MacOS 10.4 or 10.5 you will almost certainly need to run some version of our <a href="http://confluence.concord.org/display/CCTR/How+to+fix+Mac+OS+X+WebStart+bugs" title="Java 1.5.0_06, 1.5.0_07, 1.5.0_13 and 1.5.0_16 on MacOS X 10.4 and 10.5 have a bug in their implementation of Java Web Start that can cause the downloading of a Java resource to fail. You may notice this bug when the progress bar in the Java Web Start status window freezes while downloading a Java jar resource.">Fix MacOS Java 1.5 Web Start Scripts</a> once on each computer you run the Concord SAIL-OTrunk activities on. If you update Java on your Macintosh you will need to fix this problem again. The problem appears on Mac OS X computers when starting a Java Web Start program you have run before -- if a jar file needs to be updated the download process will freeze without completing.</p>}
  end

  # This method will work the same as image_path
  # image_path("image.gif") => /images/image.gif
  # however if there is an optional parameter hash like this:
  # image_path("image.gif", :only_path => false) => http://rails.host.com/images/image.gif
  def image_url(path, options=nil)
    p = image_path(path)
    if options
      my_rewrite_url(p, options)
    else
      p
    end
  end

  # loads file, evaluates with ERB, then returns result of evaluating with YAML
  def open_yaml(file)
    begin
      return YAML::load(ERB.new(IO.read(file)).result)
    rescue
      # logger.warn("Couldn't open file: #{file}")
      return nil
    end
  end
  
  # my_rewrite_url grabbed from ActionController::UrlRewriter, file: url_rewriter.rb 
  def my_rewrite_url(path, options)
    rewritten_url = ""
    unless options[:only_path]
      rewritten_url << (options[:protocol] || request.protocol)
      rewritten_url << (options[:host] || request.host_with_port)
    end
#    rewritten_url << request.relative_url_root.to_s unless options[:skip_relative_url_root]
    rewritten_url << path
    rewritten_url << '/' if options[:trailing_slash]
    rewritten_url << "##{options[:anchor]}" if options[:anchor]
    rewritten_url
  end

  def public_url
    url =  "#{request.protocol}#{request.host_with_port}#{request.relative_url_root}"
  end
  
  def display_xml(content)
    begin
      # body = XmlSimple.new().xml_in(content, {'keeproot' => true})
      # "<pre>#{CGI.escapeHTML(XmlSimple.xml_out(body, {'keeproot' => true}))}</pre>"
      "<pre>#{CGI.escapeHTML(content)}</pre>"
    rescue
      msg = "<p>This content is not well formed XML.</p>"
      msg << "<pre>#{CGI.escapeHTML(body)}</pre>"
    end
  end
  
  # Creates a list in standard english form
  # from array of words.
  #
  # Examples:
  #
  #    english_list(%w{one two three four}) 
  #      => "one, two, three, and four"
  #    english_list(%w{one two three}) 
  #      => "one, two, and three"
  #    english_list(%w{one two}) 
  #      => "one and two"
  #    english_list(%w{one}) 
  #      => "one"
  #    english_list([]) 
  #      => ""
  #    english_list() 
  #      => ""
  def english_list(items=[])
    len = items.length
    case len
    when 0
      ""
    when 1
      items[0]
    when 2
      items[0] + ' and ' + items[1]
    else
      items[0..len-2].join(', ') + ', and ' + items.last
    end
  end
end
