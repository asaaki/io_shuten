# encoding: utf-8
require File.expand_path("../../spec_helper.rb", __FILE__)

include IO_shuten
describe Memory do

  describe "Class Methods" do

    describe :new do

      context "without node_name" do
        it "raises Errors::NodeNameError" do
          expect { Memory.new }.to raise_error(Errors::NodeNameError)
        end
      end

      context "with node_name" do
        it "creates a new node with name as String" do
          node_name = "foo bar"
          ios = Memory.new(node_name)
          ios.should be_an(IO_shuten::Memory)
          ios.node_name.should == node_name
        end

        it "creates a new node with name as Symbol" do
          node_name = :foobar
          ios = Memory.new(node_name)
          ios.should be_an(IO_shuten::Memory)
          ios.node_name.should == node_name
        end

        it "raises NodeNameError if wrong type" do
          node_name = 1.23
          expect { Memory.new(node_name) }.to raise_error(Errors::NodeNameError)
        end

        it "raises NodeExistsError if node name is already taken" do
          node_name = :already_taken
          expect { Memory.new(node_name) }.to_not raise_error
          expect { Memory.new(node_name) }.to raise_error(Errors::NodeExistsError)
        end
      end

    end

    describe "class based memory storage" do
      describe :purge_instances! do
        it "purges all instances" do
          Memory.purge_instances!
          Memory.instances.should have(0).items
        end
      end

      describe :instances do
        it "retrieves all @@instances" do
          Memory.purge_instances!
          nodes = %w[first second last]
          nodes.each do |node_name|
            Memory.new(node_name)
          end

          Memory.instances.should have(3).items
        end
      end

      describe :delete_instance do
        before do
          Memory.purge_instances!
          @node_names = %w[first second last]
          @nodes = @node_names.inject([]) do |store, node_name|
            store << Memory.new(node_name)
            store
          end
        end

        it "removes an node by name from store" do
          Memory.delete_instance(@node_names.first)
          Memory.instances.should_not include(@nodes.first)
        end

        it "removes an node by instance from store" do
          Memory.delete_instance(@nodes.first)
          Memory.instances.should_not include(@nodes.first)
        end

        it "removes an node by symbolized name from store" do
          Memory.purge_instances!
          @node_names = %w[first second last].map(&:to_sym)
          @nodes = @node_names.inject([]) do |store, node_name|
            store << Memory.new(node_name)
            store
          end
          Memory.delete_instance(@node_names.first)
          Memory.instances.should_not include(@nodes.first)
        end

      end

      describe "batch tasks" do

        before do
          Memory.purge_instances!

          @tmp_path  = File.expand_path("../../../tmp", __FILE__)

          Dir.mkdir(@tmp_path) unless File.exists?(@tmp_path)

          @example_content = "This is a dummy file!"

          @file_names = %w[file1 file2 file3]

          @file_names.each do |file_name|
            File.open("#{@tmp_path}/#{file_name}",'w') do |fh|
              fh.puts file_name
              fh.puts @example_content
            end
          end
        end

        after do
          @file_names.each do |file_name|
            File.unlink("#{@tmp_path}/#{file_name}") if File.exists?("#{@tmp_path}/#{file_name}")
          end
          Memory.purge_instances!
        end

        describe :save_instances do
          before do
            @file_names2 = %w[file4 file5 file6]
          end

          after do
            @file_names2.each do |file_name|
              File.unlink("#{@tmp_path}/#{file_name}") if File.exists?("#{@tmp_path}/#{file_name}")
            end
          end

          it "writes all instances to disk" do
            @file_names2.each do |file_name|
              node = Memory.new("#{@tmp_path}/#{file_name}")
              node.puts "content of file: #{file_name}"
            end

            Memory.save_instances.should be_true
          end
        end

        describe :load_instances do
          it "loads an array of files" do
            absolute_files = @file_names.inject([]) do |store, file_name|
              store << "#{@tmp_path}/#{file_name}"
            end
            Memory.load_instances absolute_files
            Memory.pool.should have(3).items
          end

          it "loads an array of files provided by Dir.glob" do
            Memory.load_instances Dir.glob(@tmp_path+"/**/*")
            Memory.pool.should have(3).items
          end

          it "loads files from a directory name (String)" do
            Memory.load_instances @tmp_path
            Memory.pool.should have(3).items
          end
        end

      end


    end # class based memory storage

    describe :open do

      before do
        Memory.purge_instances!
      end

      context "without any args" do
        it "raises ArgumentError" do
          expect { Memory.open }.to raise_error(::ArgumentError)
        end
      end

      context "with name only" do

        context "and node does not exist" do
          it "raises NodeNotFound error" do
            expect { Memory.open("foo bar") }.to raise_error(Errors::NodeNotFoundError)
          end
        end

        context "and node exists" do
          it "returns the requested node" do
            node_name = "foo bar"
            stored_obj  = Memory.new(node_name)

            ios = Memory.open(node_name)
            ios.should === stored_obj
          end

          it "always reopens node for writing (and reading)" do
            node_name = :always_reopenable
            node = Memory.new(node_name)
            node.close

            node.should be_closed
            Memory.open(node_name).should_not be_closed
          end
        end
      end

      context "with name and block" do
        it "opens node, yields the block and closes node for writing" do
          str      = "string set in block"
          origin   = Memory.new(:blocktest)

          open_obj = Memory.open :blocktest do |handle|
            handle.write str
          end

          open_obj.should      === origin
          origin.string.should === str
          origin.should        be_closed_write
          origin.should_not    be_closed_read
          expect { origin.write 'foo' }.to raise_error(IOError)
        end

        it "can reopen an node for manipulation" do
          str       = "string set in block"
          other_str = "new string"
          origin    = Memory.new(:blocktest)

          Memory.open :blocktest do |handle|
            handle.write str
          end

          expect do
            Memory.open :blocktest do |handle|
              handle.puts other_str
            end
          end.to_not raise_error
          Memory.open(:blocktest).string.should match(other_str)
        end
      end

    end # open

  end # Class Methods

  describe "Instance Methods" do

    before do
      Memory.purge_instances!
    end

    describe "StringIO method wrapper (for: #{RUBY_VERSION})" do
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
      m19_additionals = %w[
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
      method_list = RUBY_VERSION =~ /^1\.8\./ ? m18 : (m18 + m19_additionals)

      method_list.each do |method_name|
        it "- responds to ##{method_name}" do
          Memory.new(:string_io_test).should respond_to(method_name)
        end
      end
    end

    describe "method stub with #not_yet_implemented! call" do
      it "raises NotYetImplemented" do
        ios = Memory.new(:not_implemented)
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
        expect { ios.not_implemented_method_c }.to raise_error(Errors::NotYetImplemented)
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
        f.puts "true content"
        f.close
      end

      after do
        File.unlink(@tmp_true_file)
        File.unlink(@tmp_save_file) if File.exists?(@tmp_save_file)
        Memory.purge_instances!
      end

      describe :file_exists? do

        it "returns true if path is a file" do
          ios = Memory.new(@tmp_true_file)
          ios.file_exists?.should be_true
        end

        it "returns true if custom path is a file" do
          ios = Memory.new(:different_name)
          ios.file_exists?(@tmp_true_file).should be_true
        end

        it "returns false if path is not a file" do
          ios = Memory.new(@tmp_false_file)
          ios.file_exists?.should be_false
        end

      end

      describe :load_from_file do

        context "file exists" do

          it "reads file and stores content into container" do
            ios = Memory.new(@tmp_true_file)
            ios.load_from_file.should be_true
            ios.string.should =~ /true content/
          end

          it "reads file with custom name" do
            ios = Memory.new(:different_name)
            ios.load_from_file(@tmp_true_file).should be_true
            ios.string.should =~ /content/
          end

        end

        context "file does not exist" do
          it "raises FileNotFoundError" do
            ios = Memory.new(@tmp_false_file)
            expect { ios.load_from_file }.to raise_error(Errors::FileNotFoundError)
          end
        end

      end

      describe :save_to_file do

        context "file path accessible" do
          context "with container name as default" do
            it "writes container into the file" do
              ios = Memory.new(@tmp_save_file)
              ios.puts "Test string"
              ios.save_to_file.should be_true
            end
          end

          context "with custom name" do
            it "writes container into the file" do
              ios = Memory.new(:different_name)
              ios.puts "Test string"
              ios.save_to_file(@tmp_save_file).should be_true
            end
          end

        end

        context "path not accessible" do
          it "raises FileAccessError with corresponding reason" do
            ios = Memory.new(@denied_path)
            ios.puts "Test string"
            expect { ios.save_to_file }.to raise_error(Errors::FileAccessError, /Reason/)
          end
        end

      end

    end # loading and writing

  end

end
