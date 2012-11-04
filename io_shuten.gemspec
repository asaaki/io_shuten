# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "io_shuten"
  s.version = "0.1.1.dev1"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christoph Grabo"]
  s.date = "2012-11-04"
  s.description = "IO::shuten \u{2013} Use databases as IO handler like you would do with files and streams."
  s.email = ["chris@dinarrr.com"]
  s.extra_rdoc_files = [
    "LICENSE",
    "LICENSE.de",
    "README.md"
  ]
  s.files = [
    ".rspec",
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "LICENSE.de",
    "README.md",
    "Rakefile",
    "benchmark/viiite-template-redis.rb",
    "benchmark/viiite-template.rb",
    "benchmarks.sh",
    "benchmarks/buffer.rb",
    "benchmarks/memory.rb",
    "benchmarks/redis.kvc.rb",
    "benchmarks/redis.kvs.rb",
    "io_shuten.gemspec",
    "lib/io_shuten.rb",
    "lib/io_shuten/base.rb",
    "lib/io_shuten/buffer.rb",
    "lib/io_shuten/errors.rb",
    "lib/io_shuten/memory.rb",
    "lib/io_shuten/mongo.rb",
    "lib/io_shuten/redis.rb",
    "lib/io_shuten/stores.rb",
    "lib/io_shuten/stores/base_container.rb",
    "lib/io_shuten/stores/mongo.rb",
    "lib/io_shuten/stores/mongo/collection.rb",
    "lib/io_shuten/stores/mongo/gridfs.rb",
    "lib/io_shuten/stores/redis.rb",
    "lib/io_shuten/stores/redis/container.rb",
    "lib/io_shuten/stores/redis/key_value.rb",
    "lib/io_shuten/stores/redis/key_value/collection.rb",
    "lib/io_shuten/stores/redis/key_value/single.rb",
    "lib/io_shuten/stores/redis/pub_sub.rb",
    "lib/io_shuten/stores/redis/pub_sub/publisher.rb",
    "lib/io_shuten/stores/redis/pub_sub/subscriber.rb",
    "lib/io_shuten/version.rb",
    "lib/io_shuten/zmq.rb",
    "spec/examples/logger_spec.rb",
    "spec/lib/buffer_spec.rb",
    "spec/lib/memory_spec.rb",
    "spec/lib/mongo_spec.rb",
    "spec/lib/redis_spec.rb",
    "spec/lib/stores/mongo/collection_spec.rb",
    "spec/lib/stores/mongo/gridfs_spec.rb",
    "spec/lib/stores/mongo_spec.rb",
    "spec/lib/stores/redis/key_value_spec.rb",
    "spec/lib/stores/redis/pub_sub_spec.rb",
    "spec/lib/stores/redis_spec.rb",
    "spec/lib/stores_spec.rb",
    "spec/lib/zmq_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/asaaki/io_shuten"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "IO::shuten \u{2013} Use databases as IO handler. (NOT YET READY FOR PRODUCTION!)"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<iobuffer>, ["~> 1.1.2"])
      s.add_runtime_dependency(%q<hiredis>, ["~> 0.4.5"])
      s.add_runtime_dependency(%q<redis>, ["~> 3.0.2"])
      s.add_runtime_dependency(%q<redis-namespace>, ["~> 1.2.1"])
      s.add_runtime_dependency(%q<bson_ext>, ["~> 1.5.2"])
      s.add_runtime_dependency(%q<mongo>, ["~> 1.5.2"])
      s.add_runtime_dependency(%q<ffi>, ["~> 1.1.5"])
      s.add_runtime_dependency(%q<ffi-rzmq>, ["~> 0.9.6"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.11.0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<pry-doc>, [">= 0"])
      s.add_development_dependency(%q<alf>, [">= 0"])
      s.add_development_dependency(%q<fastercsv>, [">= 0"])
      s.add_development_dependency(%q<viiite>, [">= 0"])
    else
      s.add_dependency(%q<iobuffer>, ["~> 1.1.2"])
      s.add_dependency(%q<hiredis>, ["~> 0.4.5"])
      s.add_dependency(%q<redis>, ["~> 3.0.2"])
      s.add_dependency(%q<redis-namespace>, ["~> 1.2.1"])
      s.add_dependency(%q<bson_ext>, ["~> 1.5.2"])
      s.add_dependency(%q<mongo>, ["~> 1.5.2"])
      s.add_dependency(%q<ffi>, ["~> 1.1.5"])
      s.add_dependency(%q<ffi-rzmq>, ["~> 0.9.6"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.11.0"])
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<pry-doc>, [">= 0"])
      s.add_dependency(%q<alf>, [">= 0"])
      s.add_dependency(%q<fastercsv>, [">= 0"])
      s.add_dependency(%q<viiite>, [">= 0"])
    end
  else
    s.add_dependency(%q<iobuffer>, ["~> 1.1.2"])
    s.add_dependency(%q<hiredis>, ["~> 0.4.5"])
    s.add_dependency(%q<redis>, ["~> 3.0.2"])
    s.add_dependency(%q<redis-namespace>, ["~> 1.2.1"])
    s.add_dependency(%q<bson_ext>, ["~> 1.5.2"])
    s.add_dependency(%q<mongo>, ["~> 1.5.2"])
    s.add_dependency(%q<ffi>, ["~> 1.1.5"])
    s.add_dependency(%q<ffi-rzmq>, ["~> 0.9.6"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.11.0"])
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<pry-doc>, [">= 0"])
    s.add_dependency(%q<alf>, [">= 0"])
    s.add_dependency(%q<fastercsv>, [">= 0"])
    s.add_dependency(%q<viiite>, [">= 0"])
  end
end

