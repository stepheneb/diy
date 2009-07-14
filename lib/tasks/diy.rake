# rake file

namespace :diy do
  
  require 'activerecord'
  class RemovePrefixFromTableNames < ActiveRecord::Migration
    def self.up
      ActiveRecord::Base.connection.tables.each do |table|
        new_table = table.sub(RAILS_DATABASE_PREFIX, "")
        if table != new_table
          puts "Renaming table '#{table}' to '#{new_table}'"
          rename_table(table, new_table)
        end
      end
    end

    def self.down
    end
  end

  desc "remove the table prefix from all table names"
  task :remove_prefix_from_table_names => :environment do
    RemovePrefixFromTableNames.up
  end

  def find_models
    Dir.chdir(File.join(RAILS_ROOT, 'app', 'models')) do
      model_names = Dir.glob('*.rb').collect { |rb| rb[/(.*).rb/, 1].camelize } - %w{SunflowerModel SunflowerMystriUser}
      model_names.collect  { |m| m.constantize }
    end
  end
  
  desc "save every local model generating uuids if they don't already exist"
  task :save_all_models  => :environment do
    models = find_models
    models.each do |model|
      puts "#{model.name}: #{model.count}"
      model.find(:all).each {|m| m.save }
    end
  end

  VENDOR_INTERFACES = [
    ["Fourier Ecolog", 30, ["_auto_"], "fourier_ecolog", 'usb', "SensorImages/EcoLogXL_sm.png",
      "The Fourier EcoLog has several built-in sensors, can read external Fourier sensors, and communicates via USB."],
      
    ["Data Harvest Easysense Q", 40, ["_auto_"], "dataharvest_easysense_q", 'usb', "SensorImages/EasysenseQ_sm.png",
      "The Data Harvest EasySense Q works with all the Data Harvest sensors and communicates via USB."],
      
    ["Pasco Science Workshop 500", 60, ["_auto_"], "pasco_sw500", 'serial', "SensorImages/Pasco500_sm.png",
      "The Pasco Science Workshop 500 has four input ports for connecting older Pasco sensors and communicates to your computer via a serial port."],
      
    ["Pasco Airlink SI", 61, ["_auto_"], "pasco_airlink", 'bluetooth', "SensorImages/pasportairlinksi_sm.png",
      "The Pasco AirLink Si uses PASPORT sensors and communicates to your computer via Bluetooth wireless networking."],
      
    ["Texas Instruments CBL2", 20, ["none"], "ti_cbl2", 'usb', "SensorImages/CBL2_sm.png",
      "The Texas Instruments CBL2 works with TI sensors and communicates via USB."],
      
    ["Vernier Go! Link", 10, ["none"], "vernier_goio", 'usb', "SensorImages/VernierGoLink_sm.png",
      "Vernier's USB Go!Link interface works with many Vernier sensors. The Go!Temp and Go!Motion sensors have Go!Link interfaces integrated into the sensor."],
      
    ["Simulated Data", 0, ["none"], "pseudo_interface", 'simulated', "SensorImages/psuedo_interface.jpg",
      "Use the Simulated Data interface when you have no probeware to attach to your computer but you stillwant to test your activity."],
      
    ["Vernier LabPro", 11, ["_auto_"], "vernier_labpro", 'usb', "SensorImages/labpro_sm.jpg",
      "Vernier's LabPro interface works with many Vernier sensors."],
      
    ["Vernier LabQuest", 12, ["_auto_"], "vernier_labquest", 'usb', "SensorImages/labquest_sm.jpg",
      "Vernier's LabQuest interface works with many Vernier sensors."]
  ]

  desc "update or create default vendor interfaces"
  task :update_or_create_default_vendor_interfaces => :environment do
    VENDOR_INTERFACES.each do |vi_data|
      vendor_interface = VendorInterface.find_or_create_by_short_name(vi_data[3])
      vendor_interface.attributes = {
        :user_id => 2,
        :name => vi_data[0], 
        :device_id => vi_data[1],
        :short_name => vi_data[3],
        :communication_protocol => vi_data[4],
        :image => vi_data[5],
        :description => vi_data[6]
      }
      configs = []
      vi_data[2].each do |config_string|
        configs << vendor_interface.device_configs.find_or_create_by_config_string(config_string)
      end
      vendor_interface.reload
      invalid_configs = vendor_interface.device_configs - configs
      invalid_configs.each {|c| c.destroy }
      vendor_interface.save!
    end
  end

  
  desc "create default probe types"
  task :create_default_probes_types => :environment do
    ProbeType.create(:name => "Temperature", :ptype => 0, :step_size => 0.1, :display_precision => -1, :port => 0, :unit => "degC", :min => 0, :max => 40, :period => 0.1)
    ProbeType.create(:name => "Light", :ptype => 2, :step_size => 0.1, :display_precision => 0, :port => 0, :unit => "lux", :min => 0, :max => 4000, :period => 0.1)
    ProbeType.create(:name => "Pressure", :ptype => 3, :step_size => 0.1, :display_precision => -1, :port => 0, :unit => "kPa", :min => 96, :max => 104, :period => 0.1)
    ProbeType.create(:name => "Voltage", :ptype => 4, :step_size => 0.1, :display_precision => -2, :port => 0, :unit => "V", :min => -10, :max => 10, :period => 0.1)
    ProbeType.create(:name => "Force (5N)", :ptype => 5, :step_size => 0.01, :display_precision => -2, :port => 0, :unit => "N", :min => -4, :max => 4, :period => 0.01)
    ProbeType.create(:name => "Force (50N)", :ptype => 5, :step_size => 0.1, :display_precision => -1, :port => 0, :unit => "N", :min => -40, :max => 40, :period => 0.01)
    ProbeType.create(:name => "Motion", :ptype => 13, :step_size => 0.1, :display_precision => -2, :port => 0, :unit => "m", :min => -4, :max => 4, :period => 0.1)
    ProbeType.create(:name => "Relative Humidity", :ptype => 7, :step_size => 0.1, :display_precision => -1, :port => 0, :unit => "percentage", :min => 10, :max => 90, :period => 0.1)
    ProbeType.create(:name => "CO2 Gas", :ptype => 18, :step_size => 20, :display_precision => 2, :port => 0, :unit => "ppm", :min => 0, :max => 500, :period => 1)
    ProbeType.create(:name => "Oxygen Gas", :ptype => 19, :step_size => 0.1, :display_precision => -1, :port => 0, :unit => "ppt", :min => 0, :max => 300, :period => 0.1)
    ProbeType.create(:name => "pH", :ptype => 20, :step_size => 0.1, :display_precision => -1, :port => 0, :unit => "pH", :min => 0, :max => 14, :period => 0.1)
    ProbeType.create(:name => "Salinity", :ptype => 21, :step_size => 0.1, :display_precision => -1, :port => 0, :unit => "ppt", :min => 0, :max => 50, :period => 0.1)
    ProbeType.create(:name => "Raw Data", :ptype => 22, :step_size => 1, :display_precision => 0, :port => 0, :unit => "raw", :min => -10000, :max => 10000, :period => 0.1)
    ProbeType.create(:name => "Raw Voltage", :ptype => 23, :step_size => 0.01, :display_precision => -2, :port => 0, :unit => "V", :min => -1, :max => 10, :period => 0.1)
    ProbeType.create(:name => "Colorimeter", :ptype => 33, :step_size => 0.057, :display_precision => 0, :port => 0, :unit => "%T", :min => 0, :max => 100, :period => 0.1)
    ProbeType.create(:name => "Hand Dynamometer", :ptype => 34, :step_size => 0.35, :display_precision => 0, :port => 0, :unit => "N", :min => 0, :max => 400, :period => 0.1)
  end

  desc "Print plugins managed by Piston."           
  task :pistoned do
    Dir['vendor/plugins/*'].each do |file|                                                                                               
      unless (revision = `svn propget piston:remote-revision #{file}`.strip).empty?                                                      
        puts "#{file.split('/').last}: r#{revision} [" << `svn propget piston:root #{file}`.strip << "]"                                        
      end                                                                                                                                
    end                                                                                                                                  
  end 
  
  desc "Setup default data in brand new database"
  task :setup_new_database => [:environment, :create_default_probes_types, :update_or_create_default_vendor_interfaces, :create_default_users_groups_roles, 
    :create_default_model_types_and_models, :create_activity_mixing_water, :create_activity_greenhouse_effect] do
  end

  desc "Create defaul ModelTypes and Models"
  task :create_default_model_types_and_models => :environment do
    stephen = User.find_by_login('stephen')
    mw = ModelType.create(:name => "Molecular Workbench", 
      :user_id => stephen.id,
      :description => "A Molecular Workbench activity page.", 
      :url => "http://mw.concord.org/modeler/index.html", 
      :credits => "Powered by the <a href='http://mw.concord.org/modeler/index.html'>Molecular Workbench</a> software.",
      :otrunk_object_class => "org.concord.otrunkmw.OTModelerPage",
      :otrunk_view_class => "org.concord.otrunkmw.OTModelerPageView")

    nl = ModelType.create(:name => "NetLogo", :description => "A NetLogo program.", 
      :user_id => stephen.id,
      :url => "http://ccl.northwestern.edu/netlogo/", 
      :credits => "Model created with the <a href='http://ccl.northwestern.edu/netlogo'>NetLogo</a> programming language.",
      :otrunk_object_class => "org.concord.otrunknl.OTNLogoModel",
      :otrunk_view_class => "org.concord.otrunknl.OTNLogoModelView")
      
    Model.create(:model_type_id => mw.id, :name => "Heat Flow Step 1",
      :user_id => stephen.id,
      :url => "/model_files/Step1.cml",
      :public => true, :textile => true,
      :description => "Adapted from Step 1 of Bob Tinker's Heat Flow activity.", 
      :instructions => "*Start* the model, *Click* inside the model, and *Press* the arrow keys on the *keyboard*.")

    Model.create(:model_type_id => mw.id, 
      :name => "Greenhouse Earth",
      :user_id => stephen.id,
      :url => "/model_files/greenhouse.nlogo",
      :public => true, :textile => true,
      :description => "Adapted from Bob Tinker's model created for TELS.", 
      :instructions => "Click *Reset* and then *Go* to start the model.")
  end

  desc "Create default users and roles"
  task :create_default_users_groups_roles => :environment do
