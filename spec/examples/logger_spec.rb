# encoding: utf-8
require File.expand_path("../../spec_helper.rb", __FILE__)
require "logger"

describe "Logger" do
  it "accepts an IO_shouten::Base as logdev" do
    logdev = IO_shuten::Base.new("logdev")
    logger = Logger.new(logdev)
  end
end
