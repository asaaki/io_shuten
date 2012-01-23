# encoding: utf-8
require File.expand_path("../../../../spec_helper.rb", __FILE__)

include IO_shuten
describe Stores::Redis::PubSub do
  it { should be_a(Module) }
end
