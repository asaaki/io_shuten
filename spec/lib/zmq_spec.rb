# encoding: utf-8
require File.expand_path("../../spec_helper.rb", __FILE__)

include IO_shuten
describe Zmq do
  it { IO_shuten::Zmq.should inherit_from(IO_shuten::Base) }
end
