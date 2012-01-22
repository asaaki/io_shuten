# encoding: utf-8

module IO_shuten
  # IO_shuten::Base is the in-memory implementation and parent class for other implementations.
  class Base

    # Storage of current Base instances of the running process
    # @return [Array]
    @@instances = []

    # Name of current node instance
    # @return [String]
    attr_reader :node_name

    # holds StringIO node
    # @return [StringIO]
    attr :container

    # Creates a new Base node and stores it in the pool
    #
    # @param [String] node_name Name of the node node (container)
    # @param [Symbol] node_name also a symbol is allowed
    # @param *args (not used)
    # @return [Base]
    # @raise [NodeNameError]
    def initialize(node_name = nil, *args)
      if [String, Symbol].include?(node_name.class)
        unless Base.instance_exists? node_name
        @node_name    = node_name
        @container      = StringIO.new("","w+")

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

      # @return [Array] current instances
      def instances
        @@instances
      end
      alias_method :pool,  :instances
      alias_method :nodes, :instances

      # Deletes ALL instances in the pool!
      #
      # @return [Boolean]
      def purge_instances!
        @@instances = [] and true
      end

      # Deletes a single instance of the pool
      #
      # @param [Base] node instance
      # @param [String] name of node as String
      # @param [Symbol] name of node as Symbol
      def delete_instance node_name_or_instance
        @@instances.delete_if do |node|
          (node_name_or_instance.is_a?(Symbol) && node.node_name == node_name_or_instance) ||
          (node_name_or_instance.is_a?(String) && node.node_name == node_name_or_instance) ||
          (node_name_or_instance.is_a?(Base) && node == node_name_or_instance)
        end
      end

      # Loads instances from disk
      #
      # @param [String] Directory name
      # @param [Array] File names (HINT: you can provide a Dir.glob)
      # @return [Boolean]
      def load_instances source
        case source.class.to_s
          when "Array"
            source.each do |file_name|
              node = Base.new(file_name)
              node.puts File.read(file_name)
            end
          when "String"
            if File.exists?(source) && File.directory?(source)
              Dir[source+"/**/*"].each do |file_name|
                node = Base.new(file_name)
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
        results = @@instances.inject({}) do |result, node|
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

      # Checks for existence of a node
      #
      # @param [String] name of node as String
      # @param [Symbol] name of node as Symbol
      # @return [Boolean]
      def instance_exists? node_name
        # we need to check for node_name, otherwise it will fail though node exists
        !instances.empty? && node_name && instances.map(&:node_name).include?(node_name)
      end
      alias_method :instance_exist?, :instance_exists?
      alias_method :exists?,         :instance_exists?
      alias_method :exist?,          :instance_exists?

      # @return [Base] itself on success
      # @raise [NodeNotFoundError]
      def open node_name, *args
        if Base.instance_exists? node_name
          if block_given?
            base = Base.send :load, node_name
            base.reopen(base.container.string) if base.container.closed_write?
            yield(base)
            base.container.close_write
            base

          else
            base = Base.send :load, node_name
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

    # @return [Base] itself on success
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

    # @return [Base] itself on success
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

    # @private
    def respond_to? sym
      !!self.methods.include?(sym) || respond_to_missing?(sym)
    end

    # @private
    def respond_to_missing? sym, include_private = true
      !!container_respond_to?(sym, include_private)
    end

    # @private
    def method_missing method, *args, &block
      if respond_to_missing? method
        @container.send method, *args, &block
      else
        not_yet_implemented! method
      end
    end

  private

    # @private
    def not_yet_implemented! callee = nil, pos = nil
      raise Errors::NotYetImplemented, callee, pos
    end

    # @private
    def container_respond_to? sym, include_private
      @container.respond_to? sym, include_private
    end

  end
end
