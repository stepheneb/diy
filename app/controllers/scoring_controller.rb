class ScoringController < ApplicationController
  layout "standard"
  
  before_filter :setup_attributes
  
  def index
    @ignore_concord = params[:ignore_concord]
    @ignore_private = params[:ignore_private]
    @ignore_original = params[:ignore_original]
    @ignore_copies = params[:ignore_copies]
    if request.post?
      require 'spreadsheet/excel'

      file = "#{RAILS_ROOT}/tmp/xls/activities.xls"
      f = File.new(file, "w")
      f.write("")
      f.close
          
      workbook = Spreadsheet::Excel.new(file)
      
      score_sheet = workbook.add_worksheet("Scores")
      reason_sheet = workbook.add_worksheet("Reasons")
      
      format = workbook.add_format(:text_h_align=>1)
      
      score_sheet.format_column(0, 4, format)   # ID
      score_sheet.format_column(1, 5, format)   # Score
      score_sheet.format_column(2, 8, format)   # Copy
      score_sheet.format_column(3, 8, format)   # Parent ID
      score_sheet.format_column(4, 8, format)   # Public
      score_sheet.format_column(5, 4, format)   # L 1M
      score_sheet.format_column(6, 4, format)   # S 1M
      score_sheet.format_column(7, 4, format)   # L 3M
      score_sheet.format_column(8, 4, format)   # S 3M
      score_sheet.format_column(9, 4, format)   # L 6M
      score_sheet.format_column(10, 4, format)  # S 6M
      score_sheet.format_column(11, 4, format)  # L T
      score_sheet.format_column(12, 4, format)  # S T
      score_sheet.format_column(13, 18, format) # Author
      score_sheet.format_column(14, 45, format) # Title
      score_sheet.format_column(15, 45, format) # Compare URL
      
      reason_sheet.format_column(0, 7, format)  # ID
      reason_sheet.format_column(1, 4, format)  # Score
      reason_sheet.format_column(2, 22, format) # Section
      reason_sheet.format_column(3, 22, format) # Reason
      
      scores_row = 0
      reasons_row = 0
      
      score_sheet.write(scores_row, 0, ["ID", "Score", "Copy?", "Parent ID", "Public?", "L 1M", "S 1M", "L 3M", "S 3M", "L 6M","S 6M", "L T", "S T", "Author", "Title", "Compare Link"])
      reason_sheet.write(reasons_row, 0, ["ID", "Score", "Section", "Reason"])
      delta = 1
      
      Activity.find(:all).each do |a|
        next if (@ignore_private && (! a.public?))
        next if (@ignore_concord && (a.user.email =~ /concord\.org/))
        next if (@ignore_original && (! a.parent_id))
        next if (@ignore_copies && (a.parent_id))
        score = a.score(@rubric)
        row = []
        row << a.id
        row << score[:sum]
        row << (a.parent_id ? "copy" : "original")
        row << (a.parent_id ? a.parent_id : "none")
        row << (a.public ? "public" : "private")
        # usage statistics
        usage = a.gen_usage_hash
        row << usage[:one_month_learners]
        row << usage[:one_month_sessions]
        row << usage[:three_month_learners]
        row << usage[:three_month_sessions]
        row << usage[:six_month_learners]
        row << usage[:six_month_sessions]
        row << usage[:total_learners]
        row << usage[:total_sessions]
        # end usage statistics
        row << a.user.name
        row << a.name
        row << (a.parent_id ? url_for(:controller => "activities", :action => "compare", :id => a.id, :other => a.parent_id) : "n/a")
        
        score_sheet.write(scores_row += 1, 0, row)
        reason_sheet.write(reasons_row += delta, 0, [a.id, score[:reasons].collect{|r| r[:score]}, score[:reasons].collect{|r| r[:section]}, score[:reasons].collect{|r| r[:reason]}] )
        delta = score[:reasons].size
      end
      
      workbook.close
      send_data(File.open(file).read, :type => "application/vnd.ms.excel", :filename => "activities.xls" )
    else
      render
    end
  end
  
  def setup_attributes
    @attributes = Activity.new.authorable_attribute_names
    # @attributes.merge(Model.new.authorable_attributes_names)
    # @attributes.merge(ExternalOtrunkActivity.new.authorable_attribute_names)
    @attributes["Image"] = :custom
    @attributes["Link"] = :custom
    @attributes["Bullet"] = :custom
    @attributes["Numbered List"] = :custom
    
    @rubric ||= nil
    begin
      if params[:rubric]
        @rubric = params[:rubric]
      else
        @rubric = session[:rubric]
      end
    rescue NameError
      begin
        @rubric = params[:rubric]
      rescue NameError
        @rubric ||= nil
      end
    end
    if ! @rubric
      @rubric = {}
    end
    
    @rubric = Activity.new.setup_rubric(@attributes, @rubric)
    
    begin
      session[:rubric] = @rubric
    rescue NameError
      # do nothing
    end
  end
end
