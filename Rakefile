# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

begin
  require "bundler"
  Bundler.setup
rescue LoadError
  $stderr.puts "You need to have Bundler installed to be able build this gem."
end

require "io_shuten/version"
require 'rubygems'
require 'rubygems/package_task'

spec = Gem::Specification.new do |s|
  s.name        = "io_shuten"
  s.version     = IO_shuten::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Christoph Grabo"]
  s.email       = ["chris@dinarrr.com"]
  s.homepage    = "http://github.com/asaaki/io_shuten"
  s.summary     = "IO::shuten – Use databases as IO handler."
  s.description = "IO::shuten – Use databases as IO handler like you would do with files and streams."

  s.required_rubygems_version = ">= 1.3.7"
  s.rubyforge_project         = "IO_shuten"

  s.add_development_dependency "rspec"

  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.md)
  s.executables  = []
  s.require_path = 'lib'
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Release (push) gem to rubygems.org"
task :release => :gem do
  system "gem push io_shuten-#{IO_shuten::VERSION}"
end


