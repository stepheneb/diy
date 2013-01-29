require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActiveSupport::JSON do

  describe "#decode(json)" do
    before :each do
      @good_json = <<-EOF
        {"title": "Tire Forces",
        "publicationStatus": "public",
        "subtitle": "",
        "about": "",
        "models": [
          {
            "id": "tireforcesimple$0",
            "url": "/imports/legacy-mw-content/converted/visual/Recycling/tireforcesimple$0.json"
          }
        ]}
      EOF
    end
     
    it "should parse good json" do
      decoded = ActiveSupport::JSON.decode(@good_json)
      decoded.should have(5).entries
      decoded['models'].should have(1).model
    end


  end
end
