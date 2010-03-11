require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImageChecker do

  it "should validate good image urls" do
    %q[ 
      http://www.google.com/intl/en_ALL/images/logo.gif
      http://img.timeinc.net/time/rd/trunk/www/web/feds/i/logo_time_home.gif
      http://i.cdn.turner.com/cnn/.element/img/3.0/global/header/hdr-main.gif
      http://www.concord.org/images/logos/cc/cc_main_banner.jpg
      ].split.each do |img|
        ImageChecker.valid?(img).should be true
        ImageChecker.valid?(img,false).should be true
      end
  end
  
  it "should not validate good image urls that are too big" do
    ImageChecker.valid?("http://www.concord.org/images/logos/cc/cc_main_banner.jpg",true,100).should be false
    ImageChecker.valid?("http://www.concord.org/images/logos/cc/cc_main_banner.jpg",true,100000).should be true
  end
  
  it "should not validate bad image urls" do
    %q[ 
      http://www.google.com/
      http://concord.org/
      google.com/intl/en_ALL/images/logo.gif 
      http://ddfdf
      ftp://www.concord.org/images/logos/cc/cc_main_banner.jpg
      asdasdsa
      ].split.each do |img|
        ImageChecker.valid?(img).should be false
      end
  end
  
end
