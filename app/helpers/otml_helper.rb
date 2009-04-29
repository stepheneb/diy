module OtmlHelper

  require 'redcloth'
  
  def probeware_msg
    "Your current probeware interface is: *#{@vendor_interface.name}*. If you want to use this activity with a different probeware interface, close this activity, change the probeware selection in your user settings and re-launch the activity."
  end

  def ot_user_list_imports(xml)
    xml.imports {
      xml.import("class" => "org.concord.otrunk.view.OTUserList")
      xml.import("class" => "org.concord.otrunk.view.OTUserDatabaseRef")
    }
  end

  def otml_imports(xml)
    xml.imports {
      # main
      xml.import("class" => "org.concord.otrunk.OTSystem")
      xml.import("class" => "org.concord.otrunk.view.OTFolderObject")
      xml.import("class" => "org.concord.otrunk.view.document.OTCompoundDoc")
      xml.import("class" => "org.concord.otrunk.view.document.OTTextObject")
      xml.import("class" => "org.concord.otrunk.view.OTViewEntry")
      xml.import("class" => "org.concord.otrunk.view.OTViewService")
      xml.import("class" => "org.concord.framework.otrunk.view.OTFrame")
      # snapshot
      xml.import("class" => "org.concord.otrunk.view.OTViewMode")
      xml.import("class" => "org.concord.otrunk.ui.snapshot.OTSnapshot")
      xml.import("class" => "org.concord.otrunk.ui.snapshot.OTSnapshotButton")
      xml.import("class" => "org.concord.otrunk.ui.snapshot.OTSnapshotAlbum")
      xml.import("class" => "org.concord.otrunk.ui.OTImage")
      # Pf
      xml.import("class" => "org.concord.portfolio.objects.PfCompoundDoc")
      xml.import("class" => "org.concord.portfolio.objects.PfChoice")
      xml.import("class" => "org.concord.portfolio.objects.PfImage")
      xml.import("class" => "org.concord.portfolio.objects.PfResponse")
      xml.import("class" => "org.concord.portfolio.objects.PfQuery")
      xml.import("class" => "org.concord.portfolio.objects.PfResponseTable")
      xml.import("class" => "org.concord.portfolio.objects.PfTechnicalHint")
      # UI
      xml.import("class" => "org.concord.otrunk.ui.OTText")     
      # data
      xml.import("class" => "org.concord.data.state.OTDataStore")
      xml.import('class' => 'org.concord.sensor.state.OTZeroSensor')
      xml.import("class" => "org.concord.data.state.OTDataChannelDescription")
      xml.import("class" => "org.concord.data.state.OTDataField")
      xml.import("class" => "org.concord.datagraph.state.OTDataGraph")
      xml.import("class" => "org.concord.datagraph.state.OTDataAxis")
      xml.import("class" => "org.concord.datagraph.state.OTDataGraphable")
      xml.import("class" => "org.concord.datagraph.state.OTDataCollector")
      xml.import("class" => "org.concord.datagraph.state.OTMultiDataGraph")
      xml.import('class' => 'org.concord.datagraph.state.OTPluginView')
      xml.import('class' => 'org.concord.otrunk.control.OTButton')      
      # drawings
      xml.import("class" => "org.concord.graph.util.state.OTDrawingTool")
      xml.import("class" => "org.concord.graph.util.state.OTDrawingStamp")
      xml.import("class" => "org.concord.graph.util.state.OTDrawingImageIcon")
      xml.import("class" => "org.concord.graph.util.state.OTDrawingShape")
      xml.import("class" => "org.concord.graph.util.state.OTPointTextLabel")
#     xml.import("class" => "org.concord.framework.data.stream.DataProducer")
#     xml.import("class" => "org.concord.framework.data.stream.DataStreamDescription")
      # probes
      xml.import("class" => "org.concord.sensor.state.OTDeviceConfig")
      xml.import("class" => "org.concord.sensor.state.OTExperimentRequest")
      xml.import("class" => "org.concord.sensor.state.OTInterfaceManager")
      xml.import("class" => "org.concord.sensor.state.OTSensorDataProxy")
      xml.import("class" => "org.concord.sensor.state.OTSensorRequest")
      # model_types
      ModelType.find(:all).each do |mt|
        xml.import("class" => mt.otrunk_object_class)
      end
      DataFilter.find(:all).each do |df|
        xml.import("class" => df.otrunk_object_class)
      end
      
    }
  end

  def otml_services(xml)
    xml.services {
      xml.OTViewService("showLeftPanel" => "false") {
        xml.viewEntries {
          xml.OTViewEntry("viewClass" => "org.concord.otrunk.view.document.OTDocumentView", "objectClass" => "org.concord.otrunk.view.document.OTDocument")
          xml.OTViewEntry("viewClass" => "org.concord.portfolio.views.PfQueryView", "objectClass" => "org.concord.portfolio.objects.PfQuery")
          xml.OTViewEntry("viewClass" => "org.concord.otrunk.ui.swing.OTTextEditView", "objectClass" => "org.concord.otrunk.ui.OTText")
          xml.OTViewEntry("viewClass" => "org.concord.portfolio.views.PfImageView", "objectClass" => "org.concord.portfolio.objects.PfImage")
          xml.OTViewEntry("viewClass" => "org.concord.portfolio.views.PfChoiceView", "objectClass" => "org.concord.portfolio.objects.PfChoice")
          xml.OTViewEntry("viewClass" => "org.concord.datagraph.state.OTDataCollectorView", "objectClass" => "org.concord.datagraph.state.OTDataCollector")
          xml.OTViewEntry("viewClass" => "org.concord.datagraph.state.OTDataGraphView", "objectClass" => "org.concord.datagraph.state.OTDataGraph")
          xml.OTViewEntry("viewClass" => "org.concord.data.state.OTDataFieldView", "objectClass" => "org.concord.data.state.OTDataField")
          xml.OTViewEntry("viewClass" => "org.concord.datagraph.state.OTDataDrawingToolView", "objectClass" => "org.concord.graph.util.state.OTDrawingTool")
          xml.OTViewEntry("viewClass" => "org.concord.datagraph.state.OTMultiDataGraphView", "objectClass" => "org.concord.datagraph.state.OTMultiDataGraph")
          xml.OTViewEntry('viewClass' => 'org.concord.otrunk.control.OTButtonView', 'objectClass' => 'org.concord.otrunk.control.OTButton')
          # snapshot
          xml.OTViewEntry('viewClass' => 'org.concord.otrunk.ui.snapshot.OTSnapshotButtonView', 'objectClass'=> 'org.concord.otrunk.ui.snapshot.OTSnapshotButton', 'local_id' => 'snapshot_button_view')
          xml.OTViewEntry('viewClass' => 'org.concord.otrunk.ui.snapshot.OTSnapshotAlbumView', 'objectClass'=> 'org.concord.otrunk.ui.snapshot.OTSnapshotAlbum')
          xml.OTViewEntry('viewClass' => 'org.concord.otrunk.view.document.OTDocumentView', 'objectClass'=> 'org.concord.otrunk.view.document.OTDocument')
          # model_types
          ModelType.find(:all).each do |mt|
            xml.OTViewEntry("viewClass" => mt.otrunk_view_class, "objectClass" => mt.otrunk_object_class)
          end
        }
      }
      xml.OTInterfaceManager {
        xml.deviceConfigs {
          @vendor_interface.device_configs.each do |dc|
            xml.OTDeviceConfig("configString" => dc.config_string, "deviceId" => @vendor_interface.device_id)
          end
        }
      }
    }
  end

  def otml_choice(xml)
    xml.PfChoice("local_id" => "vendor_choice") {
      xml.currentChoice { xml.object("refid" => "${vendor_id_#{@vendor_interface.short_name}}") }
        xml.choices { 
          xml.PfCompoundDoc("local_id" => "vendor_id_vernier_goio") {
            xml.bodyText("Vernier GoIO")
          }
          xml.PfCompoundDoc("local_id" => "vendor_id_vernier_labpro") {
            xml.bodyText("Vernier LabPro")
          }
          xml.PfCompoundDoc("local_id" => "vendor_id_pasco_sw500") {
            xml.bodyText("Pasco Science Workshop 500")
          }
          xml.PfCompoundDoc("local_id" => "vendor_id_pasco_airlink") {
              xml.bodyText("Pasco Airlink")
          }
          xml.PfCompoundDoc("local_id" => "vendor_id_dataharvest_easysense_q") {
            xml.bodyText("Data Harvest Easysense Q")
          }
          xml.PfCompoundDoc("local_id" => "vendor_id_ti_cbl2") {
            xml.bodyText("Texas Instruments CLB II")
          }
          xml.PfCompoundDoc("local_id" => "vendor_id_fourier_ecolog") {
            xml.bodyText("Fourier Ecolog")
          }
          xml.PfCompoundDoc("local_id" => "vendor_id_pseudo_interface") {
            xml.bodyText("Vernier")
          }
        }
      }
  end

  def otml_sensor_requets(xml, pt)
    xml.sensorRequests { 
      xml.OTSensorRequest("type" => pt.ptype, "stepSize" => pt.step_size, 
                          "displayPrecision" => pt.display_precision, "port" => pt.port, 
                          "unit" => pt.unit, "requiredMax" => pt.max, "requiredMin" => pt.min) }
  end

  def otml_sensor_data_proxy(xml, pt, id)
    xml.OTSensorDataProxy("local_id" => "dp_#{id}", "name" => "dataproducer") {
      xml.request { 
        xml.OTExperimentRequest("period" => pt.period) {
          otml_sensor_requets(xml, pt)
        } 
      }
      if pt.ptype == 5 # force
        xml.zeroSensor {
          xml.OTZeroSensor('local_id' => "force_zero_#{id}", 'sensorIndex' => '0')
        }
      end
    } 
  end

  def otml_datacollector(pt, multi, calibration, xml, id, predict_id=nil)
    xml.OTDataCollector("local_id" => id, "name" => "datacollector", "multipleGraphableEnabled" => multi, 
      "title" => "#{pt.name} Sensor#{if predict_id then ' and Prediction' end} Graph", "autoScaleEnabled" => "true") {
      if predict_id
        xml.graphables {
          xml.OTDataGraphable("connectPoints" => "true", "locked" => "true", 
              "color" => "0xff0000", "drawMarks" => "false", "name" => "Prediction", 
              "xColumn" => "0", "yColumn" => "1") {
            xml.dataStore { otml_object_reference(xml, "#{predict_id}_datastore") }
          } 
        }
      end
      xml.source { 
        xml.OTDataGraphable("connectPoints" => "true", "color" => "0x0000ff", "drawMarks" => "false", "name" => "Sensor", "xColumn" => "0", "yColumn" => "1") {
          xml.dataProducer { 
            if calibration
              attributes = []
              %w{ k0 k1 k2 k3 }.each do |coeff|
                if calibration.data_filter.send("#{coeff}_active")
                  attributes << "'#{coeff}' => '#{calibration.send(coeff)}'"
                end
                attributes << "'sourceChannel' => '1'"
              end
              element_name = calibration.data_filter.otrunk_object_class[/(.*\.)(.*)/, 2]
              eval("xml.#{element_name}(#{attributes.join(',')}) { xml.source { otml_sensor_data_proxy(xml, pt, id) } }")
            else
              otml_sensor_data_proxy(xml, pt, id)
            end
          }
          xml.dataStore { xml.OTDataStore("local_id" => "ds_#{id}") } 
        } 
      }
      if calibration
        xml.xDataAxis { xml.OTDataAxis("min" => calibration.x_axis_min, "max" => calibration.x_axis_max, "label" => "Time", "units" => "s") }
        xml.yDataAxis { xml.OTDataAxis("min" => calibration.y_axis_min, "max" => calibration.y_axis_max, "label" => calibration.physical_unit.quantity.capitalize, "units" => calibration.physical_unit.unit_symbol_text) }
      else
        xml.xDataAxis { xml.OTDataAxis("min" => "0", "max" => "60", "label" => "Time", "units" => "s") }
        xml.yDataAxis { xml.OTDataAxis("min" => pt.min, "max" => pt.max, "label" => pt.name, "units" => pt.unit) }
      end
    }
    if pt.ptype == 5 # force
      xml.OTButton("text" => "Zero Force", "local_id" => "force_zero_button_#{id}") {
        xml.action {
          xml.object("refid" => "${" + "force_zero_#{id}" + "}")
        }
      }
    end
  end

  def otml_prediction(pt, xml, id)
    xml.OTDataCollector("local_id" => id, "name" => "prediction") {
      xml.source { xml.OTDataGraphable("connectPoints" => "true", "controllable" => "true", "color" => "0xff0000", "drawMarks" => "false", "name" => "Prediction Graph", "xColumn" => "0", "yColumn" => "1") {
        xml.dataStore { xml.OTDataStore("local_id" => "#{id}_datastore") }
      }}
      xml.dataSetFolder { xml.OTFolderObject }
      xml.xDataAxis { xml.OTDataAxis("min" => "0", "max" => "60", "label" => "Time", "units" => "s") }
      xml.yDataAxis { xml.OTDataAxis("min" => pt.min, "max" => pt.max, "label" => pt.name, "units" => pt.unit) }
    }
  end          

  def otml_textbox(xml, id)
    xml.OTText("local_id" => id) {
        xml.text("Place answer here!")
    }
  end

  def otml_drawing(xml, id)
    xml.OTDrawingTool("name" => "Drawing", "local_id" => id)
  end

  def otml_model(model, xml, id)
    element_name = model.model_type.otrunk_object_class[/(.*\.)(.*)/, 2]
    url = ""
    if model.url
      url = process_local_url(model.url)
    end
    if model.model_type.sizeable == true
      eval_str = "xml.#{element_name}('local_id' => id, 'authoredDataURL' => url"
      if model.height
        eval_str << ", 'objectHeight' => model.height"
      end
      if model.width
        eval_str << ", 'objectWidth' => model.width"
      end
      eval_str << ")"
      eval(eval_str)
    else
      eval("xml.#{element_name}('local_id' => id, 'authoredDataURL' => url)")
    end
    if model.snapshot_active
      xml.OTSnapshotButton("local_id" => "#{id}_snapshot_button", "target" => "${#{id}}", "snapshotAlbum" => "${#{id}_snapshot_album}")    
      xml.OTSnapshotAlbum("local_id" => "#{id}_snapshot_album")
    end
  end

  def otml_object_reference(xml, id)
    xml.object("refid" => "${" + id + "}")
  end

  def otml_textbox_reference(xml, id)
    xml.div("style" => "margin: 10px 10px 10px 10px; padding: 0px 60px 10px 15px;  background-color: rgb(255, 252, 248);") {
      xml.div("style" => "") {
        xml.p { xml.object("refid" => "${" + id + "}") }
      }
    }
  end

  def otml_graph_reference(xml, value)
    graph = value[:graph]
    id = value[:id]
    type = value[:type]
    calibration = value[:calibration]
    xml.div("style" => "margin: 10px 0px 10px 0px; padding: 8px 20px 15px 20px;  background-color: rgb(255, 252, 248); border-width: 5px; border-color: silver; border-style: solid;") {
      xml.div("style" => "") {
        xml.p { 
          xml.object("refid" => "${" + id + "}")
          if graph.ptype == 5 && type == :collect # a force probe AND a data collection graph (NOT a prediction graph)
            xml.br 
            xml.table { xml.tr { xml.td { xml.object("refid" => "${" + "force_zero_button_#{id}" + "}") } } }    
          end
          if calibration
            xml.br
            xml.div("style" => "font-style: italic; font-family: Optima; color: rgb(0, 102, 0); margin: 5px 0px 0px 0px;") {
              xml.font("size" => "-1") {
                otml_content(xml, "The data from the #{graph.name} probe is displayed using the alternative calibration: #{calibration.name}.", nil)
              }
            }
          end
        }
      }
    }
  end

  def otml_drawing_reference(xml, id)
    xml.div("style" => "margin: 10px 0px 10px 0px; padding: 8px 20px 15px 20px;  background-color: rgb(255, 252, 248); border-width: 5px; border-color: silver; border-style: solid;") {
      xml.div("style" => "") {
        xml.p { xml.object("refid" => "${" + id + "}") }
      }
    }
  end

  def otml_model_reference(xml, value)
    model = value[:model]
    xml.div("style" => "margin: 10px 0px 10px 0px; padding: 8px 20px 15px 20px;  background-color: rgb(255, 252, 248); border-width: 5px; border-color: silver; border-style: solid;") {
      otml_content(xml, model.instructions, model.textile)
      if model.model_type.name == 'Molecular Workbench'
        xml.table { xml.tr { xml.td { xml.object("refid" => "${" + value[:id] + "}") } } }
      else
        xml.object("refid" => "${" + value[:id] + "}")
      end
      xml.div("style" => "font-style: italic; font-family: Optima; color: rgb(0, 102, 0); margin: 0px 10px 5px 10px;") {
        xml.font("size" => "-1") {
          otml_content(xml, model.model_type.credits, nil)
          unless model.credits.blank? || (model.model_type.authorable == nil)
            xml.br
            otml_content(xml, model.credits, nil)
          end
        }
      }
      if model.snapshot_active
        xml.table { xml.tr { 
          xml.td { xml.object("refid" => "${#{value[:id]}_snapshot_button}") }
          xml.td { xml.object("refid" => "${#{value[:id]}_snapshot_album}") }
        } }
      end
    }
  end

  def otml_content(xml, content, textile)
    if content
      if textile 
        xml << process_local_image_urls(RedCloth.new(content).to_html)
      else
        xml << content
      end
    end
  end

  def otml_content_section(xml, section_title, section_content, textile, more_objects=[])
    xml.div('style' => "margin: 10px 0px 5px 0px; padding: 8px 25px 15px 15px; background-color: rgb(255, 252, 248); font-family: Optima ExtraBlack; border-width: 1px; border-color: silver; border-style: solid; list-style-type: square;") {
      xml.h2(section_title)
      xml.div('style' => "margin: 0px 0px 0px 0px; padding: 0px 0px 4px 10px; font-family: Optima;") {
        otml_content(xml, section_content, textile)
        unless more_objects.empty?
          more_objects.each do |obj_hash|
            obj_hash.each do |key, value|
              case key
                when :textbox then otml_textbox_reference(xml, value)
                when :graph then otml_graph_reference(xml, value)
                when :drawing then otml_drawing_reference(xml, value)
                when :model then otml_model_reference(xml, value)
                when :content then otml_content(xml, value, @activity.textile)
              end
            end
          end
        end
      }
    }
  end

  def process_local_url(url)
    if request.relative_url_root == "" 
      suffix = "/" 
    else 
      suffix = request.relative_url_root + "/"
    end
    url.gsub(/^\//, "#{request.protocol}#{request.host_with_port}#{suffix}")
  end

  def process_local_image_urls(html)
    if request.relative_url_root == "" 
      suffix = "/" 
    else 
      suffix = request.relative_url_root + "/"
    end
    html.gsub("src=\"/", "src=\"#{request.protocol}#{request.host_with_port}#{suffix}")
  end

  def web_content(content, textile=@activity.textile)
    unless content.blank?
      if textile
        RedCloth.new(content).to_html.gsub("src=\"/", "src=\"#{request.relative_url_root.to_s}/")
      else
  #      content
        simple_format(content)
      end
    end
  end 

  def xhtml_errors?(content)
    errors = Array.new
    begin
      doc = REXML::Document.new("<xhtml_errors_body>#{content}</xhtml_errors_body>")
      doc.root
    rescue REXML::ParseException => e
      errors = e.to_s.split("\n")  
      errors = errors.slice(errors.index('...')+1, errors.size-1)
      errors.each {|s| s.gsub!(/<\/?xhtml_errors_body>/, '') }    
    end
    errors[0..4]
  end
  
#  require 'xml/libxml'
  
  def xhtml_errors2?(content) # uses libxml instead of rexml
    errors = Array.new
    parser = XML::Parser.new    
    parser.string = "<xhtml_errors_body>#{content}</xhtml_errors_body>"
    doc = parser.parse
    doc.find("//result/messages/msg").each do |msg|
      errors <<  "Line %i: %sn" % [msg["line"], msg]
    end
    errors
  end

  def otml_activity_preamble(xml)
    msg = ""
    if @learner
      sessions = @learner.learner_sessions.length
      if @savedata && !@nobundles # run
        msg << "Hi #{@learner.user.name}, "
        if sessions
          msg << "you have run this activity #{pluralize(sessions, 'time')}."
        else
          msg << "this is the first time you have run: #{h(@activity.name)}."
        end
      elsif !@savedata && @nobundles # preview
        msg = "You are previewing the activity: *#{h(@activity.name)}*. Saving data is disabled"
      elsif !@savedata && !@nobundles # view
        msg = "*#{@learner.user.name}* has run this activity: *#{h(@activity.name)}* #{pluralize(sessions, 'time')}.\nSaving data is disabled because you are *Viewing* (instead of Running) this activity.\n"
      elsif @savedata && @nobundles # run with no previous bundles
        msg = "Hi #{@learner.user.name}, "
        if sessions
          msg << "you have already run this activity #{pluralize(sessions, 'time')} but you are starting it from the beginning without your previous changes."
        else
          msg << "this is the first time you have run: #{h(@activity.name)}."
        end
      end
    end
    msg << "\n" + probeware_msg
    xml.div('style' => 'text-align: center; font-style: italic; font-family: Optima; color: rgb(0, 102, 0); margin-top: 0px; margin-bottom: 4px;') { 
      xml.font('size' => @savedata ? '-1' : '100%') {
        xml.span('style' => 'font-family: Futura;') {
          xml << RedCloth.new(msg).to_html
        }
      }
    }
  end

  def otml_infobar(xml)
    xml.div('style' => 'margin: 10px 0px 0px 0px; padding: 0px 0px 0px 0px; border: border-width: 5px; border-color: blue; border-style: solid;') { 
      xml.hr
      xml.div('style' => 'text-align: center; font-style: normal; font-family: Optima; color: rgb(0, 102, 0); margin: 0px 20px 0px 20px; padding: 0px 0px 0px 0px;') { 
        xml.font('size' => '-1') {
          xml << RedCloth.new("SensorPortfolio (c) 2005-2006 by the Concord Consortium, developed by the \"TEEMSS2\":http://teemss2.concord.org project.\nThis activity was created by #{@activity.user.name} using the #{link_to APP_PROPERTIES[:application_name], {:action => 'index', :only_path => false}, :title => 'tooltip test'} portal.\n" + probeware_msg).to_html
        }
      }
    }
  end
end
