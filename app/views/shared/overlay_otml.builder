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
          # use the DIY configured interface manager:
          if (r.to_s =~/interface_manager/) 
            otml_device_config(xml)
          else
            xml.object("refid" => r)
          end
        end
        if @learners.size > 0 || @userListURL
          hash = {}
          if @group_overlay_url
            hash["groupDataURL"] = @group_overlay_url.gsub(/\.otml$/,"-data.otml")
          end
          if @userListURL
            hash["userListURL"] = @userListURL
          end
            xml.OTGroupListManager(hash) {
              xml.userList {
                @learners.each do |l|
                  xml.OTGroupMember("name" => l.user.name, "uuid" => l.user.uuid, "passwordHash" => l.user.password_hash, "dataURL" => "#{get_overlay_server_root}/#{l.runnable.id}/#{l.id}-data.otml", "isCurrentUser" => (l.user_id == @user.id)) {
                    xml.userObject {
                      xml.OTUserObject("id" => l.uuid)
                    }
                  }
                end
              }
            }
        end
        if ((defined? OTRUNK_USE_LOCAL_CACHE) && OTRUNK_USE_LOCAL_CACHE)
          xml.OTProxyService {
            xml.proxyConfig {
              xml.OTProxyConfig("id" => "327ced8d-0b78-4cd8-9f87-5d2308fa716f", "proxyMode" => "CLIENT")
            }
          }
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
