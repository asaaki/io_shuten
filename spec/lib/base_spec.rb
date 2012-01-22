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

        it "raises NodeNameError if wrong type" do
          object_name = 1.23
          expect { Base.new(object_name) }.to raise_error(Errors::NodeNameError)
        end

        it "raises NodeExistsError if object name is already taken" do
          object_name = :already_taken
          expect { Base.new(object_name) }.to_not raise_error
          expect { Base.new(object_name) }.to raise_error(Errors::NodeExistsError)
        end
      end

    end

    describe "class based memory storage" do
      describe :purge_instances! do
        it "purges all instances" do
          Base.purge_instances!
          Base.instances.should have(0).items
        end
      end

      describe :instances do
        it "retrieves all @@instances" do
          Base.purge_instances!
          objects = %w[first second last]
          objects.each do |object_name|
            Base.new(object_name)
          end

          Base.instances.should have(3).items
        end
      end

      describe :delete_instance do
        before do
          Base.purge_instances!
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
          Base.purge_instances!
          @object_names = %w[first second last].map(&:to_sym)
          @objects = @object_names.inject([]) do |store, object_name|
            store << Base.new(object_name)
            store
          end
          Base.delete_instance(@object_names.first)
          Base.instances.should_not include(@objects.first)
        end

      end

      describe "batch tasks" do

        before do
          Base.purge_instances!

          @tmp_path  = File.expand_path("../../../tmp", __FILE__)

          Dir.mkdir(@tmp_path) unless File.exists?(@tmp_path)

          example_content = "This is a dummy file!"

          @file_names = %w[file1 file2 file3]

          @file_names.each do |file_name|
            File.open("#{@tmp_path}/#{file_name}",'w') do |fh|
              fh.puts example_content
            end
          end
        end

        after do
          @file_names.each do |file_name|
            File.unlink("#{@tmp_path}/#{file_name}") if File.exists?("#{@tmp_path}/#{file_name}")
          end
          Base.purge_instances!
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

      end


    end # class based memory storage

    describe :open do

      before do
        Base.purge_instances!
      end

      context "without any args" do
        it "raises ArgumentError" do
          expect { Base.open }.to raise_error(::ArgumentError)
        end
      end

      context "with name only" do

        context "and object does not exist" do
          it "raises NodeNotFound error" do
            expect { Base.open("foo bar") }.to raise_error(Errors::NodeNotFoundError)
          end
        end

        context "and object exists" do
          it "returns the requested object" do
            object_name = "foo bar"
            stored_obj  = Base.new(object_name)

            ios = Base.open(object_name)
            ios.should === stored_obj
          end
        end
      end

      context "with name and block" do
        it "opens object, yields the block and closes object for writing" do
          str      = "string set in block"
          origin   = Base.new(:blocktest)

          open_obj = Base.open :blocktest do |handle|
            handle.write str
          end

          open_obj.should      === origin
          origin.string.should === str
          origin.should        be_closed_write
          origin.should_not    be_closed_read
          expect { origin.write 'foo' }.to raise_error(IOError)
        end
      end

    end # open

  end # Class Methods

  describe "Instance Methods" do

    describe "StringIO method wrapper" do
      m18 = %w[
        binmode bytes
        chars close close_read close_write closed? closed_read? closed_write?
        each each_byte each_char each_line
        eof eof?
        fcntl fileno flush fsync
        getbyte getc gets
        isatty
        length lineno lineno= lines
        pid pos pos= print printf putc puts
        read readbyte readchar readline readlines
        reopen rewind
        seek size string string= sync sync= sysread syswrite
        tell truncate tty?
        ungetc
        write
      ]
      m19 = %w[
        codepoints
        each_codepoint
        external_encoding
        internal_encoding
        read_nonblock
        readpartial
        set_encoding
        ungetbyte
        write_nonblock
      ]
      method_list = RUBY_VERSION =~ /^1\.8\./ ? m18 : (m18 + m19)
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
          def not_implemented_method_a
            not_yet_implemented!
          end
          def not_implemented_method_b
            not_yet_implemented! __method__, "#{__FILE__}:#{__LINE__}"
          end
        end
        expect { ios.not_implemented_method_a }.to raise_error(Errors::NotYetImplemented)
        expect { ios.not_implemented_method_b }.to raise_error(Errors::NotYetImplemented)
      end
    end

    describe "loading and writing" do

      before do
        @tmp_path  = File.expand_path("../../../tmp", __FILE__)
        @tmp_true_file  = "#{@tmp_path}/base.exist_true.txt"
        @tmp_save_file  = "#{@tmp_path}/base.save_true.txt"
        @tmp_false_file = "#{@tmp_path}/base.exist_false.txt"
        @denied_path    = "/invalid_file.txt"

        Dir.mkdir(@tmp_path) unless File.exists?(@tmp_path)
        f = File.new(@tmp_true_file,'w')
        f.puts("true content")
        f.close
      end

      after do
        File.unlink(@tmp_true_file)
        File.unlink(@tmp_save_file) if File.exists?(@tmp_save_file)
        Base.purge_instances!
      end

      describe :file_exists? do

        it "returns true if path is a file" do
          ios = Base.new(@tmp_true_file)
          ios.file_exists?.should be_true
        end

        it "returns true if custom path is a file" do
          ios = Base.new(:different_name)
          ios.file_exists?(@tmp_true_file).should be_true
        end

        it "returns false if path is not a file" do
          ios = Base.new(@tmp_false_file)
          ios.file_exists?.should be_false
        end

      end

      describe :load_from_file do

        context "file exists" do

          it "reads file and stores content into container" do
            ios = Base.new(@tmp_true_file)
            ios.load_from_file.should be_true
            ios.string.should =~ /true content/
          end

          it "reads file with custom name" do
            ios = Base.new(:different_name)
            ios.load_from_file(@tmp_true_file).should be_true
            ios.string.should =~ /content/
          end

        end

        context "file does not exist" do
          it "raises FileNotFoundError" do
            ios = Base.new(@tmp_false_file)
            expect { ios.load_from_file }.to raise_error(Errors::FileNotFoundError)
          end
        end

      end

      describe :save_to_file do

        context "file path accessible" do
          context "with container name as default" do
            it "writes container into the file" do
              ios = Base.new(@tmp_save_file)
              ios.puts = "Test string"
              ios.save_to_file.should be_true
            end
          end

          context "with custom name" do
            it "writes container into the file" do
              ios = Base.new(:different_name)
              ios.puts = "Test string"
              ios.save_to_file(@tmp_save_file).should be_true
            end
          end

        end

        context "path not accessible" do
          it "raises FileAccessError with corresponding reason" do
            ios = Base.new(@denied_path)
            ios.puts = "Test string"
            expect { ios.save_to_file }.to raise_error(Errors::FileAccessError, /Reason/)
          end
        end

      end

    end # loading and writing

  end

end
