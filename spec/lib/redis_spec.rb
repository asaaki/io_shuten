# encoding: utf-8
require File.expand_path("../../spec_helper.rb", __FILE__)

include IO_shuten
describe Redis do
  it { IO_shuten::Redis.should inherit_from(IO_shuten::Base) }
end
