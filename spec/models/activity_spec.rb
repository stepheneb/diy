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

  it "should not throw NPE when misconfigured with futher models" do
    model = mock_model(Model, {
      :name => 'fake'
    })
    @activity = Activity.create(@valid_attributes)
    @activity.further_model_active = true
    @activity.save
    @activity.contains_active_model(model).should be false
    @activity.interactive_components.should_not be_nil
  end

  it "should respond to archived" do
    @activity = Activity.create(@valid_attributes)
    @activity.should respond_to :archived
  end

  it "should respond to archived=" do
    @activity = Activity.create(@valid_attributes)
    @activity.should respond_to "archived="
  end

  it "should be archivable" do
    @activity = Activity.create(@valid_attributes)
    @activity.archived = true
    @activity.save.should be true
    @activity.archived.should be true
    @activity.archived = false
    @activity.archived.should be false
  end

  describe "creates reports in the diy that" do
    it "should trigger a callback to create_reportable" do
      @activity = Activity.new(@valid_attributes)
      @activity.should_receive(:create_reportable)
      @activity.save
    end
  end

  describe "public activities" do
    before(:each) do
      @valid_attributes[:public] = true
    end

    it "should have one (and only one) report when saved or updated" do
      @activity = Activity.new(@valid_attributes)
      @activity.save  
      Report.find(:all, :conditions => {:reportable_id => @activity.id}).size.should eql 1
      @activity.update_attributes({:name => "other name"})
      Report.find(:all, :conditions => {:reportable_id => @activity.id}).size.should eql 1
    end
  end

  describe "private activites" do
    before(:each) do
      @valid_attributes[:public] = false
    end

    it "should have have no reports when saved or updated" do
      @activity = Activity.new(@valid_attributes)
      @activity.save  
      Report.find(:all, :conditions => {:reportable_id => @activity.id}).size.should eql 0
      @activity.update_attributes({:name => "other name"})
      Report.find(:all, :conditions => {:reportable_id => @activity.id}).size.should eql 0
    end
  end
end
