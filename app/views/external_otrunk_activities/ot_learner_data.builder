xml.otrunk("xmlns:fo" => "http://www.w3.org/1999/XSL/Format", "xmlns:lxslt" => "http://xml.apache.org/xslt", "id" => "16c847dc-071a-4816-a452-5fe30716442a") { 
  ot_user_list_imports(xml)
  xml.objects {
    xml.OTUserList("local_id" => "user_list") {
      @bundle_content_ids.each do |bc|
        xml.OTUserDatabaseRef("url" => "#{SdsConnect::Connect.config['host']}/bundle_contents/#{bc}/ot_learner_data.xml")
      end
    }
  }
}
