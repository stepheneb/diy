require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Activity do
  before(:each) do
    @valid_attributes = {
      :name => "test activity",
      :description => "new decription",
      :introduction => "this is the introduction"
    }
  end

  it "should create a new instance given valid attributes" do
    Activity.create!(@valid_attributes)
  end
  
  describe "should let authors attach images" do
    before(:each) do
      @activity = Activity.create!(@valid_attributes)
    end
    
    it "should have image methods" do
      @activity.should respond_to(:image_url)
      @activity.should respond_to(:image_url=)
      @activity.should respond_to(:has_image?)
    end
    
    it "should not have an image at first" do
      @activity.has_image?.should be false
      @activity.image_url.should be nil
    end
    
    it "should accept valid image urls" do
      @activity.image_url="http://www.concord.org/images/logos/cc/cc_main_banner.jpg"
      @activity.save.should be true
      @activity.reload
      @activity.image_url.should == "http://www.concord.org/images/logos/cc/cc_main_banner.jpg"
      @activity.has_image?.should be true
    end
    
    it "should reject invalid image urls" do
      @activity.image_url="http://www.concord.org/images/logos/cc/cc_main_banner.foo"
      @activity.save.should be false
      @activity.reload
      @activity.image_url.should be_nil
      @activity.has_image?.should be false
    end
  end
  
end
