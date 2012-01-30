# encoding: utf-8
require File.expand_path("../../spec_helper.rb", __FILE__)

include IO_shuten
describe Buffer do

  it { IO_shuten::Buffer.should inherit_from(IO_shuten::Base) }

  describe "Class Methods" do

    describe :new do

      context "without node_name" do
        it "raises Errors::NodeNameError" do
          expect { Buffer.new }.to raise_error(Errors::NodeNameError)
        end
      end

      context "with node_name" do
        it "creates a new node with name as String" do
          node_name = "foo bar"
          iob = Buffer.new(node_name)
          iob.should be_an(IO_shuten::Buffer)
          iob.node_name.should == node_name
        end

        it "creates a new node with name as Symbol" do
          node_name = :foobar
          iob = Buffer.new(node_name)
          iob.should be_an(IO_shuten::Buffer)
          iob.node_name.should == node_name
        end

        it "raises NodeNameError if wrong type" do
          node_name = 1.23
          expect { Buffer.new(node_name) }.to raise_error(Errors::NodeNameError)
        end

        it "raises NodeExistsError if node name is already taken" do
          node_name = :already_taken
          expect { Buffer.new(node_name) }.to_not raise_error
          expect { Buffer.new(node_name) }.to raise_error(Errors::NodeExistsError)
        end
      end

    end

    describe "class based Buffer storage" do
      describe :purge_instances! do
        it "purges all instances" do
          Buffer.purge_instances!
          Buffer.instances.should have(0).items
        end
      end

      describe :instances do
        it "retrieves all @@instances" do
          Buffer.purge_instances!
          nodes = %w[first second last]
          nodes.each do |node_name|
            Buffer.new(node_name)
          end

          Buffer.instances.should have(3).items
        end
      end

      describe :delete_instance do
        before do
          Buffer.purge_instances!
          @node_names = %w[first second last]
          @nodes = @node_names.inject([]) do |store, node_name|
            store << Buffer.new(node_name)
            store
          end
        end

        it "removes an node by name from store" do
          Buffer.delete_instance(@node_names.first)
          Buffer.instances.should_not include(@nodes.first)
        end

        it "removes an node by instance from store" do
          Buffer.delete_instance(@nodes.first)
          Buffer.instances.should_not include(@nodes.first)
        end

        it "removes an node by symbolized name from store" do
          Buffer.purge_instances!
          @node_names = %w[first second last].map(&:to_sym)
          @nodes = @node_names.inject([]) do |store, node_name|
            store << Buffer.new(node_name)
            store
          end
          Buffer.delete_instance(@node_names.first)
          Buffer.instances.should_not include(@nodes.first)
        end

      end

      describe "batch tasks" do

        before do
          Buffer.purge_instances!

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
          Buffer.purge_instances!
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
              node = Buffer.new("#{@tmp_path}/#{file_name}")
              node.<< "content of file: #{file_name}"
            end

            Buffer.save_instances.should be_true
          end
        end

        describe :load_instances do
          it "loads an array of files" do
            absolute_files = @file_names.inject([]) do |store, file_name|
              store << "#{@tmp_path}/#{file_name}"
            end
            Buffer.load_instances absolute_files
            Buffer.pool.should have(3).items
          end

          it "loads an array of files provided by Dir.glob" do
            Buffer.load_instances Dir.glob(@tmp_path+"/**/*")
            Buffer.pool.should have(3).items
          end

          it "loads files from a directory name (String)" do
            Buffer.load_instances @tmp_path
            Buffer.pool.should have(3).items
          end
        end

      end


    end # class based Buffer storage

    describe :open do

      before do
        Buffer.purge_instances!
      end

      context "without any args" do
        it "raises ArgumentError" do
          expect { Buffer.open }.to raise_error(::ArgumentError)
        end
      end

      context "with name only" do

        context "and node does not exist" do
          it "raises NodeNotFound error" do
            expect { Buffer.open("foo bar") }.to raise_error(Errors::NodeNotFoundError)
          end
        end

        context "and node exists" do
          it "returns the requested node" do
            node_name = "foo bar"
            stored_obj  = Buffer.new(node_name)

            iob = Buffer.open(node_name)
            iob.should === stored_obj
          end

        end
      end

      context "with name and block" do

        it "opens node and yields the block" do
          str      = "string set in block"
          origin   = Buffer.new(:blocktest)

          open_obj = Buffer.open :blocktest do |handle|
            handle.write str
          end

          open_obj.should    === origin
          origin.read.should === str
        end

        it "can reopen an node for manipulation" do
          str       = "string set in block"
          other_str = "new string"
          origin    = Buffer.new(:blocktest)

          Buffer.open :blocktest do |handle|
            handle.write str
          end

          expect do
            Buffer.open :blocktest do |handle|
              handle.write other_str
            end
          end.to_not raise_error
          Buffer.open(:blocktest).read.should match(other_str)
        end

      end

    end # open

  end # Class Methods

  describe "Instance Methods" do

    before do
      Buffer.purge_instances!
    end

    describe "IO::Buffer method wrapper (for: #{RUBY_VERSION})" do
      method_list = %w[
        <<
        append
        clear
        empty?
        gets
        prepend print printf putc puts
        read readline readlines read_from
        size
        write write_to
      ]

      method_list.each do |method_name|
        it "- responds to ##{method_name}" do
          Buffer.new(:string_io_test).should respond_to(method_name)
        end
      end
    end

    describe "method stub with #not_yet_implemented! call" do
      it "raises NotYetImplemented" do
        iob = Buffer.new(:not_implemented)
        iob.instance_eval do
          def not_implemented_method_a
            not_yet_implemented!
          end
          def not_implemented_method_b
            not_yet_implemented! __method__, "#{__FILE__}:#{__LINE__}"
          end
        end
        expect { iob.not_implemented_method_a }.to raise_error(Errors::NotYetImplemented)
        expect { iob.not_implemented_method_b }.to raise_error(Errors::NotYetImplemented)
        expect { iob.not_implemented_method_c }.to raise_error(Errors::NotYetImplemented)
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
        Buffer.purge_instances!
      end

      describe :file_exists? do

        it "returns true if path is a file" do
          iob = Buffer.new(@tmp_true_file)
          iob.file_exists?.should be_true
        end

        it "returns true if custom path is a file" do
          iob = Buffer.new(:different_name)
          iob.file_exists?(@tmp_true_file).should be_true
        end

        it "returns false if path is not a file" do
          iob = Buffer.new(@tmp_false_file)
          iob.file_exists?.should be_false
        end

      end

      describe :load_from_file do

        context "file exists" do

          it "reads file and stores content into container" do
            iob = Buffer.new(@tmp_true_file)
            iob.load_from_file.should be_true
            iob.read.should =~ /true content/
          end

          it "reads file with custom name" do
            iob = Buffer.new(:different_name)
            iob.load_from_file(@tmp_true_file).should be_true
            iob.read.should =~ /content/
          end

        end

        context "file does not exist" do
          it "raises FileNotFoundError" do
            iob = Buffer.new(@tmp_false_file)
            expect { iob.load_from_file }.to raise_error(Errors::FileNotFoundError)
          end
        end

      end

      describe :save_to_file do

        context "file path accessible" do
          context "with container name as default" do
            it "writes container into the file" do
              iob = Buffer.new(@tmp_save_file)
              iob.write "Test string"
              iob.save_to_file.should be_true
            end
          end

          context "with custom name" do
            it "writes container into the file" do
              iob = Buffer.new(:different_name)
              iob.write "Test string"
              iob.save_to_file(@tmp_save_file).should be_true
            end
          end

        end

        context "path not accessible" do
          it "raises FileAccessError with corresponding reason" do
            iob = Buffer.new(@denied_path)
            iob.write "Test string"
            expect { iob.save_to_file }.to raise_error(Errors::FileAccessError, /Reason/)
          end
        end

      end

    end # loading and writing

  end

end