#      public_group = Group.create(:public => true, :key => nil, :textile => true, :name => 'Public', 
#                  :description => 'The Public group includes all members of the site',
#                  :introduction => 'When you make an activity available in the Public group all users will be able to try it out.')
      admin_role = Role.find_or_create_by_title('admin')
      manager_role = Role.find_or_create_by_title('manager')
      member_role = Role.find_or_create_by_title('member')
      teacher_role = Role.find_or_create_by_title('teacher')
      student_role = Role.find_or_create_by_title('student')
      guest_role = Role.find_or_create_by_title('guest')
      v = VendorInterface.find_by_short_name('vernier_goio')
      anonymous_user = User.create(:login => "anonymous", :email => "anonymous", :password_hash => MD5.md5("anonymous").hexdigest, :first_name => "Anonymous", :last_name => "User", :vendor_interface => v)
      admin_user = User.create(:login => "stephen", :email => "stephen@concord.org", :password_hash => "fd035914661eb4f8b00a57be66a2be2b", :first_name => "Stephen", :last_name => "Bannasch", :vendor_interface => v)
      manager_user = User.create(:login => 'cstaudt', :first_name => 'Carolyn', :last_name => 'Staudt', :email => 'carolyn@concord.org', :password_hash => '46e5c6c44beb1cfd814e45fd3b572aa6', :vendor_interface => v)
      anonymous_user.roles << guest_role 
      admin_user.roles << member_role 
      admin_user.roles << admin_role 
      manager_user.roles << member_role 
      manager_user.roles << manager_role       
  end 
  
  desc "Delete local DIY references to external SDS resources: this will cause them to be regenerated."
  task :delete_local_sds_attributes => [:environment, :delete_local_sds_part1, :delete_local_sds_part2, 
    :delete_local_sds_part3, :delete_local_sds_part4] do
  end

  task :delete_local_sds_part1 => :environment do
    puts "\nDeleting LearnerSessions and Learners.\n"
    LearnerSession.delete_all
    Learner.delete_all
    
    puts "\nSetting the sds_user_id in Users to NULL."
  end

  task :delete_local_sds_part2 => :environment do
    puts "\nUsers to process: #{User.count.to_s}:"
    User.update_all("sds_sail_user_id = NULL")
    puts "\nRe-saving each User (this should regenerate the local and remote sds sail_user resources)."
    User.find(:all).each {|u| if u.save then print '.' else print 'x' end }
    puts
  end


  task :delete_local_sds_part3 => :environment do
    puts "\nSetting the sds_offering_id in Activities to NULL."
    Activity.update_all("sds_offering_id = NULL")
    puts "\nRe-saving each Activity (this should regenerate the local and remote sds resources).\n"
    puts "Activities to process: #{Activity.count.to_s}: "
    Activity.find(:all).each {|a| a.save; print '.'}
  end

  task :delete_local_sds_part4 => :environment do
    puts "\nSetting the sds_offering_id in Models, and External Otrunk Activities to NULL."
    Model.update_all("sds_offering_id = NULL")
    ExternalOtrunkActivity.update_all("sds_offering_id = NULL")
    puts "\nRe-saving each Model, and External Otrunk Activity (this should regenerate the local and remote sds resources).\n"
    puts "\nModels to process: #{Model.count.to_s}:"
    Model.find(:all).each {|a| if a.save then print '.' else print 'x' end }
    puts "\nExternal Otrunk Activities to process: #{ExternalOtrunkActivity.count.to_s}:"
    ExternalOtrunkActivity.find(:all).each do |a|
      if a.save
        print '.' 
      else 
        print 'x' 
      end
    end
    puts "\nLearners and LearnerSessions will be re-created as Activities are run. New sds workgroups will be made.\n\n"
  end

  desc "Set uuid and digest attribute for activities."
  task :set_uuid_and_digest_attribute => :environment do
    Activity.find(:all) { |a| a.save }
  end

  desc "Create activity Mixing Water"
  task :create_activity_mixing_water => :environment do
    c = Activity.create(
    :name => 'Mixing Different Temperature Water', 
    :user_id => User.find_by_email('carolyn@concord.org').id, 
    :public => 1, :draft => 1, :textile => 1,
    :description => "In this activity, you will investigate how the temperature changes when two cups of water at different temperatures are mixed.", 
    :introduction => "In this activity, you will investigate how the temperature changes when two cups of water at different temperatures are mixed.\n\n<b>How do I mix water in a fish tank to adjust the temperature?</b>\n\n!/images/activity_images/boywithaquarium.jpg!\n\n", 
    :standards => "Differences between heat and temnperature\n\n", 
    :materials => "* 3 large Styrofoam cups (500 ml or 16 oz)\n* 1 small Styrofoam cup (250 ml or 8 oz)\n* 2 empty 35 mm film canisters\n* ice water\n* warm water - less than 40 degrees Celsius (or 100 degrees Fahrenheit)\n* large pitchers or jugs", 
    :safety => "The warm water in this investigation cannot exceed 40 degrees Celsius (or 100 degrees Fahrenheit). If the water temperature exceeds this temperature, burns may result.", 
    :proced => "!/images/activity_images/foamcups.jpg!\n\n# Obtain 1 small Styrofoam cup and 1 large one. \n# Fill the small cup half full with cold water (ice water with no ice cubes). \n# Put about the same amount of the warm water in the large cup.\n# Connect the temperature sensor to the computer. \n\n\n\n", 
    :predict => "What do you think the temperature will be when you mix one cup of cold water with another cup of about the same amount of warm water? How did you come up with your prediction?", 
    :collectdata => "!/images/activity_images/tempcups.jpg!\n\n# Place the temperature sensor in the small cup. \n# Measure the temperature. When recording the temperature, wait until the temperature read by the sensor stops decreasing, then record your result.\n# Repeat the process for the large cup of water, and record your results below. \n# Pour the small cup of water into the large cup. Measure and record the temperature below.\n\n!/images/activity_images/pourcup.jpg!\n\n", 
    :probe_type_id => ProbeType.find_by_name('Temperature').id,
    :analysis => "!/images/activity_images/combinecannisters.jpg!\n\n# Is the temperature of your mixture close to what you expected? Explain. Be prepared to share your answer with the class.\n# Trying to find patterns or trends in your data can be puzzling. Sometimes it seems like a jumble until you find a good way to display or arrange your data. As a scientist, you have many tools you can use, like tables and charts, and your math abilities. One way to think about the temperature of the mixture is as follows: If you mixed 1 canister of water at temperature 1 and 1 canister of water at temperature 2, the final cup holds 2 canisters of water at temperature 3. The drawing above shows this. Do you see any patterns that could help you predict Temperature 3? If so, what is the pattern?\n# Can you come up with an equation that could help someone else accurately predict the final temperature for 2 identical volumes of water mixing, while only knowing the initial temperatures and volumes?\n# Can you come up with an equation that could help someone else accurately predict the final temperature for 2 different volumes of water mixing, while only knowing the initial temperatures and volumes?", 
    :conclusion => "Suppose that a pet store manager added a liter of water to a fish tank. Consider what would have happened to the tank temperature if the manager had added 10 liters of cold water instead of 1 liter. Consider what would have happened if only a drop of cold water was added. Do you think the amounts of water involved are important? Explain. Be prepared to share your answer with the class.\n\n",
    :further => "* Using 35 mm film canisters and Styrofoam cups, design a method to accurately predict the temperature of your water mixture. How many canisters did you add from cup 1 and cup 2? How many canisters are in cup 3? How did the actual results compare to your prediction?\n\n!/images/activity_images/foamandcannisters.jpg!\n* Can you come up with an equation that could help someone else accurately predict the final temperature for 3 different volumes of water mixing, while only knowing the initial temperatures and volumes?\n* You have a bathtub that has 60 liters of 30 degrees Celsius water in it and you want to bring the temperature up to 40 degrees Celsius. What is the least number of readings you can make with the temperature sensor to get your desired final temperature? Note: you can try this with a bathtub at home, or do it on a smaller scale using cups of water in the classroom."
    ) 
  end

  desc "Create activity Greenhouse Effect"
  task :create_activity_greenhouse_effect => :environment do
    a = Activity.create(
    :name => 'Greenhouse Effect', 
    :user_id => User.find_by_email('carolyn@concord.org').id, 
    :public => 1, :draft => 1, :textile => 1,
    :description => "By using a temperature probe, we can relate changes in sunlight to the temperature of the air being trapped in a container.", 
    :introduction => "!http://www.concord.org/private/jasonv/greenhouse/images/greenhouse21.jpg!

    The greenhouse effect is the name scientists use to describe the process where visible radiation from the sun passes through our atmosphere but infrared radiation emitted by the earth is absorbed by the atmosphere. A majority of the energy from the sun arrives at the earth as visible radiation. This energy passes through our atmosphere and warms the surface of the earth. The warmed surface surface re-emits radiation but this radiation is not visible it is in the infrared. Some of this infrared radiation is absorbed by our atmosphere. Our atmosphere absorbs more of the infrared radiation when water vapor is present. For this reason water vapor is a greenhouse gas. There are other greenhouse gases, such as carbon dioxide and methane. The greenhouse gas that plays the largest role in our atmosphere is water vapor.

    Do varying amounts of greenhouse gases in the atmospheres affect the surface temperatures?", 
    :standards => "Differences between heat and temnperature\n\n", 
    :materials => "* 3 large Styrofoam cups (500 ml or 16 oz)\n* 1 small Styrofoam cup (250 ml or 8 oz)\n* 2 empty 35 mm film canisters\n* ice water\n* warm water - less than 40 degrees Celsius (or 100 degrees Fahrenheit)\n* large pitchers or jugs", 
    :safety => "* <b>Caution:</b> Do not look directly at the sun or a sun lamp as eye damage will result.

* Care should be taken while punching the hole in the plastic food container with the awl or scissors so no injury will result.", 
    :proced => "# Obtain a clear plastic food container without a lid. Any size and shape container will do as long as the container's width is larger than the metal portion of the temperature probe. The container shown just happens to be round.
# Place a small amount of dirt or sugar in the bottom of the container.
# Have an adult punch a small hole halfway up the side of the plastic food container. Place the temperature probe through the side of the container.
!http://www.concord.org/private/jasonv/greenhouse/images/vgreenhouseslits1.jpg!
# Prepare a clear plastic wrap or bubble wrap cover that will be held on by a rubber band.
# Cover the container with plastic wrap or bubble wrap.
# Place your container outside in direct sunlight (or under a bright light).

!http://www.concord.org/private/jasonv/greenhouse/images/vearthgreenhouse1.jpg!
!http://www.concord.org/private/jasonv/greenhouse/images/vvenusgreenhouse.jpg!
", 
    :predict => "Which type of ground surface and thickness of atmosphere will be the hottest?

* Click in the box below and predict in words how the temperature will change inside the container over a ten minute time period based on your dark ground cover and type of choice of \"atmosphere\" (clear plastic wrap or bubble wrap). 
* Also, please draw your prediction directly on the graph before data collection by selecting the pencil and clicking and dragging directly on the graph.You will need to move the time axis to include 600 seconds by clicking and dragging on the axis.", 
    :collectdata => "# Click on the Start button at the bottom of the graph.
# Leave the clear wrap on the container for at least ten minutes.
# Click on the Stop button to stop the data collection.

    ", 
    :probe_type_id => ProbeType.find_by_name('Temperature').id,
    :analysis => "# How did the temperature change inside your container? 
# What caused the change in temperature?
# Do you think there is a relationship between the air temperature inside the container and the depth of atmosphere?", 
    :conclusion => "* What did you find out? 
* What additional questions do your findings raise?
* How would a change in the depth of atmosphere affect the temperature within the container? If so, can you explain why? 
* How does this activity rekate to varying amounts of greenhouse gases in the atmospheres affect the surface temperatures?

Save and mount your results and try it out with a different atmosphere!


      ",
    :further => "* How would the readings change throughout a complete day (24 hours)?
* What if the surface was more reflective? You were using a dark (dirt) surface, now try a light (sugar) surface?
* What would happen if you added other materials to your container like plants or pollutants, etc.? 
* How would an atmosphere of another color affect the temperature within the container?" )
  end
  
  desc "Delete current database, copy from stable, convert tables ..."
  task :delete_copy_and_convert_db => :environment do
    # pull in config
    # copy from production db to development db
    db_config = ActiveRecord::Base.configurations
    remote = db_config['remote']
    remote_str = '  ' + remote.to_a.collect {|i| i.join(': ')}.sort.join("\n  ")
    local = db_config['production']
    local_str = '  ' + local.to_a.collect {|i| i.join(': ')}.sort.join("\n  ")
    temp_file = "#{RAILS_ROOT}/tmp/production.sql"

    # get a connection to the current db
    con = User.connection
    old_version = con.execute("select version from #{RAILS_DATABASE_PREFIX}schema_info").fetch_hash['version']

    # get the stable db
    print "\nGetting the remote database ... "
    cmd_body = "-u #{remote['username']} " << (remote['password'] ? "--password='#{remote['password']}' " : "") << "-h #{remote['host']} #{remote['database']}"
    cmd = "mysqlshow #{cmd_body} '#{remote['table_prefix']}%'"
    # puts "\ncmd:\n#{cmd}"
    tables = `#{cmd}`.scan(/#{remote['table_prefix']}\S+/)[1..-1].join(' ')
    cmd = "mysqldump #{cmd_body} #{tables} > #{temp_file}"
    # puts "\ncmd:\n#{cmd}"
    `#{cmd}`
    puts "done\n"

    puts "\nYour current database tables:\n\n"
    puts local_str
    puts "\nare about to be deleted and replaced with data from this remote database:\n\n"
    puts remote_str
    puts "\nAny data that only exists in your current db will be lost."
    print "\nAre you sure you want to proceed? [Y/n] "
    response = STDIN.gets
    response = response.chomp
    puts ""
    case response
    when "y", "Y", "yes", "Yes", ""
      # continue
    when "n", "N", "no", "No"
      puts "Aborting."
      return
    else
      puts "Invalid response. Aborting."
      return
    end

    # clear out the current db
    print "Deleting tables in the current database "
    con.tables.each do |t|
      if t.match "^#{RAILS_DATABASE_PREFIX}"
        con.drop_table(t)
        print "."
      end
    end
    puts " done.\n\n"

    # The table prefixes may not match...
    # we need to convert the db dump to the current prefix
    File.open(temp_file) { |file|
      File.open(temp_file + ".new", "w") { |new_file|
        begin
          while line = file.readline
            new_file.write(line.gsub(/#{remote['table_prefix']}/,"#{RAILS_DATABASE_PREFIX}"))
          end
        rescue
        end
      }
    }

    # import the stable db
    print "Importing the stable database ... "
    command = "mysql -u #{local['username']} " << (local['password'] ? "--password='#{local['password']}' " : "") << "-h #{local['host']} #{local['database']} < #{temp_file}.new"
    `#{command}`
    puts "done.\n\n"

    con = User.connection
    new_version = con.execute("select version from #{RAILS_DATABASE_PREFIX}schema_info").fetch_hash['version']
    puts "Previous database version: #{old_version}"
    puts "Production database version: #{new_version}"
    if old_version > new_version
      puts "*** The production database was older than your existing database. You should probably run:\n\n"
      puts "***    rake db:migrate\n\n"
      puts "*** to update your new database."
    elsif old_version < new_version
      puts "*** The production database was newer than your existing database. You might want to run:\n\n"
      puts "***    svn up\n\n"
      puts "*** to be sure you're running the latest code."
    end
    puts 
    puts "Often you will want to follow the successful completion of this task by running either:\n\n"
    puts "   rake diy:migrate_sds_data\n\n"
    puts "To copy learner data from another SDS to the new SDS for this DIY instance. Or ...\n\n"
    puts "   rake diy:delete_local_sds_attributes\n\n"
    puts "Which will erase and re-generate the SDS attributes for the local DIY"
    puts
  end
  
  desc "Migrate the DIY data stored in an SDS from one SDS to another."
  task :migrate_sds_data => :environment do
  puts "This is intended to move data from one SDS to another."
  puts "You should have already updated your sds.yml file to point to the *new* SDS."
  puts "Often you will want to run the task: 'rake diy:delete_copy_and_convert_db' immediately prior to running this task."
  puts "Moving data from:\n\n"
  puts "  #{OLD_SDS_HOST}\n"
  puts "to\n"
  puts "  #{SdsConnect::Connect.config['host']}\n"
  print "\nWould you like to proceed? [y/N] "
  response = STDIN.gets
  response = response.chomp 
  puts ""
  case response
  when "y", "Y", "yes", "Yes"
    # continue
  when "n", "N", "no", "No", ""
    puts "Aborting."
    return
  else
    puts "Invalid response. Aborting."
    return
  end
  require 'timeout'
  Timeout.timeout(60*60*24) { # let this run for up to 24 hours 
  # check that OLD_SDS_HOST is defined
  if OLD_SDS_HOST
    # check the version of the sds to make sure the sds is up and running
    sds_version = nil
    uri = URI.parse("#{OLD_SDS_HOST}/")
    Net::HTTP.start(uri.host, uri.port) do |http|
      sds_version = Hash.from_xml(http.get(uri.path, 'Accept' => 'application/xml').body)['sds']['version']
    end
    if sds_version && sds_version.to_f >= 1.0
      # we're ok
    else
      puts "The OLD_SDS_HOST did not return a recognizable version string. Please double-check the url."
      return
    end
  else
    puts "OLD_SDS_HOST is not defined. Please add this to the environment.rb and set it to the old SDS host url."
    return
  end
  SdsConnect::Connect.setup
  # check that the jnlp exists
  jnlp = SdsConnect::Connect.jnlp(SdsConnect::Connect.jnlp_id)
  # check that the curnit exists
  curnit = SdsConnect::Connect.curnit(SdsConnect::Connect.curnit_id)
  # if either doesn't, exit with an error
  if ! jnlp['jnlp']
    puts "The jnlp defined in the sds.yml file doesn't seem to exist. Please double-check it."
    return
  elsif ! curnit['curnit']
    puts "The curnit defined in the sds.yml file doesn't seem to exist. Please double-check it."
    return
  end
  
  #### can we do these just by calling save on each thing?
  ###### yes, but we need to save some of the old values to get the bundles

## arrays to store old information
  old_workgroups = []  ## an array of hashes --> learner.id => { "workgroup_id" => #, "workgroup_version" => #}
  old_offerings = {}  ## a hash of offering ids --> "runnable.type-runnable.id" => offering_id

## arrays to store any failures
  failed_users = []
  failed_runnable = []
  failed_learner = []
  failed_workgroup = []

	print "Migrating users (#{User.count}) ..."
  count = 0
  # for each USER, create a sail_user in the new SDS and update the local sds_sail_user_id
  User.find(:all).each do |u|
    if (count % 50 == 0)
      print "\n#{count}: "
    end
    count += 1
    u.sds_sail_user_id = nil
    if ! u.save
      $stderr.puts "Failed to move user: (#{u.id}) #{u.name}"
      failed_users << u
    else
			print "."
    end
  end
 
	puts " done."
	
  # for each RUNNABLE (activity, otrunk activity, model), create an offering in the new sds and update the local sds_offering_id
  runnables = Activity.find(:all) << Model.find(:all) << ExternalOtrunkActivity.find(:all)
  runnables.flatten!
  print "Migrating runnables (#{runnables.size})..." 
  count = 0
  runnables.each do |r|
    if (count % 50 == 0)
      print "\n#{count}: "
    end
    count += 1
    old_offerings["#{r.type}-#{r.id}"] = r.sds_offering_id
    r.sds_offering_id = nil
    if ! r.save
      $stderr.puts "Failed to move runnable: #{r.type} #{r.id}"
      failed_runnable << r
    else
			print "."
    end
  end

	puts " done."
	
  
  # for each LEARNER, create a workgroup in the new SDS, assign the correct sail_user to the workgroup, and update the local sds_workgroup_id
  print "Migrating learners (#{Learner.count})..."
  count = 0
  Learner.find(:all).each do |l|
    if (count % 50 == 0)
      print "\n#{count}: "
    end
    count += 1
    if failed_users.include? l.user
      $stderr.puts "Skipping learner #{l.id} because the user failed to be moved."
      failed_learner << l
      next
    end
    if l.runnable == nil
   	  $stderr.puts "Skipping learner #{l.id} because the runnable is nil."
      failed_learner << l
      next
    end
    old_wid = l.sds_workgroup_id
    wkgrp = nil
    uri = URI.parse("#{OLD_SDS_HOST}/workgroup/#{old_wid}")
      Net::HTTP.start(uri.host, uri.port) do |http|
        wkgrp = Hash.from_xml(http.get(uri.path, 'Accept' => 'application/xml').body)["workgroup"]
      end
    old_widv = wkgrp["version"]
    old_workgroups[l.id] = { "workgroup_id" => old_wid, "workgroup_version" => old_widv }
    
    l.sds_workgroup_id = nil
    if ! l.save
      $stderr.puts "Failed to move learner: #{learner.id}"
      failed_learner << l
    else
      print "."
    end
  end

	puts " done."
  print "Migrating learner data (#{LearnerSession.count}) ..."
  count = 0
  # for each WORKGROUP, get the bundles and upload them to the new sds
  # REQUIRES KNOWING THE OLD OFFERING, WORKGROUP ID AND WORKGROUP VERSION
  learners = LearnerSession.find(:all).collect{|ls| ls.learner}.uniq
  learners.each do |l|
  begin
    if (failed_learner.include? l)
    	$stderr.puts "Skipping learner (#{l.id}) because the learner had an error earlier"
    	next
    end
    old_wid = old_workgroups[l.id]["workgroup_id"]
    old_widv = old_workgroups[l.id]["workgroup_version"]
    old_oid = old_offerings["#{l.runnable_type}-#{l.runnable_id}"]
    bundles_xml = nil
    uri = URI.parse("#{OLD_SDS_HOST}/offering/#{old_oid}/bundle/#{old_wid}/#{old_widv}")
    # puts "Moving bundle #{OLD_SDS_HOST}/offering/#{old_oid}/bundle/#{old_wid}/#{old_widv}"
    Net::HTTP.start(uri.host, uri.port) do |http|
      bundles_xml = http.get(uri.path, 'Accept' => 'application/xml').body
    end

    bundles = REXML::Document.new(bundles_xml)
    
    new_offering_id = l.runnable.sds_offering_id
    new_workgroup_id = l.sds_workgroup_id
    wkgrp = SdsConnect::Connect.workgroup(new_workgroup_id)["workgroup"]
    new_workgroup_version = 1
    if wkgrp
    	new_workgroup_version = (wkgrp["version"] ? wkgrp["version"] : 1)
    end
    post_url = "#{SdsConnect::Connect.host_url}/offering/#{new_offering_id}/bundle/#{new_workgroup_id}/#{new_workgroup_version}"
    
    # pull out each <sessionBundles>... </sessionBundles>
    bundles.elements.each("//sessionBundles") do |sb|
      if ! sb.has_elements?
        # skip it if it doesn't have any information
        $stderr.puts "Bundle is empty! (o: #{old_oid}, w: #{old_wid}, wv: #{old_widv}) which is now (l: #{l.id})"
        next
      end
      #    modify the sdsReturnAddresses to match the new data
      ra = sb.elements["//sdsReturnAddresses"]
      if ra
        ra.text = post_url
      else
        $stderr.puts "No return address on bundle (o: #{old_oid}, w: #{old_wid}, wv: #{old_widv}) which is now (l: #{l.id})"
      end
      
      #    post it to the post_url
      begin
          uri = URI.parse("#{post_url}")
	      puts uri.to_s
	      Net::HTTP.start(uri.host, uri.port) do |http|
	        response = http.post(uri.path, sb.to_s, 'Content-Type' => 'application/xml')
	        unless response.class == Net::HTTPCreated
	          ActionController::Base.logger.warn("\npost_resource:\n  path: #{uri.path}, uri: #{uri.to_s}\n  resource: #{sb.to_s}")
	          ActionController::Base.logger.warn("  response: #{response.code}: #{response.message}\n  body: \n#{response.body}")
  	      end
          if (count % 50 == 0)
            print "\n#{count}: "
          end
          count += 1
					print "."
	      end
      rescue => e
        $stderr.puts "--------------------------------------------"
        $stderr.puts "Error saving bundle for (o: #{old_oid}, w: #{old_wid}, wv: #{old_widv}) which is now (l: #{l.id})"
        $stderr.puts "#{e}\n#{e.backtrace.join("\n")}"
      end
    end
    rescue Exception => ex
        $stderr.puts "--------------------------------------------"
        $stderr.puts "Error saving bundle for (o: #{old_oid}, w: #{old_wid}, wv: #{old_widv}) which is now (l: #{l.id})"
        $stderr.puts "#{ex}\n#{ex.backtrace.join("\n")}"
    end
  end

	puts " done."
  
  puts "\nFinished."
  total = failed_users.length + failed_learner.length + failed_workgroup.length + failed_runnable.length
  puts "\nThere were #{total} total errors."
  if total > 0
	  puts "Users failed:      #{failed_users.length}"
	  puts "Learners failed:   #{failed_learner.length}"
	  puts "Workgroups failed: #{failed_workgroup.length}"
	  puts "Runnables failed:  #{failed_runnable.length}"
  end
  # TODO List each failed artifact.
		} # end timeout
  end

  desc "Copy all of the external otrunk activities to a local location, including referenced artifacts"
  task :copy_otrunk_activities_locally => :environment do
  require 'open-uri'
  require 'ftools'
  require 'cgi'
  STDOUT.sync = true
  STDERR.sync = true
  cache_dir = "#{RAILS_ROOT}/public/cache/"
  # url = "/"
  # print "\nPlease enter the DIY's base url path: [#{url}]  "
  # diy_url = STDIN.gets.chomp
  # if diy_url.empty?
  #   diy_url = url
  # end
  # diy_url.gsub!(/.\/$/,"")
  @errors = {}
  # for each external otrunk activity
  ExternalOtrunkActivity.find(:all, :conditions => "public=1").each do |a|
    # open the otml file from the specified url or grab the embedded content
    content = ""
    if (a.external_otml_url)
      content = open(a.external_otml_url).read
    else
      content = a.otml
    end
    parse_file("#{cache_dir}#{a.uuid}/#{a.uuid}.otml", content, cache_dir + "#{a.uuid}/", URI.parse(a.external_otml_url), true)
    # update the url to point to the local copy
    # we don't need to do this anymore, just be sure that :cache_external_otrunk_activities: true is set in the app config
    # a.external_otml_url = "#{diy_url}/cache/#{a.uuid}/unit-#{a.uuid}.otml"
    # if a.save
    #   puts " done."
    # else
    #   puts "\n Couldn't save activity #{a.id}"
    # end
  end

  puts "\nThere were #{@errors.length} artifacts with errors.\n"
  @errors.each do |k,v|
  	puts "In #{k}:"
  	v.uniq.each do |e|
      puts "    #{e}"
    end
  end
  puts "\nDon't forget to set :cache_external_otrunk_activities: true in the application config file.\n"
  end
  
  def parse_file(filename, content, cache_dir, parent_url, recurse)
    short_filename = /\/([^\/]+)$/.match(filename)[1]
    print "\n#{short_filename}: "
    lines = content.split("\n")
    new_content = ""
    lines.each do |line|
      #   scan for anything that matches (http://[^'"]+)
      url_regex = /(http:\/\/[^'"]+)/
      src_regex = /src=['"]([^'"]+)/
      match_indexes = []
      while ( ((match = url_regex.match(line)) && (! match_indexes.include?(match.begin(1)))) ||
                ((match = src_regex.match(line)) && (! match_indexes.include?(match.begin(1)))) )
        # puts "Matched url: #{match[1]}"
        match_indexes << match.begin(1)
        #   get the resource from that location, save it locally
        match_url = match[1].gsub(/\s+/,"").gsub(/[\?\#&;=\+\$,<>"\{\}\|\\\^\[\]].*$/,"")
        # puts("pre: #{match[1]}, post: #{match_url}")
        begin
          resource_url = URI.parse(CGI.unescapeHTML(match_url))
        rescue
          @errors[parent_url] ||= []
        @errors[parent_url] << "Bad URL: '#{CGI.unescapeHTML(match_url)}', skipping."
          print 'x'
          next
        end
        if (resource_url.relative?)
          # relative URL's need to have their parent document's codebase appended before trying to download
          resource_url = parent_url.merge(resource_url.to_s)
        end
        localFile = match_url
        localFile = localFile.gsub("http://","")
        localFile = localFile.gsub(/\/$/,"")
        # localFile = localFile.gsub(/[\?\#&;=\+\$,<>"\{\}\|\\\^\[\]].*$/,"")
        localDir = localFile.gsub(/[^\/]+$/,"")
        File.makedirs(cache_dir + localDir)
        
        next if (localFile.length < 1)
        next if (localFile =~ /^mailto/)
        
        # Uncomment the if/else if you want to skip downloading already existing files.
        # if File.exist?(cache_dir + localFile)
          # this already exists, so assume it's current and skip
          # FIXME - possibly we could compare timestamps or something
        #   print 's'
        # else
          # if it's an otml/html file, we should parse it too (only one level down)
          if ((localFile =~ /otml$/ || localFile =~ /html/) && recurse)
              parse_file(cache_dir + localFile, open(resource_url.to_s).read, cache_dir + localDir + "/", resource_url, false)
          else
            f = File.new(cache_dir + localFile, "w")
            begin
              f.write(open(resource_url.to_s).read)
              print "."
            rescue => e
              @errors[parent_url] ||= []
              @errors[parent_url] << "Problem getting or writing file: #{resource_url.to_s},   Error: #{e}"
              print 'X'
            end
            f.flush
            f.close
          end
        # end
        #   replace the url reference with a url to the local resource
        line = line.gsub(match_url, localFile)
        
      end
      new_content << line
      new_content << "\n"
    end
    # save the file in the local server directories
    f = File.new(filename, "w")
    f.write(new_content)
    f.flush
    f.close
    print ".\n"
  end
  
  desc "Copy all of the external mw models which reside in zip files (created in MW 1.3) locally"
  task :copy_mw_zips_locally => :environment do
    require 'open-uri'
    require 'zip/zip'
    
    url = "http://itsidiy.concord.org/"
    print "\nPlease enter the DIY's base url path: [#{url}]  "
    server_prefix = STDIN.gets.chomp
    if server_prefix.empty?
      server_prefix = url
    end
    server_prefix.gsub!(/.[\/]+$/,"")

    # for each model of the MW model type
    mt = ModelType.find(1)
    
    server_location = "#{RAILS_ROOT}/public/model_files"
    temp_dir = "#{RAILS_ROOT}/tmp"
    begin
      Dir.mkdir(server_location)
    rescue SystemCallError => e
      puts "#{e}"
    end
    begin
      Dir.mkdir(temp_dir)
    rescue SystemCallError => e
      puts "#{e}"
    end
    mt.models.each do |m|
    # m = mt.models[0]
      # if the url matches zip
      if (m.url =~ /zip/)
        begin
        # puts "Url: #{m.url}"
        filename = /([^=]+\.zip)/.match(m.url)[1]
        # puts "Filename: #{filename}"
        # download the zip
        Dir.mkdir("#{server_location}/#{m.id}")
        Dir.mkdir("#{temp_dir}/#{m.id}")
        File.open("#{temp_dir}/#{m.id}/#{filename}", "w") {|f| f.write(open(m.url).read) }
        # extract the zip
        mfiles = []
        Zip::ZipFile.foreach("#{temp_dir}/#{m.id}/#{filename}") do |zipfile|
          zipfile.extract("#{server_location}/#{m.id}/#{zipfile.filepath}#{zipfile.name}")
          if zipfile.name =~ /cml$/
            mfiles << "#{zipfile.filepath}#{zipfile.name}"
          end
        end
        # change the model url
        if (mfiles.length > 1)
          puts "Found #{mfiles.length} cml files for model #{m.id}"
        end
        if (mfiles.length == 0)
          raise "Found NO cml files for model #{m.id}. Aborting this model!"
        end
        # puts "Setting url to be #{server_prefix}/model_files/#{m.id}/#{mfiles[0]}"
        m.url = "#{server_prefix}/model_files/#{m.id}/#{mfiles[0]}"
        # save the model
        m.save!
        print "."
        rescue Exception => e
          puts "Model #{m.id} had a problem: #{e}\n#{e.backtrace.join("\n")}"
        end
      end
    end
    puts "Done."
  end
  
  desc "Parse the rails log to determine ancestry information"
  task :recreate_ancestry_from_logs => :environment do
    open_copy_sessions = {}
    current_linkage = nil
    
    # controller = m[1], ip = m[2], timestamp = m[3]
    copy_regex = /^Processing (Activities|Models|ExternalOtrunkActivites)Controller#copy \(for ([^ ]+) at (.+)\) \[GET\]$/
    # sess_id = m[1]
    session_id_regex = /^  Session ID: ([0-9a-f]+)$/
    # id = m[1]
    params_regex = /^  Parameters: \{[^\}]+"id"=>"([0-9]+)"[^\}]+"controller"=>"([^"]+)"/
    
    # controller = m[1], ip = m[2], timestamp = m[3]
    create_regex = /^Processing (Activities|Models|ExternalOtrunkActivites)Controller#create \(for ([^ ]+) at (.+)\) \[POST\]$/
    # id = m[1]
    redirect_regex = /^Redirected to [^ 0-9]+([0-9]+)(|\/edit)$/
    url_regex = /.*302 Found \[.*(activities|models|external_otrunk_activities)\]$/
    
    new_regex = /^Processing (Activities|Models|ExternalOtrunkActivites)Controller#new \(for ([^ ]+) at (.+)\) \[GET\]$/
    
    # vars
    session_id = nil
    parent_id = nil
    controller = nil
    timestamp = nil
    ip = nil
    
    state = :clean
    
    count = 0
    File.open("#{RAILS_ROOT}/log/production.log") {|f|
      begin
        while line = f.readline
          count += 1
          
          # if copy source line
          if line =~ copy_regex
            # extract copy info
            ip = Regexp.last_match(2)
            timestamp = Regexp.last_match(3)
            controller = Regexp.last_match(1)
            line = f.readline
            count += 1
            # if session id line, extract session
            if line =~ session_id_regex
              session_id = Regexp.last_match(1)
              line = f.readline
              count += 1
              # if params line, extract parent id
              if line =~ params_regex
                parent_id = Regexp.last_match(1)
                open_copy_sessions["#{controller}-#{session_id}"] = {:session_id => session_id, :parent_id => parent_id, :controller => controller, :timestamp => timestamp, :ip => ip}
                puts "Open copy: #{session_id} - #{parent_id} <==> ?? - #{controller} - #{timestamp} - #{ip} - Line: #{count}"
              else
                # we were in a copy session, but didn't get an expected line
              end
            else
              #expected a session id line, didn't find it
            end
            session_id = parent_id = controller = timestamp = ip = nil
            # if create source line
          elsif line =~ create_regex
            # extract create info
            ip = Regexp.last_match(2)
            timestamp = Regexp.last_match(3)
            controller = Regexp.last_match(1)
            line = f.readline
            count += 1
            # if session id line, extract session, create copy-create linkage
            if line =~ session_id_regex
              session_id = Regexp.last_match(1)
              line = f.readline
              count += 1
              # don't bother with params line
              line = f.readline
              count += 1
              if line =~ redirect_regex
                # if there's a copy-create linkage
                if current_linkage = open_copy_sessions["#{controller}-#{session_id}"]
                  child_id = Regexp.last_match(1)
                  line = f.readline
                  count += 1
                  if line =~ url_regex
                    # assume we have a match
                    if child_id.to_i < current_linkage[:parent_id].to_i
                      puts "CHILD ID LESS THAN PARENT'S ID -- Line: #{count}"
                    end
                    puts "Match: #{current_linkage[:session_id]} - #{current_linkage[:parent_id]} <==> #{child_id} - #{current_linkage[:controller]} - #{current_linkage[:timestamp]} - #{current_linkage[:ip]} - Line: #{count}"
                    set_relationship(current_linkage[:parent_id], child_id, current_linkage[:controller])
                    open_copy_sessions.delete("#{current_linkage[:controller]}-#{current_linkage[:session_id]}")
                    current_linkage = nil
                  else
                    if line =~ /[Rr]edirect/
                      puts "FAILED match (url not correct): #{current_linkage[:session_id]} - #{current_linkage[:parent_id]} <==> #{child_id} - #{current_linkage[:controller]} - #{current_linkage[:timestamp]} - #{current_linkage[:ip]} - Line: #{count}"
                    end
                  end
                else
                  # ignore
                end
                session_id = parent_id = controller = timestamp = ip = nil
              else
                if line =~ /[Rr]endering/
                  puts "FAILED match (render, not redirect): #{session_id} - Line: #{count}"
                elsif line =~ /Filter chain halted/
                  puts "FAILED match (filter chain, not redirect): #{session_id} - Line: #{count}"
                elsif line =~ /Redirected/
                  puts "FAILED match (redirect to a non-id): #{session_id} - Line: #{count}"
                else
                  puts "FAILED match (redirect not found): #{session_id} - Line: #{count} :: #{line}"
                end
              end
            end
          elsif line =~ new_regex
            controller = Regexp.last_match(1)
            line = f.readline
            count += 1
            # if session id line, extract session, create copy-create linkage
            if line =~ session_id_regex
              session_id = Regexp.last_match(1)
              if open_copy_sessions["#{controller}-#{session_id}"]
                open_copy_sessions.delete("#{controller}-#{session_id}")
                puts "Removing: #{controller} - #{session_id} - Line: #{count}"
              end
            end
            session_id = parent_id = controller = timestamp = ip = nil
          end
        end
      rescue EOFError
        puts "Done."
      end
    }
    
    puts "Count: #{count}"
  end
  
  def controller_to_url(str)
    case str
      when "Activities"
        "activities"
      when "Models"
        "models"
      when "ExternalOtrunkActivities"
        "external_otrunk_activities"
    else
        "unknown"
    end
  end
  
  def set_relationship(parent_id, child_id, type)
    parent = nil
    child = nil
    if parent_id == nil || child_id == nil
      $stderr.puts "Parent or child id was nil: type: #{type}, parent: #{parent_id}, child: #{child_id}"
      return
    end
    begin
      case type
        when "Activities"
          parent = Activity.find(parent_id)
          child = Activity.find(child_id)
        when "Models"
          parent = Model.find(parent_id)
          child = Model.find(child_id)
        when "ExternalOtrunkActivities"
          parent = ExternalOtrunkActivity.find(parent_id)
          child = ExternalOtrunkActivity.find(child_id)
      end
      if parent == nil || child == nil
        $stderr.puts "Parent or child was nil: type: #{type}, parent: #{parent_id}, child: #{child_id}"
        return
      end
      
      child.parent = parent
      child.save!
    rescue => e
      $stderr.puts "#{e}: type: #{type}, parent: #{parent_id}, child: #{child_id}"
    end
  end
end
