# encoding: utf-8
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "io_shuten"


### MONKEY PATCH raise

RUBY_ENGINE = '(no engine)' unless defined? RUBY_ENGINE

# usage: raise my_instance
#        raise :foo
#        raise anything_else_which_is_an_object
#        raise foo.bar.baz

unless RUBY_ENGINE == 'rbx' && RUBY_VERSION =~ /^1\.9\./
  class Module
    def alias_method_chain( target, feature )
      alias_method "#{target}_without_#{feature}", target
      alias_method target, "#{target}_with_#{feature}"
    end
  end

  class Object
    def raise_with_helpfulness(*args)
      raise_without_helpfulness(*args)
    rescue TypeError => e
      raise_without_helpfulness args.first.inspect if ['exception class/object expected', 'exception object expected'].include?(e.to_s)
      raise_without_helpfulness e
    end
    alias_method_chain :raise, :helpfulness
  end
end

### Custom Matchers

require 'rspec/expectations'

RSpec::Matchers.define :inherit_from do |expected|
  match do |actual|
    actual.ancestors.include?(expected)
  end
end

### Configuration

Rspec.configure do |conf|
  conf.before(:suite) do
    REDIS = Redis::Namespace.new("io_shuten/test", :redis => Redis.new) unless defined? REDIS
    IO_shuten::Redis.redis_clear!
  end
end
