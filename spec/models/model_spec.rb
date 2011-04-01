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

  describe "associated activities" do
    before(:each) do
      @model = Model.create!(@valid_attributes)
      counter = 0
      defaults = lambda do 
        counter = counter + 1 
        return {:description => "d",:introduction=>"in", :name=>"test activity ##{counter}"}
      end
      @activity1 = Activity.create!(defaults.call)
      @activity2 = Activity.create!(defaults.call)
      @activity3 = Activity.create!(defaults.call)
      @activity4 = Activity.create!(defaults.call)

      @activity1.model = @model
      @activity1.collectdata_model_active = true

      @activity2.second_model = @model
      @activity2.collectdata2_model_active = true

      @activity3.third_model = @model
      @activity3.collectdata3_model_active = true

      @activity4.fourth_model = @model
      @activity4.further_model_active = true
      @activity4.save!
      @activity3.save!
      @activity2.save!
      @activity1.save!
      @model.reload
    end

    it "should calculate the total number of included activities" do
      @model.included_activities.size.should == 4
      @model.included_activities.should include(@activity1)
      @model.included_activities.should include(@activity2)
      @model.included_activities.should include(@activity3)
      @model.included_activities.should include(@activity4)
    end
  end
end
