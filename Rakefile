# encoding: utf-8
require "rubygems"
require "bundler"
Bundler.setup
require "jeweler"

require "rspec"
require "rspec/core/rake_task"


$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "io_shuten/version"

RUBY_ENGINE = '(no engine)' unless defined? RUBY_ENGINE

Jeweler::Tasks.new do |gem|
  gem.name        = "io_shuten"
  gem.version     = IO_shuten::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ["Christoph Grabo"]
  gem.email       = ["chris@dinarrr.com"]
  gem.licenses    = ["MIT"]
  gem.homepage    = "http://github.com/asaaki/io_shuten"
  gem.summary     = "IO::shuten – Use databases as IO handler. (NOT YET READY FOR PRODUCTION!)"
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

desc "Starts IRB with env"
task :irb do
  sh "irb -I lib -r io_shuten"
end

desc "Starts PRY with env"
task :pry do
  sh "pry -I lib -r io_shuten --no-pager"
end

desc "Prints current environment"
task :envinfo do
  puts ['RUBY:',RUBY_PLATFORM,RUBY_ENGINE,RUBY_VERSION].join(" ")
end

desc "RBX ONLY: Clean up rbc and .rbx"
task :rbx_clean do
  Dir["./**/*.rbc","./**/.*.rbc"].each do |f|
    File.unlink f
  end
  sh "rm -rf .rbx" if File.exists?(".rbx") && File.directory?(".rbx")
end

desc "Runs complex viiite benchmark suite"
task :benchmark do
  sh "./benchmarks.sh"
end



task :default => [:envinfo,:spec]
