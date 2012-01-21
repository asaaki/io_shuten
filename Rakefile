# encoding: utf-8
require "rubygems"
require "bundler"
Bundler.setup
require "jeweler"

require "rspec"
require "rspec/core/rake_task"

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "io_shuten/version"



Jeweler::Tasks.new do |gem|
  gem.name        = "io_shuten"
  gem.version     = IO_shuten::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ["Christoph Grabo"]
  gem.email       = ["chris@dinarrr.com"]
  gem.licenses    = ["MIT"]
  gem.homepage    = "http://github.com/asaaki/io_shuten"
  gem.summary     = "IO::shuten – Use databases as IO handler."
  gem.description = "IO::shuten – Use databases as IO handler like you would do with files and streams."
end



task :gem => :build

desc "Release current gem version to rubygems.org"
task "gem:release" => :gem do
  system "gem push pkg/io_shuten-#{IO_shuten::VERSION}.gem"
end

desc "A complete release cycle (build, git, gem, push to rubygems.org)"
task "full:release" => [:release,"gem:release"]

desc "Run all specs"
task RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = false
end

desc "Run all specs + code coverage"
task "spec:cov" do
  ENV["COV"] = 'true'
  Rake::Task["spec"].invoke
end



desc "Starts IRB with env"
task :irb do
  sh "irb -I lib -r io_shuten"
end

desc "Starts PRY with env"
task :pry do
  sh "pry -I lib -r io_shuten --no-pager"
end

task :default => :spec
