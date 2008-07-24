class StatisticsController < ApplicationController
  layout "standard"
  
  require 'csv'

  before_filter :define_format
  
  def define_format
    @format = params[:format]
    @format ||= "html"
    @cache_dir = "#{RAILS_ROOT}/public"
  end

  def month
    months = params[:months]
    months ||= 1
    gen_info(months.to_i)
    if @format == "csv"
      file = "#{@cache_dir}/diy-statistics-#{months.to_s}-month.csv"
      gen_csv_data(file)
      send_data(File.open(file).read, :type => "application/vnd.ms.excel", :filename => "diy-statistics-#{months.to_s}-month.csv" )
    else
      render(:template => 'statistics/stats.rhtml')
    end
    
  end

  def total
    gen_info
    if @format == "csv"
      file = "#{@cache_dir}/diy-statistics-lifetime.csv"
      gen_csv_data(file)
      send_data(File.open(file).read, :type => "application/vnd.ms.excel", :filename => "diy-statistics-lifetime.csv" )
    else
      render(:template => 'statistics/stats.rhtml')
    end
  end
  
  def authoring
    @final = {}
    render(:template => 'statistics/stats.rhtml')
  end
  
  def gen_info(time = nil)
    # FIXME 20 years ago *should* cover everything, for now
    cutoff_time = 240.month.ago
    if time
      cutoff_time = time.month.ago
    end
    # collect by activity
    temp = {}
    seenUsers = {}
    
    ## this code is very much database cpu bound
    Learner.find(:all).each do |l|
      if l.runnable
        temp[l.runnable_type] ||= []
        temp[l.runnable_type][l.runnable_id] ||= {:count => 0, :activity => l.runnable, :controller => l.runnable.class.to_s.underscore.pluralize, :session_count => 0 }
        LearnerSession.find(:all, :conditions => ['learner_id = ? AND created_at > ?', l.id, cutoff_time]).each do |s|
        # l.learner_sessions.each do |s|
        #   if cutoff_time == nil || s.created_at < cutoff_time
            if (seenUsers["#{s.learner.runnable_type}-#{s.learner.runnable_id}-#{s.learner.user_id}"] != true)
              temp[s.learner.runnable_type][s.learner.runnable_id][:count] += 1
              seenUsers["#{s.learner.runnable_type}-#{s.learner.runnable_id}-#{s.learner.user_id}"] = true
            end
            temp[s.learner.runnable_type][s.learner.runnable_id][:session_count] += 1
        #  end
        end
      end
    end
    
    # include things that have never been run
    # activities
    # acts = Activity.find(:all, :include => :learners).select{|a| a.learners.count == 0}
    # models
    # external otrunk activities
    
    # rank them by number
    # can sort by multiple columns
    sort_by = params[:sort_by]
    sort_str = 'b[:count] <=> a[:count]'
    if (sort_by == "sessions") 
      sort_str = 'b[:session_count] <=> a[:session_count]'
    end
    @final = {}
    temp.each do |k,v|
      ltemp = v.compact.sort {|a,b| eval(sort_str)  }
    @final[k] = ltemp
    end
  end
  
  def gen_csv_data(filename = "#{@cache_dir}/stats.csv")
    CSV.open("#{filename}", "w") do |workbook|
      @final.keys.sort.each do |k|
        v = @final[k]
        count = 0
        workbook << [k]
        workbook << ["Rank","# of Users","# of sessions","Activity id","Public?","Activity author","Activity title"]
        v.each do |a|
          row = []
          row << count += 1
          row << a[:count]
          row << a[:session_count]
          row << a[:activity].id
          row << a[:activity].public
          row << (a[:activity].user ? a[:activity].user.name : "unknown")
          row << a[:activity].name
          workbook << row
        end
      end
    end
  end
end
