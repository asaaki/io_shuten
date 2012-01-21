# encoding: utf-8
require File.expand_path("../../spec_helper.rb", __FILE__)

include IO_shuten
describe Base do

  describe "Class Methods" do

    describe :new do

      context "without object_name" do
        it "creates a new object with nil name" do
          ios = Base.new
          ios.should be_an(IO_shuten::Base)
          ios.object_name.should be_nil
        end
      end

      context "with object_name" do
        it "creates a new object with name as String" do
          object_name = "foo bar"
          ios = Base.new(object_name)
          ios.should be_an(IO_shuten::Base)
          ios.object_name.should == object_name
        end

        it "creates a new object with name as Symbol" do
          object_name = :foobar
          ios = Base.new(object_name)
          ios.should be_an(IO_shuten::Base)
          ios.object_name.should == object_name
        end
      end

    end

    describe "class based memory storage" do
      describe :purge_instances do
        it "purges all instances" do
          Base.purge_instances
          Base.instances.should have(0).items
        end
      end

      describe :instances do
        it "retrieves all @@instances" do
          Base.purge_instances
          objects = %w[first second last]
          objects.each do |object_name|
            Base.new(object_name)
          end

          Base.instances.should have(3).items
        end
      end

      describe :delete_instance do
        before do
          Base.purge_instances
          @object_names = %w[first second last]
          @objects = @object_names.inject([]) do |store, object_name|
            store << Base.new(object_name)
            store
          end
        end

        it "removes an instance by name from store" do
          Base.delete_instance(@object_names.first)
          Base.instances.should_not include(@objects.first)
        end

        it "removes an instance by object from store" do
          Base.delete_instance(@objects.first)
          Base.instances.should_not include(@objects.first)
        end

        it "removes an instance by symbolized name from store" do
          Base.purge_instances
          @object_names = %w[first second last].map(&:to_sym)
          @objects = @object_names.inject([]) do |store, object_name|
            store << Base.new(object_name)
            store
          end
          Base.delete_instance(@object_names.first)
          Base.instances.should_not include(@objects.first)
        end

      end
    end

    describe :open do

      before do
        Base.purge_instances
      end

      context "without any args" do
        it "raises ArgumentError" do
          expect { Base.open }.to raise_error(ArgumentError)
        end
      end

      context "with name only" do

        context "and object does not exist" do
          it "raises NodeNotFound error" do
            Base.stub(:exists?).and_return(false)
            expect { Base.open("foo bar") }.to raise_error(Base::NodeNotFoundError)
          end
        end

        context "and object exists" do
          it "returns the requested object" do
            object_name = "foo bar"
            object_cont = "demo content of object"
            object_mock = double(Base, :object_name => object_name, :object_content => object_cont)

            Base.should_receive(:exists?).with(object_name).and_return(true)
            Base.should_receive(:load).and_return(object_mock)

            ios = Base.open(object_name)

            ios.object_name.should == object_name
            ios.object_content.should == object_cont
          end
        end
      end

      context "with name and block" do
        it "opens object, yields the block and closes object" do

        end
      end

    end # open

    describe :close do
      it :TODO
    end

  end # Class Methods

  describe "Instance Methods" do

    describe :each do
      context "without block" do
        it "creates an Enumerable for lines"
      end

      context "with block" do
        it "iterates the lines"
      end
    end

    describe :each_line do
      it "is an alias to #each"
    end

    describe :lines do
      it "is an alias to #each"
    end

    describe :each_byte do
      context "without block" do
        it "creates an Enumerable for bytes"
      end

      context "with block" do
        it "iterates the bytes"
      end
    end

  end

end
