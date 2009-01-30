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
        @bundles.each do |r|
          xml.object("refid" => r)
        end
        if @learners.size > 0 || @userListURL
          if @userListURL
            xml.OTGroupListManager("userListURL" => @userListURL)
          else
            xml.OTGroupListManager {
              xml.userList {
                @learners.each do |l|
                
                  xml.OTGroupMember("name" => l.user.name, "uuid" => l.user.uuid, "dataURL" => "#{OVERLAY_SERVER_ROOT}/#{l.runnable.id}/#{l.id}-data.otml", "isCurrentUser" => (l.user_id == @user.id)) {
                    xml.userObject {
                      xml.OTUserObject
                    }
                  }
                end
              }
            }
          end
        end
      }
      if @group_overlay_url || @learner_overlay_url || @overlays.size > 0
        xml.overlays {
          if @learner_overlay_url
            xml.OTIncludeRootObject("href" => @learner_overlay_url)
          end
          if @group_overlay_url
            xml.OTIncludeRootObject("href" => @group_overlay_url)
          end
          @overlays.each do |o|
            xml.object("refid" => o)
          end
        }
      end
      xml.root {
        if @rootObjectID
          xml.object("refid" => @rootObjectID)
        else
          xml.OTIncludeRootObject("href" => @activity_otml_url)
        end
      }
    }
  }
}