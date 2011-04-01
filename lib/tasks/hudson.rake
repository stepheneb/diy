namespace :hudson do

  def cuke_rep_path
    "hudson/reports/features/"
  end
  def spec_rep_path
    "hudson/reports/spec/"
  end
  def report_paths
    [cuke_rep_path,spec_rep_path]
  end

  if defined? Cucumber
    Cucumber::Rake::Task.new({:cucumber  => [:report_setup, 'db:migrate', 'db:test:prepare']}) do |t|
      t.cucumber_opts = %{--profile default  --format junit --out #{cuke_rep_path} --format html --out #{cuke_rep_path}/report.html}
    end
  end

  task :report_setup do
    report_paths.each do |path|
      rm_rf path
      mkdir_p path
    end
  end

  desc "Run the cucumber and RSpec tests, but don't fail until both suites have run."
  task :everything do
    tasks = {"cucumber" => ["hudson:cucumber"], "test" => ["hudson:spec"] }
    exceptions = []
    tasks.each do |env,tasks|
      ENV['RAILS_ENV'] = env
      tasks.each do |t|
        begin
          Rake::Task[t].invoke
        rescue => e
          exceptions << e
        end
      end
    end
    exceptions.each do |e|
      puts "Exception encountered:"
      puts "#{e}\n#{e.backtrace.join("\n")}"
    end
    raise "Test failures" if exceptions.size > 0
  end

  task :spec => ["hudson:setup:rspec", 'db:migrate', 'db:test:prepare', 'rake:spec']

  namespace :setup do
    task :pre_ci do
      ENV["CI_REPORTS"] = spec_rep_path
      gem 'ci_reporter'
      require 'ci/reporter/rake/rspec'
    end
    task :rspec => [:pre_ci, "hudson:report_setup", "ci:setup:rspec"]
  end
end
