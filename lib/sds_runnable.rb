# === Module SdsRunnable
#
# include SdsRunnable in any model that is the basis for a runnable
# OTrunk instantiation on an SDS.
# 
# runnable objects should also include OtrunkSystem
#
# A runnable object must include the following attributes
#
#  integer "sds_offering_id"
#  string  "short_name"
#  string "uuid"
#
module SdsRunnable
  require 'cgi'
  require 'diff/lcs'
  require 'diff/lcs/string'
  require 'htmldiff'
  require 'symboldiff'
  
  include ActionController::UrlWriter
  default_url_options[:host] = 'www.basecamphq.com'
  
  def sds_url(user, controller, options = {})
    # merge these values into the options hash if they don't exist
    options.merge({:savedata => false, :nobundles => false, :author => false, :reporting => false, :group_id => nil}) {|k,o,n| o}
    learner = self.find_or_create_learner(user)
    learner.create_session unless ! options[:savedata]
    sds_url = "#{SdsConnect::Connect.config['host']}/offering/#{options[:custom_offering_id] ? options[:custom_offering_id] : self.sds_offering_id}/jnlp/#{options[:custom_workgroup_id] ? options[:custom_workgroup_id] : learner.sds_workgroup_id}"
    sds_url << '/view' unless options[:savedata]
    sds_url << '/nobundles' if options[:nobundles]
    
    if options[:otml_url]
      my_otml_url = options[:otml_url]
    elsif options[:use_overlay]
      my_otml_url = controller.url_for(:only_path => false, :action => "overlay_otml", :vid => user.vendor_interface.id, :uid => user.id, :lid => learner.id, :savedata => options[:savedata], :group_id => options[:group_id], :group_list => (options[:group_list] ? options[:group_list] : nil), :group_list_url => (options[:group_list_url] ? options[:group_list_url] : nil) )
    else
      my_otml_url = self.otml_url(user, controller, options)
    end
    
    jnlp_url = "#{sds_url}?sailotrunk.otmlurl=#{URI.escape(my_otml_url, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)}"
    
    jnlp_filename = "#{RAILS_DATABASE_PREFIX}#{self.short_name}_#{user.vendor_interface.short_name}.jnlp"
    jnlp_url = jnlp_url << "&jnlp_filename=#{URI.escape(jnlp_filename, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)}"

    if options[:system_properties].blank?
      jnlp_props = []
    else
      jnlp_props = options[:system_properties].clone
    end
    
    if options[:authoring]
      jnlp_props << "otrunk.view.author=true"
      if self.kind_of? ExternalOtrunkActivity
        jnlp_props << "otrunk.rest_enabled=true"
      end
      jnlp_props << "otrunk.view.hide_tree=true"
      jnlp_props << "otrunk.view.frame_title=#{APP_PROPERTIES[:application_name]}"
    elsif options[:reporting]
      jnlp_props << "otrunk.view.mode=#{options[:reporting]}"
      jnlp_props << "otrunk.view.frame_title=#{APP_PROPERTIES[:application_name]}"
    else
      title = "#{APP_PROPERTIES[:page_title_prefix]} - #{self.id}: #{self.name}"
      jnlp_props << "otrunk.view.frame_title=#{title.gsub(/=/,'-')}"
    end

    unless jnlp_props.blank?
      jnlp_props_string = jnlp_props.join("&")
      escape_pattern = /[#{URI::REGEXP::PATTERN::RESERVED}\s]/
      jnlp_url << "&jnlp_properties=#{URI.escape(jnlp_props_string, escape_pattern)}"      
    end
    
    return jnlp_url
  end 
  
  def html_export_url(user, controller, options = {})
    # merge these values into the options hash if they don't exist
    options.merge({:savedata => false, :nobundles => false, :author => false, :reporting => false}) {|k,o,n| o}
    learner = self.find_or_create_learner(user)
    learner.create_session unless ! options[:savedata]
    sds_url = "#{SdsConnect::Connect.config['host']}/workgroup/report/#{learner.sds_workgroup_id}/html"
    # sds_url << '/view' unless options[:savedata]
    # sds_url << '/nobundles' if options[:nobundles]
    
    my_otml_url = self.otml_url(user, controller, options)
    
    jnlp_url = "#{sds_url}?sailotrunk.otmlurl=#{URI.escape(my_otml_url, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)}"
    
    jnlp_filename = "#{RAILS_DATABASE_PREFIX}#{self.short_name}_#{user.vendor_interface.short_name}.jnlp"
    jnlp_url = jnlp_url << "&jnlp_filename=#{URI.escape(jnlp_filename, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)}"
    
    if options[:authoring]
      props = "otrunk.view.author=true"
      if self.kind_of? ExternalOtrunkActivity
        props << "&otrunk.rest_enabled=true"
      end
      props << "&otrunk.view.hide_tree=true"
      props << "&otrunk.view.frame_title=#{APP_PROPERTIES[:application_name]}"
      jnlp_url << "&jnlp_properties=#{URI.escape(props, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)}"
    elsif options[:reporting]
      jnlp_properties = URI.escape("otrunk.view.mode=#{options[:reporting]}&otrunk.view.frame_title=#{APP_PROPERTIES[:application_name]}", /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)
      jnlp_url << "&jnlp_properties=#{jnlp_properties}"
    else
      title = "#{APP_PROPERTIES[:page_title_prefix]} - #{self.id}: #{self.name}"
      jnlp_properties = URI.escape("otrunk.view.frame_title=#{title.gsub(/=/,'-')}", /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)
      jnlp_url << "&jnlp_properties=#{jnlp_properties}"
    end
    
    return jnlp_url
  end 

  def bundle_content_ids
    bc = self.learners.collect {|l| l.most_recent_not_empty_bundle_content_id}
    bc.delete(nil)
    bc
  end

  def ot_learner_data
    bc_ids = self.bundle_content_ids
    bc_ids.delete(nil)
    if bc_ids.empty?
      ot_user_data = ""
    else
      ot_user_data = bc_ids.collect do |bc| 
          "<OTUserDatabaseRef url= '#{SdsConnect::Connect.config['host']}/bundle_contents/#{bc}/ot_learner_data.xml'/>"
      end.join("\n")      
    end
    otdata = "<userDatabases>\n" + ot_user_data + "\n</userDatabases>\n"
  end

  # First checks to make sure an offering exists for this runnable.
  # Then finds or creates a learner and starts a learner session 
  # for this sds runnable object and for the specified user.
  def create_learner_session(user)
    check_sds_offering
    learner = find_or_create_learner(user)
    learner.create_session(self)
  end

  # Find or creates a learner for this sds runnable object
  # and for the specified user.
  def find_or_create_learner(user)
    check_sds_offering
    learner = self.learners.find_or_initialize_by_user_id(user.id)
    learner.runnable = self
    learner.save
    learner
  end
  
  # Checks to see if an sds offering exists for this runnable.
  # returns nil if self.sds_offering_id exists.
  # If not one is created and the sds ofering id is returned.
  def check_sds_offering
    if sds_offering_id.blank?
        jnlp_id = SdsConnect::Connect.config['jnlp_id']
      curnit_id = SdsConnect::Connect.config['curnit_id']
      self.sds_offering_id = SdsConnect::Connect.create_offering(self.name, jnlp_id, curnit_id)
    end
  end
  
  def authorable_attribute_names
    hash = {}
    attrs = self.attribute_names
    attrs.delete("id")
    attrs.delete("content_digest")
    attrs.delete("custom_otml")
    attrs.delete("draft")
    attrs.delete("nobundles")
    attrs.delete("parent_id")
    attrs.delete("parent_version")
    attrs.delete("sds_offering_id")
    attrs.delete("short_name")
    attrs.delete("uuid")
    attrs.delete("version")
    to_delete = []
    attrs.each do |a|
      if a =~ /_active/
        # logger.info("match: #{a}")
        if ((a =~ /_probe_/) && attrs.index(a.gsub("probe_active", "probetype_id")))
          # logger.info("probe/probetype: #{a}")
          to_delete << a.gsub("probe_active", "probetype_id")
          hash[a.gsub("_active", "_combined")] = :combined
        elsif (a =~ /collectdata_/)
          if (a =~ /_model/) && (attrs.index "model_id")
            # logger.info("main model: #{a}")
            to_delete << "model_id"
            hash[a.gsub("_active", "_combined")] = :combined
          elsif  (a =~ /_probe/) && (attrs.index "probe_type_id")
            # logger.info("main probe: #{a}")
            to_delete << "probe_type_id"
            hash[a.gsub("_active", "_combined")] = :combined
          end
        elsif attrs.index(a.gsub("_active", "_id"))
          # logger.info("normal: #{a}")
          to_delete << a.gsub("_active", "_id")
          hash[a.gsub("_active", "_combined")] = :combined
        end
      else
        hash[a] = self.column_for_attribute(a).type 
      end
    end
    to_delete.each do |d|
      hash.delete(d)
    end
    return hash
  end
 
  # compares two objects and returns a hash of attribute keys which are different,
  # with the value being how it changed:
  def compare_to(object2)
    if (object2 == nil)
      object2 = self.class.new
    end
    if object2.kind_of? self.class
      different_attributes = {}
      attributes = self.authorable_attribute_names
      attributes.keys.each do |att|
        type = self.attributes[att]
        realatt = att
        if type == :combined
          # special handling
          attrs = real_attributes(att)
          # attrs[0] is whether it's active or not
          # attrs[1] is the id
          realatt = attrs[0]
          att2 = attrs[1]
        end
        if self[realatt] != object2[realatt]
          # how is it different
          if (self[realatt] == nil || self[realatt] == false) && (object2[realatt] == nil || object2[realatt] == false)
            # just ignore this, nil and false for booleans evaluate to the same
            # puts "nil and false change, ignoring"
          elsif (self[realatt] == nil || self[realatt] == false || (self[realatt].respond_to?(:empty?) && self[realatt].empty?))
            # the attribute was deleted
            # puts "#{att} was deleted"
            different_attributes[att] = {:action => "deleted"}
          elsif (object2[realatt] == nil || object2[realatt] == false || (object2[realatt].respond_to?(:empty?) && object2[realatt].empty?))
            # the attribute was added
            # puts "#{att} was added"
            different_attributes[att] = {:action => "added"}
          else
            # puts "#{att} was changed"
            different_attributes[att] = {:action => "changed"}
            if (self[att].kind_of? String)
              # puts "#{att} was a string"
              different_attributes[att][:how] = self.how_changed(object2, att)
            end
          end
        else
          if att2
            # this is a combined object
            if self[att2] != object2[att2]
              different_attributes[att] = {:action => "changed"}
            end
          end
        end
      end
      return different_attributes
    elsif object2 == nil
       # return all attributes that have *something* or aren't (nil or false)
       # different_attributes = {}
       # self.authorable_attribute_names.keys.each do |att|
       # realatt = att
       # if att =~ /_combined/
       #   # special handling
       #   attrs = real_attributes(att)
       #   # attrs[0] is whether it's active or not
       #   # attrs[1] is the id
       #   realatt = attrs[0]
       #   att2 = attrs[1]
       # end
       # if self[realatt] && ! (self[realatt].respond_to?(:empty?) && self[realatt].empty?)
       #   different_attributes[att] = {:action => "added"}
       #   if (self[realatt].kind_of? String)
       #       # puts "#{att} was a string"
       #       different_attributes[att][:how] = self.how_changed(object2, realatt)
       #   end
       # end
       # end
      return different_attributes
    else
      raise "Can't compare a #{object2.class} with a #{self.class}"
    end
  end
  
  def score(rubric = nil)
    if ! rubric
      logger.warn("Score called without @rubric initialized")
      attributes = self.authorable_attribute_names
      attributes["Image"] = :custom
      attributes["Link"] = :custom
      attributes["Bullet"] = :custom
      attributes["Numbered List"] = :custom
      rubric = self.setup_rubric(attributes)
    end
    changes = self.compare_to(self.parent)
    reasons = []
    # now iterate through the changes and assign points based on a rubric
    changes.each do |k,v|
      if w = v[:how]
        w.each do |r|
          if r == w[0]
            if r <= 0
              # no change
              reasons << { :section => k, :reason => "Content changed #{r}%", :score => 0 }
            elsif r > 75
              reasons << { :section => k, :reason => "Content changed #{r}%", :score => rubric[k]["changed75"] }
            elsif r > 50
              reasons << { :section => k, :reason => "Content changed #{r}%", :score => rubric[k]["changed50"] }
            elsif r > 25
              reasons << { :section => k, :reason => "Content changed #{r}%", :score => rubric[k]["changed25"] }
            else
              reasons << { :section => k, :reason => "Content changed #{r}%", :score => rubric[k]["changed0"] }
            end
          elsif r =~ /(.*) (added|changed|deleted)/
            reasons << { :section => k, :reason => "#{r}", :score => rubric[Regexp.last_match(1)][Regexp.last_match(2)] }
          end
        end
      else
        begin
          reasons << { :section => k, :reason => "#{v[:action]}", :score => rubric[k][v[:action]] }
        rescue
          # debugger
          logger.warn("Error on k: #{k}, v: #{v[:action]}")
        end
      end
    end
    sum = 0
    reasons.collect{|r| sum += r[:score].to_i }
    return {:sum => sum, :reasons => reasons}
  end

  def how_changed(obj, attr)
    changes = []
    changes << calculate_change_percent(obj, attr)
    html_diffs = html_attribute_difference(obj, attr, "sequences", false)[0].split(/<\/span>/)
    html_diffs.each do |d|
      action = ""
      if d =~ /<span class='match'>/
        # ignore matches
        next
      elsif d =~ /(<span class='only_a'>)/
        action = "added"
      elsif d =~ /(<span class='only_b'>)/
        action = "deleted"
      elsif d =~ /(<span class='changed'>)/
        action = "changed"
      end
      d.sub!(Regexp.last_match(1), '')
      
      # links
      while d =~ /(<a href)/ || d =~ /(\[[^\]]\])/
        # puts "link #{action}"
        changes << "Link #{action}"
        d.sub!(Regexp.last_match(1), '')
      end
      
      # images
      while d =~ /(<img)/ || d =~ /(![^!]+!)/
        # puts "image #{action}"
        changes << "Image #{action}"
        d.sub!(Regexp.last_match(1), '')
      end
      
      # bullets
      while d =~ /^[ ]*(\*) / || d =~ /\n[ ]*(\*) /  || d =~ /(<ul>)/
        # puts  "bullet #{action}"
        changes << "Bullet #{action}"
        d.sub!(Regexp.last_match(1), '')
      end
      
      # numbered list
      while d =~ /^[ ]*(#) / || d =~ /\n[ ]*(#) /  || d =~ /(<ol>)/
        # puts "numbered list #{action}"
        changes << "Numbered List #{action}"
        d.sub!(Regexp.last_match(1), '')
      end
      
    end
    return changes
  end
  
  def calculate_change_percent(obj, attr)
    if obj == nil
      return 100
    end
    if ! (obj[attr].kind_of?(String))
      if self[attr] != obj[attr]
        return 100
      else
        return 0
      end
    else
      # the basic idea is to calculate the amount of original content still in the attribute
      # so, figure out how many words are the same, and divide by 
      # (the total number of words currently in the attribute PLUS the total words deleted from the original)
      # this yields the percentage of original content. subtract this from 100,
      # and you get the amount of changed/new/deleted content.
      out1 = "";
      out2 = "";
      # symbol diff returns a string of +-=* which represent whether the "word" was changed, added, deleted or the same.
      sd = SymbolDiff.new(out1, out2)
      a = self[attr]
      b = obj[attr]
      a = CGI.escapeHTML(a).gsub(/(\s)/) {|s| "#{s} "}.split(/ /)
      a.delete("")
      b = CGI.escapeHTML(b).gsub(/(\s)/) {|s| "#{s} "}.split(/ /)
      b.delete("")
      Diff::LCS.traverse_sequences(a,b, sd)
      same = out1.count("=")
      return 100-((same/(out1.size.to_f + out2.count("-")))*100).to_i
    end
  end
  
  # returns an html representation of the differences between the attribute of 2 objects
  def html_attribute_difference(object2, attribute, style = "sequences", dual = true)
    output = []
    output2 = []
    hd = HTMLDiff.new(output)
    if dual
      hd = HTMLDiff.new(output, output2)
    end
    a = self[attribute]
    b = object2[attribute]
    if (a == nil) || (! a.kind_of? Enumerable)
      a = [a]
    elsif a.kind_of? String    
      a = CGI.escapeHTML(a).gsub(/(\s)/) {|s| "#{s} "}.split(/ /)
      a.delete("")
      # a = CGI.escapeHTML(a).split(/\b/)
    end
    if (b == nil) || (! b.kind_of? Enumerable)
      b = [b]
    elsif b.kind_of? String
      b = CGI.escapeHTML(b).gsub(/(\s)/) {|s| "#{s} "}.split(/ /)
      b.delete("")
      # b = CGI.escapeHTML(b).split(/\b/)
    end
    if style != "balanced"
      Diff::LCS.traverse_sequences(a,b, hd)
    else
      Diff::LCS.traverse_balanced(a,b, hd)
    end
    hd.close
    if dual
      return [output.join(" "), output2.join(" ")]
    else
      return [output.join(" ")]
    end
  end
  
  def real_attributes(att)
    attr = att.gsub("_combined", "_active")
    attr2 = ""
    att =~ /([^_]+)_([^_]+)_combined/
    if Regexp.last_match(1) == "collectdata"
      if Regexp.last_match(2) == "model"
        attr2 = "model_id"
      elsif Regexp.last_match(2) == "probe"
        attr2 = "probe_type_id"
      end
    elsif Regexp.last_match(2) == "probe"
      attr2 = att.gsub("probe", "probetype")
    else
      attr2 = att.gsub("_combined", "_id")
    end
    return [attr, attr2]
  end
  
  # returns a hash of html representations of the differences between 2 objects (all attributes)
  # { attr1 => "...html...", attr2 => "...html...", ...}
  def html_difference(object2, style = "sequences", dual = true)
    result = {}
    if object2.kind_of? self.class
      attributes = self.authorable_attribute_names
      attributes.keys.each do |att|
        # FIXME skip comparing the otml for now. This uses a huge amount of memory...
        next if att == "otml"
        type = attributes[att]
        if type == :combined && att =~ /([^_]+)_([^_]+)_combined/
          attrs = real_attributes(att)
          result[attrs[0]] = self.html_attribute_difference(object2, attrs[0], style, dual)
          result[attrs[1]] = self.html_attribute_difference(object2, attrs[1], style, dual)
        else
          result[att] = self.html_attribute_difference(object2, att, style, dual)
        end
      end
    end
    return result
  end

  def gen_usage_hash
    hash = {}
    learners = self.learners
    sessions = self.learners.collect {|l| l.learner_sessions }
    sessions.flatten!
    hash[:total_learners] = learners.size
    hash[:total_sessions] = sessions.size
    one_month_sessions = sessions.select{|s| s.created_at > 1.month.ago}
    three_month_sessions = sessions.select{|s| s.created_at > 3.month.ago}
    six_month_sessions = sessions.select{|s| s.created_at > 6.month.ago}
    hash[:one_month_learners] = one_month_sessions.collect{|s| s.learner}.uniq.size
    hash[:one_month_sessions] = one_month_sessions.size
    hash[:three_month_learners] = three_month_sessions.collect{|s| s.learner}.uniq.size
    hash[:three_month_sessions] = three_month_sessions.size
    hash[:six_month_learners] = six_month_sessions.collect{|s| s.learner}.uniq.size
    hash[:six_month_sessions] = six_month_sessions.size
    return hash
  end
  
  def setup_rubric(attributes = self.authorable_attribute_names, rubric = {})
    attributes.each do |a, type|
      next if rubric[a]  # if it exists, assume it already has the appropriate values
      if (a =~ /_(active|response|multi)/)
        rubric[a] = {"added" => 1, "deleted" => 0}
      elsif (type == :text || type == :string)
        rubric[a] = {"added" => 1, "changed0" => 1, "changed25" => 2, "changed50" => 3, "changed75" => 4, "deleted" => 0}
      else
        rubric[a] = {"added" => 1, "changed" => 1, "deleted" => 0}
      end
    end
    return rubric
  end
end
