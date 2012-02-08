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
        ior.backend_spec.should == [:key_value,:single]
      end

      it "creates a node with KeyValue as :collection" do
        ior = IOR.new(:test, :key_value, :collection)
        ior.backend_spec.should == [:key_value,:collection]
      end

      it "creates a node with PubSub as :publisher" do
        ior = IOR.new(:test, :pub_sub, :publisher)
        ior.backend_spec.should == [:pub_sub,:publisher]
      end

      it "creates a node with PubSub as :subscriber" do
        ior = IOR.new(:test, :pub_sub, :subscriber)
        ior.backend_spec.should == [:pub_sub,:subscriber]
      end

      it "fails, if backend is not known" do
        expect { IOR.new(:will_fail, :unknown_backend, :unknown_type) }.to raise_error(ArgumentError)
      end

      it "fails, if type is not known" do
        expect { IOR.new(:will_fail, :key_value, :unknown_type) }.to raise_error(ArgumentError)
        expect { IOR.new(:will_fail, :pub_sub, :unknown_type) }.to raise_error(ArgumentError)
      end

      it "fails if node already exists" do
        IOR.new(:should_fail, :key_value, :single)
        expect { IOR.new(:should_fail, :key_value, :single) }.to raise_error(Errors::NodeExistsError)
      end

      it "fails if node name is of wrong type" do
        expect { IOR.new(1.23, :key_value, :single) }.to raise_error(Errors::NodeNameError)
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
            ior.clear!
            data.each{ |line| ior.write line }

            IOR.redis.lrange(:kvs_test_write,0,-1).should == data
          end

          it "reads data" do
            data = %w[first_entry more_data last_entry]
            ior = IOR.new(:kvs_test_read, :key_value, :single)
            ior.clear!
            data.each{ |line| ior.write line }

            ior.read.should == data.join
          end

        end

        describe "Collection type" do

          it "writes data" do
            data = %w[first_entry more_data last_entry]
            ior = IOR.new(:kvc_test_write, :key_value, :collection)
            ior.clear!
            data.each{ |line| ior.write line }

            keys = IOR.redis.keys("kvc_test_write:*").sort
            res = keys.inject([]){|m,k| m << IOR.redis.get(k); m}

            # keep in mind: collecting all related keys include also the counter key
            res.should == [data.size.to_s] + data
          end

          it "reads data" do
            data = %w[first_entry more_data last_entry]
            ior = IOR.new(:kvc_test_read, :key_value, :collection)
            ior.clear!
            data.each{ |line| ior.write line }

            ior.read.should == data.join
          end

        end

      end

    end

  end

end
