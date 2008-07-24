# Include hook code here

require 'query_reviewer'
if ActiveRecord::ConnectionAdapters.const_defined? :MysqlAdapter
  ActiveRecord::ConnectionAdapters::MysqlAdapter.send(:include, QueryReviewer::MysqlAdapterExtensions)
end

ActionController::Base.send(:include, QueryReviewer::ControllerExtensions)
Array.send(:include, QueryReviewer::ArrayExtensions)