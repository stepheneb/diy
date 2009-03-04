class HomeController < ApplicationController
    
  layout "standard"

  def index
    @vendor_interface = self.current_user.vendor_interface
    @vendor_interfaces = VendorInterface.find(:all).map { |v| [v.name, v.id] }
    begin
      @activity = Activity.find(39)
    rescue
      @activity = Activity.find(:first, :conditions => "public='1'")
    end
    render :layout => 'standard'
  end
   
end
