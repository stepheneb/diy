require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Reportable do
  before(:all) do
    class TestClass 
      @@save_hooks = []
      @@update_hooks = []
      def self.after_save(sym)
        @@save_hooks << sym
        @@save_hooks = @@save_hooks.uniq.flatten
      end
      def self.after_update(sym)
        @@update_hooks << sym
        @@update_hooks = @@update_hooks.uniq.flatten
      end
      def name
        "foo"
      end
      def save
        @@save_hooks.each do |hook|
          self.send hook
        end
      end
      def public
        true
      end
      def update
        @@update_hooks.each do |hook|
          self.send hook
        end
      end
      include Reportable
    end
  end
  
  it "should respond to the mixin methods" do
    @test = TestClass.new
    @test.should respond_to :default_template_url
    @test.should respond_to :default_template_name
    @test.should respond_to :create_reportable
  end
  

  describe "applications without default templates" do
    before(:all) do
      @test = TestClass.new
      APP_PROPERTIES["#{@test.class.name.underscore}_report_template_url".to_sym]  = nil
      APP_PROPERTIES["#{@test.class.name.underscore}_report_template_name".to_sym] = nil
    end
    it "shouldn't have default templates" do
      @test.default_template_url.should be_nil
    end
  end

  describe "applications with default templates" do
    before(:all) do
      @test = TestClass.new
      @test_url = "foo"
      @test_name = "foo_name"
      APP_PROPERTIES["#{@test.class.name.underscore}_report_template_url".to_sym]  = @test_url
      APP_PROPERTIES["#{@test.class.name.underscore}_report_template_name".to_sym] = @test_name
    end
    it "should have default templates with expected text values" do
      @test = TestClass.new
      @test_url = "foo"
      @test_name = "foo_name"
      @test.default_template_url.should eql @test_url
      @test.default_template_name.should eql @test_name
    end
    it "should receive :create_reportable after save" do
      @test.should_receive(:create_reportable)
      @test.save
    end
    # TODO: We really need to test that we do create the Report when its not found
    it "should not try to create a report template if it finds an existing one" do
      Report.should_receive(:find_by_reportable_id).and_return(Report.new)
      Report.should_not_receive(:create)
      @test.save
    end
  end
  
end
