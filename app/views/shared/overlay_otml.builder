xml.otrunk("xmlns:fo" => "http://www.w3.org/1999/XSL/Format", "xmlns:lxslt" => "http://xml.apache.org/xslt", "id" => @external_otrunk_activity.uuid) {
  xml.imports {
    @imports.each do |i|
      xml.import("class" => i)
    end
  }
  xml.objects {
    xml.OTSystem("local_id" => "system") {
      xml.includes {
        xml.OTInclude("href" => @activity_otml_url)
      }
      xml.bundles {
        @references.each do |r|
          xml.object("refid" => r)
        end
      }
      xml.overlays {
        if @group_overlay_url
          xml.OTIncludeRootObject("href" => @group_overlay_url)
        end
        xml.OTIncludeRootObject("href" => @learner_overlay_url)
      }
      xml.root {
        xml.OTIncludeRootObject("href" => @activity_otml_url)
      }
    }
  }
}