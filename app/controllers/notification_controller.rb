class NotificationController < ApplicationController
  require "rexml/document"
  
  DEBUG = false
  
  def workgroup_sync
    # This action takes a bundle:create notification from the SDS and:
    # 1) gets the learner data
    # 2) parses it to determine the lead member and other members of the on-the-fly workgroup
    # 3) if the notification is for the lead member, copies the bundle to the other member's sds workgroups
    # 4) otherwise, ignores it
    
    # the SDS notification gives us the following pieces of data
    @bundle_workgroup_id = params[:workgroup_id]
    @bundle_id = params[:bundle_id]
    @sds_portal_id = params[:portal_id]
    @sds_offering_id = params[:offering_id]
    @event_type = params[:event_type]
    @bundle_url = params[:bundle_url]
    @bundle_content_url = params[:bundle_content_url]
    @ot_learner_data_url = params[:bundle_ot_learner_data_url]
    
    # 1) Gets the learner data
    ot_learner_data = REXML::Document.new(open(@ot_learner_data_url + ".xml").read).root
    
    # 2) parses it to determine the lead member and other members of the on-the-fly workgroup
    # it looks for the OTWorkgroupMemberChooser element, and then takes the LeadMember and OtherWorkgroupMembers
    lead_member = ot_learner_data.elements["//OTWorkgroupMemberChooser/leadMember/OTGroupMember"]
    other_members = ot_learner_data.elements.to_a("//OTWorkgroupMemberChooser/otherWorkgroupMembers/OTGroupMember")
    
    # 3) if the notification is for the lead member, copies the bundle to the other member's sds workgroups
    notification_learner = Learner.find_by_sds_workgroup_id(@bundle_workgroup_id)
    if (notification_learner != nil && lead_member != nil && notification_learner.user.uuid == lead_member.attributes["uuid"])
      logger.info("have learner, lead member, and they match") if DEBUG
      # for each member, find the uuid, look up the diy user and sds workgroup, copy the bundle
      logger.info("there are #{other_members.size} other members") if DEBUG
      other_members.each do |mem|
        uuid = mem.attributes["uuid"]
        # avoid copying the bundle to the source workgroup
        next if notification_learner.user.uuid == uuid
        user = User.find_by_uuid(uuid)
        workgroup_id = notification_learner.runnable.find_or_create_learner(user).sds_workgroup_id
        
        # copy the bundle
        # make this an XML request to avoid authenticating
        logger.info("copying bundle: #{@bundle_url}/copy/#{workgroup_id}.xml")
        logger.info("result: " + open("#{@bundle_url}/copy/#{workgroup_id}.xml").read)
      end
    else
      # 4) this bundle is not from a workgroup lead. Ignore it. (This avoids endless copying loops, too.)
      logger.info("have learner and lead member didn't match!") if DEBUG
    end
    render :xml => "<success>true</success>"
  end
end
