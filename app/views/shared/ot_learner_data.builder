xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.otrunk("xmlns:fo" => "http://www.w3.org/1999/XSL/Format", "xmlns:lxslt" => "http://xml.apache.org/xslt", "id" => "7a9876a6-e64c-11dc-bee7-001b631eb2da") { 
  ot_user_list_imports(xml)
  xml.objects {
    xml.OTUserList("local_id" => "user_list") {
      xml.userDatabases {
        if @useOverlays
          @learners.each do |learner|
            xml.OTUserDatabaseRef(
              "url" => "#{SdsConnect::Connect.config['host']}/workgroups/#{learner.sds_workgroup_id}/ot_learner_data.xml",
              "overlayURL" => "#{OVERLAY_SERVER_ROOT}/#{learner.runnable.id}/#{learner.id}.otml"
            )
          end
        else
          @learners.each do |learner|
            xml.OTUserDatabaseRef( "url" => "#{SdsConnect::Connect.config['host']}/workgroups/#{learner.sds_workgroup_id}/ot_learner_data.xml" )
          end
        end
      }
    }
  }
}
