require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Report do
  before(:each) do
    @activity = Activity.create({
      :name => "test",
      :introduction => "this is a test"
    })
  end
  
  describe "with serialized reportable" do
    before(:each) do
      @valid_attributes = {
        "name"=>"Test a",
        "public"=>"1",
        "custom_offering_id"=>"",
        "reportable_s"=>"Activity:#{@activity.id}",
        "description"=>"first test",
        "otrunk_report_template_id"=>"1",
        "custom_workgroup_id"=>""
      }
    end

    it "should create a new instance given valid attributes " do
      r = Report.create!(@valid_attributes)
      r.reportable_type.should eql "Activity"
      r.reportable_id.should eql @activity.id
      r.reportable.should eql @activity
    end
  end

  describe "with a real AR reportable" do
    before(:each) do
      @valid_attributes = {
        "name"=>"Test a",
        "public"=>"1",
        "custom_offering_id"=>"",
        "reportable"=> @activity,
        "description"=>"first test",
        "otrunk_report_template_id"=>"1",
        "custom_workgroup_id"=>""
      }
    end

    it "should have a real reportable" do
      r =  Report.create!(@valid_attributes)
      r.reportable.should eql @activity
    end
  end

end
