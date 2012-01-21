# encoding: utf-8

module IO_shuten
  # IO_shuten::Base is the in-memory implementation and parent class for other implementations.
  class Base

    # Exception if a node object was not found
    class NodeNotFoundError < StandardError; end
    # Exception if the node object name was of wrong type
    class NodeNameError     < StandardError; end
    # Exception if file was not found
    class FileNotFoundError < StandardError; end
    # Exception if something went wrong on file handling
    class FileAccessError   < StandardError; end
    # Exception for not yet implemented methods (stubs)
    class NotYetImplemented < StandardError
      # @private
      def initialize callee = nil, pos = nil
        msg = if callee
          "Method :#{callee} is not (yet) supported. #{pos ? ''+pos+'' : ''}"
        else
          "The method is not (yet) supported."
        end
        super msg
      end
    end

    # Storage of current Base instances of the running process
    # @return [Array]
    @@instances = []

    # Name of current node instance
    # @return [String]
    attr_reader :object_name

    # holds StringIO object
    # @return [StringIO]
    attr :container

    # Creates a new Base object and stores it in the pool
    #
    # @param [String] object_name Name of the node object (container)
    # @param [Symbol] object_name also a symbol is allowed
    # @param *args (not used)
    # @return [Base]
    # @raise [NodeNameError]
    def initialize(object_name = nil, *args)
      if [String,Symbol,NilClass].include?(object_name.class)
        @object_name    = object_name
        @container      = StringIO.new("","w+")

        @@instances << self unless @@instances.include?(self)
      else
        raise NodeNameError, "Name must be kind of String or Symbol."
      end
    end

    class << self

      # @return [Array] current instances
      def instances
        @@instances
      end

      # Deletes ALL instances in the pool!
      #
      # @return [Boolean]
      def purge_instances!
        @@instances = []
        true
      end

      # Deletes a single instance of the pool
      #
      # @param [Base] object
      # @param [String] name of object as String
      # @param [Symbol] name of object as Symbol
      def delete_instance object_name_or_instance
        @@instances.delete_if do |object|
          (object_name_or_instance.is_a?(Symbol) && object.object_name == object_name_or_instance) ||
          (object_name_or_instance.is_a?(String) && object.object_name == object_name_or_instance) ||
          (object_name_or_instance.is_a?(Base) && object == object_name_or_instance)
        end
      end

      # @return [Base] itself on success if no block was given
      # @return [Boolean] true on success if block was given
      # @raise [NodeNotFoundError]
      def open object_name, *args
        if Base.exists? object_name
          if block_given?
            base = Base.send :load, object_name
            yield(base)
            base.close
            true

          else
            Base.send :load, object_name
          end

        else
          raise NodeNotFoundError
        end
      end

      # @return [Boolean]
      def exists? o_name = nil
        o_name ||= self.object_name
        false
      end
      alias_method :exist?, :exists?

    private

      # @private
      def load object_name
        obj = Base.new object_name
        obj.string ""
        obj
      end
      alias_method :load_object, :load

    end

    ### instance methods

    # @return [Base] itself on success
    # @raise [FileNotFoundError]
    def load_from_file file_name = nil
      file_name ||= self.object_name
      if file_exists? file_name
        self.container.string = File.read(file_name)
        self
      else
        raise FileNotFoundError, self.object_name
      end
    end

    # @return [Base] itself on success
    # @raise [FileAccessError]
    def save_to_file file_name = nil
      file_name ||= self.object_name
      begin
        File.open(file_name, 'w') do |fh|
          fh.write(self.container.string)
        end
        self
      rescue Exception => e
        raise FileAccessError, "Reason: #{e.message}"
      end
    end

    # @return [Boolean]
    def file_exists? file_name = nil
      file_name ||= self.object_name
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
      end
    end

  private

    # @private
    def not_yet_implemented! callee = nil, pos = nil
      raise NotYetImplemented, callee, pos
    end

    # @private
    def container_respond_to? sym, include_private
      @container.respond_to? sym, include_private
    end

  end
end
