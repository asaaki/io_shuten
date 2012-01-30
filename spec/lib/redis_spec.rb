# encoding: utf-8
require File.expand_path("../../spec_helper.rb", __FILE__)

IOR = IO_shuten::Redis

describe IO_shuten::Redis do
  it { IO_shuten::Redis.should inherit_from(IO_shuten::Base) }

  describe "Class Methods" do

    describe :new do

      before do
        IOR.purge_instances!
      end

      it "creates a node with KeyValue as :single" do
        ior = IOR.new(:test, :key_value, :single)
        ior.container.backend.should      == :key_value
        ior.container.backend_type.should == :single
      end

      it "creates a node with KeyValue as :collection" do
        ior = IOR.new(:test, :key_value, :collection)
        ior.container.backend.should      == :key_value
        ior.container.backend_type.should == :collection
      end

      it "creates a node with PubSub as :publisher" do
        ior = IOR.new(:test, :pub_sub, :publisher)
        ior.container.backend.should      == :pub_sub
        ior.container.backend_type.should == :publisher
      end

      it "creates a node with PubSub as :subscriber" do
        ior = IOR.new(:test, :pub_sub, :subscriber)
        ior.container.backend.should      == :pub_sub
        ior.container.backend_type.should == :subscriber
      end

      it "fails, if backend is not known" do
        expect { IOR.new(:will_fail, :unknown_backend) }.to raise_error(ArgumentError)
      end

      it "fails, if type is not known" do
        expect { IOR.new(:will_fail, :key_value, :unknown_type) }.to raise_error(ArgumentError)
      end

    end

    describe "Instance Methods" do

      before do
        IOR.purge_instances!
        IOR.redis = Redis::Namespace.new(:instances, :redis => REDIS)
      end

      after do
        IOR.redis_clear!
      end

      describe "KeyValue backend" do

        describe "Single type" do

          it "writes data" do
            data = %w[first_entry more_data last_entry]
            ior = IOR.new(:kvs_test_write, :key_value, :single)
            data.each{ |line| ior.write line }

            IOR.redis.lrange(:kvs_test_write,0,-1).should == data
          end

          it "reads data" do
            data = %w[first_entry more_data last_entry]
            ior = IOR.new(:kvs_test_read, :key_value, :single)
            data.each{ |line| ior.write line }

            ior.read.should == data.join
          end

        end

        describe "Collection type" do

          it "writes data" do
            data = %w[first_entry more_data last_entry]
            ior = IOR.new(:kvc_test_write, :key_value, :collection)
            data.each{ |line| ior.write line }

            keys = IOR.redis.keys("kvc_test_write:*").sort
            res = keys.inject([]){|m,k|m << IOR.redis.get(k); m}

            res.should == data
          end

          it "reads data" do
            data = %w[first_entry more_data last_entry]
            ior = IOR.new(:kvc_test_read, :key_value, :collection)
            data.each{ |line| ior.write line }

            ior.read.should == data.join
          end

        end

      end

    end

  end

end
