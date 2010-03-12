require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Model do
  before(:each) do
    @valid_attributes = {
      :name => "test model"
    }
  end

  it "should create a new instance given valid attributes" do
    Model.create!(@valid_attributes)
  end
  
  describe "should let authors attach images" do
    before(:each) do
      @model = Model.create!(@valid_attributes)
    end
    
    it "should have image methods" do
      @model.should respond_to(:image_url)
      @model.should respond_to(:image_url=)
      @model.should respond_to(:has_image?)
    end
    
    it "should not have an image at first" do
      @model.has_image?.should be false
      @model.image_url.should be nil
    end
    
    it "should accept valid image urls" do
      @model.image_url="http://www.concord.org/images/logos/cc/cc_main_banner.jpg"
      @model.save.should be true
      @model.reload
      @model.image_url.should == "http://www.concord.org/images/logos/cc/cc_main_banner.jpg"
      @model.has_image?.should be true
    end
    
    it "should reject invalid image urls" do
      @model.image_url="http://www.concord.org/images/logos/cc/cc_main_banner.foo"
      @model.save.should be false
      @model.reload
      @model.image_url.should be_nil
      @model.has_image?.should be false
    end
  end
  
end
