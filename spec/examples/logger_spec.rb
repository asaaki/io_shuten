# encoding: utf-8
require File.expand_path("../../spec_helper.rb", __FILE__)
require "logger"

describe "Logger" do

  it "accepts an IO_shuten::Memory as logdev" do
    logdev = IO_shuten::Memory.new(:mlogdev)
    logger = Logger.new(logdev)
    logger.info "Foo log."
    logger.info "Test message."
    logger.info "Bar log."

    logdev.string.should =~ /Test message/
  end

  it "accepts an IO_shuten::Buffer as logdev" do
    logdev = IO_shuten::Buffer.new(:blogdev)
    logger = Logger.new(logdev)
    logger.info "Foo log."
    logger.info "Test message."
    logger.info "Bar log."

    logdev.read.should =~ /Test message/
  end

  it "accepts an IO_shuten::Mongo as logdev"

  describe "accepts an IO_shuten::Redis as logdev" do
    before do
      IO_shuten::Redis.purge_instances!
      IO_shuten::Redis.redis = Redis::Namespace.new(:logging, :redis => REDIS)
      IO_shuten::Redis.redis_clear!
    end

    after do
      IO_shuten::Redis.redis_clear!
    end

    it "by using KeyValue::Single" do
      logdev = IO_shuten::Redis.new(:rlogdev_kvs, :key_value, :single)
      logger = Logger.new(logdev)
      logger.info "Foo log."
      logger.info "Test message."
      logger.info "Bar log."

      logdev.read.should =~ /Test message/
    end

    it "by using KeyValue::Collection" do
      logdev = IO_shuten::Redis.new(:rlogdev_kvc, :key_value, :collection)
      logger = Logger.new(logdev)
      logger.info "Foo log."
      logger.info "Test message."
      logger.info "Bar log."

      logdev.read.should =~ /Test message/
    end

    it "by using PubSub::Publisher"
  end

  it "accepts an IO_shuten::Zmq as logdev"

end
