# encoding: utf-8
require File.expand_path("../../spec_helper.rb", __FILE__)

include IO_shuten
describe Mongo do
  it { IO_shuten::Mongo.should inherit_from(IO_shuten::Base) }
end
