# encoding: utf-8
require File.expand_path("../../spec_helper.rb", __FILE__)
require "logger"

describe "Logger" do
  it "accepts an IO_shuten::Base as logdev" do
    logdev = IO_shuten::Base.new(:logdev)
    logger = Logger.new(logdev)
    logger.info "Foo log."
    logger.info "Test message."
    logger.info "Bar log."

    logdev.string.should =~ /Test message/
  end
end
