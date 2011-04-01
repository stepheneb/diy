require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe OtrunkReportTemplate  do

  describe "class mathods" do
    before(:each) do
      @diy_template_url = "https://github.com/concord-consortium/itsisu_reports/raw/master/reports/diy-full-report.otml"
      @diy_template_name = "testing template"
      @pretest_template_url = "https://github.com/concord-consortium/itsisu_reports/raw/master/reports/pre-test-report.otml"
      @pretest_template_name = "pretest testing template"
    end

    it "should find_or_create the same template by url" do
      OtrunkReportTemplate.should respond_to :find_or_create_by_url
      template = OtrunkReportTemplate.find_or_create_by_url(@diy_template_url, @diy_template_name)
      template.should be_valid
      template2 =OtrunkReportTemplate.find_or_create_by_url(@diy_template_url, @diy_template_name)
      template2.should be_valid
      template.external_otml_url.should eql @diy_template_url
      template.should eql template2
      OtrunkReportTemplate.find(:all).size.should eql 1
    end
    it "should find_or_create two templates with different urls" do
      OtrunkReportTemplate.should respond_to :find_or_create_by_url
      template = OtrunkReportTemplate.find_or_create_by_url(@diy_template_url, @diy_template_name)
      template.should be_valid
      template2 =OtrunkReportTemplate.find_or_create_by_url(@pretest_template_url, @pretest_template_name)
      template2.should be_valid
      template.external_otml_url.should eql @diy_template_url
      template2.external_otml_url.should eql @pretest_template_url
      OtrunkReportTemplate.find(:all).size.should eql 2
    end

  end

end
