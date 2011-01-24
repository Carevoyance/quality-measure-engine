require 'rspec/core/rake_task'
require 'jeweler'
require 'yard'
require 'metric_fu'

ENV['MEASURE_DIR'] = File.join('fixtures', 'measure_defs')

Dir['lib/tasks/*.rake'].sort.each do |ext|
  load ext
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

Jeweler::Tasks.new do |gem|
  gem.name = "quality-measure-engine"
  gem.summary = "A library for extracting quality measure information from HITSP C32's and ASTM CCR's"
  gem.description = "A library for extracting quality measure information from HITSP C32's and ASTM CCR's"
  gem.email = "talk@projectpophealth.org"
  gem.homepage = "http://github.com/pophealth/quality-measure-engine"
  gem.authors = ["Marc Hadley", "Andy Gregorowicz"]
  
  gem.add_dependency 'mongo', '~> 1.1'
  
  gem.add_development_dependency "jsonschema", "~> 2.0.0"
  gem.add_development_dependency "rspec", "~> 2.0.0"
  gem.add_development_dependency "awesome_print", "~> 0.2.1"
  gem.add_development_dependency "jeweler", "~> 1.4.0"
  
  gem.files = Dir.glob('lib/**/*.rb') + Dir.glob('lib/**/*.rake') + Dir.glob(File.join(ENV['MEASURE_DIR'], '**', '*.js*')) +
              Dir.glob('js/**/*.js*') + ["Gemfile", "Gemfile.lock", "README.md", "Rakefile", "VERSION"]
  
  gem.test_files = []
end

YARD::Rake::YardocTask.new

namespace :cover_me do
  
  task :report do
    require 'cover_me'
    CoverMe.complete!
  end
  
end

task :coverage do
  Rake::Task['spec'].invoke
  Rake::Task['cover_me:report'].invoke
end

MetricFu::Configuration.run do |config|
    #define which metrics you want to use
    config.metrics  = [:roodi, :reek, :churn, :flog, :flay]
    config.graphs   = [:flog, :flay]
    config.flay ={:dirs_to_flay => []} #Flay doesn't seem to be handling CLI arguments well... so this config squashes them
end