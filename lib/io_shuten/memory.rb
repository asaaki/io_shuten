# encoding: utf-8

module IO_shuten
  # Implementation of the Memory storage
  class Memory < IO_shuten::Base

    # Creates a new Memory node and stores it in the pool
    #
    # @param [String] node_name Name of the node node (container)
    # @param [Symbol] node_name also a symbol is allowed
    # @return [Memory]
    # @raise [NodeNameError]
    def initialize(node_name = nil)
      if [String, Symbol].include?(node_name.class)
        unless Memory.instance_exists? node_name
        @node_name  = node_name
        @container  = StringIO.new("","w+")

        @@instances << self unless @@instances.include?(self)
        else
          raise Errors::NodeExistsError, "Node already in pool, replacement is not allowed."
        end
      else
        raise Errors::NodeNameError, "Name must be kind of String or Symbol and can't be nil."
      end
    end

    ### class methods

    class << self

      # Loads instances from disk
      #
      # @param [String] Directory name
      # @param [Array] File names (HINT: you can provide a Dir.glob)
      # @return [Boolean]
      def load_instances source
        case source.class.to_s
          when "Array"
            source.each do |file_name|
              node = Memory.new(file_name)
              node.puts File.read(file_name)
            end
          when "String"
            if File.exists?(source) && File.directory?(source)
              Dir[source+"/**/*"].each do |file_name|
                node = Memory.new(file_name)
                node.puts File.read(file_name)
              end
            end
          else
            raise ArgumentError, "Input must be a kind of Array or String (but was: #{source.class})."
        end
      end

      # Saves all instances to disk
      #
      # @return [Boolean]
      def save_instances
        results = instances.inject({}) do |result, node|
          File.open(node.node_name,"w") do |fh|
            fh.puts node.string
          end
          result[node.node_name] = :failed unless File.exists?(node.node_name)
        end
        if results
          false
        else
          true
        end
      end

      # @return [Memory] itself on success
      # @raise [NodeNotFoundError]
      def open node_name, *args
        if Memory.instance_exists? node_name
          if block_given?
            base = Memory.send :load, node_name
            base.reopen(base.container.string) if base.container.closed_write?
            yield(base)
            base.container.close_write
            base

          else
            base = Memory.send :load, node_name
            base.reopen(base.container.string) if base.container.closed_write?
            base
          end

        else
          raise Errors::NodeNotFoundError
        end
      end
      alias_method :open_node, :open

    private

      # @private
      def load node_name
        instances.select do |inst|
          inst.node_name == node_name
        end.first
      end
      alias_method :load_node, :load

    end

    ### instance methods

    # @return [Memory] itself on success
    # @raise [FileNotFoundError]
    def load_from_file file_name = nil
      file_name ||= self.node_name
      if file_exists? file_name
        self.container.string = File.read(file_name)
        self
      else
        raise Errors::FileNotFoundError, self.node_name
      end
    end

    # @return [Memory] itself on success
    # @raise [FileAccessError]
    def save_to_file file_name = nil
      file_name ||= self.node_name
      begin
        File.open(file_name, 'w') do |fh|
          fh.write(self.container.string)
        end
        self
      rescue Exception => e
        raise Errors::FileAccessError, "Reason: #{e.message}"
      end
    end

    # @return [Boolean]
    def file_exists? file_name = nil
      file_name ||= self.node_name
      File.exists?(file_name)
    end
    alias_method :file_exist?, :file_exists?

  end
end

