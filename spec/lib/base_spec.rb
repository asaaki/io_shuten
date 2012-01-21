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

      describe :save_instances do
        it "writes all instances to disk" do
          pending
        end
      end

      describe :load_instances do
        it "loads instances from disk" do
          pending
        end
      end

    end # class based memory storage

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
            object_mock = double(Base, :object_name => object_name, :container => object_cont)

            Base.should_receive(:exists?).with(object_name).and_return(true)
            Base.should_receive(:load).and_return(object_mock)

            ios = Base.open(object_name)

            ios.object_name.should == object_name
            ios.container.should == object_cont
          end
        end
      end

      context "with name and block" do
        it "opens object, yields the block and closes object" do

        end
      end

    end # open

  end # Class Methods

  describe "Instance Methods" do

    describe "StringIO method wrapper" do
      method_list = %w[
        binmode bytes
        chars close close_read close_write closed? closed_read? closed_write? codepoints
        each each_byte each_char each_codepoint each_line
        eof eof?
        external_encoding
        fcntl fileno flush fsync
        getbyte getc gets
        internal_encoding isatty
        length lineno lineno= lines
        pid pos pos= print printf putc puts
        read read_nonblock readbyte readchar readline readlines readpartial
        reopen rewind
        seek set_encoding size string string= sync sync= sysread syswrite
        tell truncate tty?
        ungetbyte ungetc
        write write_nonblock
      ]
      method_list.each do |method_name|
        it "- responds to ##{method_name}" do
          Base.new.should respond_to(method_name)
        end
      end
    end

    describe "method stub with #not_yet_implemented! call" do
      it "raises NotYetImplemented" do
        ios = Base.new
        ios.instance_eval do
          def not_implemented_method
            not_yet_implemented! __method__, "#{__FILE__}:#{__LINE__}"
          end
        end
        expect { ios.not_implemented_method }.to raise_error(Base::NotYetImplemented)
      end
    end

    describe "loading and writing" do

      before do
        @tmp_path  = File.expand_path("../../../tmp", __FILE__)
        @root_path = File.expand_path("../../../tmp", __FILE__)
      end

      describe :load_from_file do

        context "file exists" do
          it "reads file and stores content into container"
        end

        context "file does not exist" do
          it "raises FileNotFound error"
        end

      end

      describe :save_to_file do

        context "desired path accessible" do
          context "with container name as default" do
            it "writes container into the file" do
              ios = Base.new("base.foobar.txt")
              ios.puts = "Test string"
              ios.save_to_file.should be(true)
            end
          end

          context "with custom name" do
            it "writes container into the file" do
              ios = Base.new("base.foobar.txt")
              ios.puts = "Test string"
              ios.save_to_file("base.custom_name.txt").should be(true)
            end
          end

        end

        context "path not accessible" do
          it "raises FileAccessError with corresponding reason" do
            ios = Base.new("base.foobar.txt")
            ios.puts = "Test string"
            expect { ios.save_to_file }.to raise_error(Base::FileAccessError, /reason/)
          end
        end

      end

    end # loading and writing

  end

end
