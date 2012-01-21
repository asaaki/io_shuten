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
        it "creates a new object with given name" do
          object_name = "foo bar"
          ios = Base.new(object_name)
          ios.should be_an(IO_shuten::Base)
          ios.object_name.should == object_name
        end
      end

    end

    describe :open do

      context "without any args" do
        it "raises ArgumentError" do
          expect { Base.open }.to raise_error(ArgumentError)
        end
      end

      context "with name only" do

        context "and object does not exist" do
          it "raises NodeNotFound error" do
            Base.stub(:exists?).and_return(false)
            expect { Base.open("foo bar") }.to raise_error(Base::NodeNotFound)
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
