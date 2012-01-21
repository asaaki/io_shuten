# encoding: utf-8
module IO_shuten
  class Base

    class NodeNotFoundError < StandardError; end
    class NodeNameError     < StandardError; end
    class FileAccessError   < StandardError; end
    class NotYetImplemented < StandardError
      def initialize callee = nil, pos = nil
        msg = if callee
          "Method :#{callee} is not (yet) supported. #{pos ? ''+pos+'' : ''}"
        else
          "The method is not (yet) supported."
        end
        super msg
      end
    end

    @@instances = []

    attr_reader  :object_name
    attr         :container, :container_size

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

      def instances
        @@instances
      end

      def purge_instances
        @@instances = []
      end

      def delete_instance object_name_or_instance
        @@instances.delete_if do |object|
          (object_name_or_instance.is_a?(Symbol) && object.object_name == object_name_or_instance) ||
          (object_name_or_instance.is_a?(String) && object.object_name == object_name_or_instance) ||
          (object_name_or_instance.is_a?(Base) && object == object_name_or_instance)
        end
      end

      def open object_name, *args
        if Base.exists? object_name
          if block_given?
            base = Base.send :load, object_name
            yield(base)
            base.close

          else
            Base.send :load, object_name
          end

        else
          raise NodeNotFoundError
        end
      end

      def exists? object_name = self.container.object_name
        false
      end
      alias_method :exist?, :exists?

    private

      def load object_name
        obj = Base.new object_name
        obj.string ""
        obj
      end
      alias_method :load_object, :load

    end

    def load_from_file
      not_yet_implemented! __method__
    end

    def save_to_file
      not_yet_implemented! __method__
    end

    def file_exists? object_name = self.container.object_name
      not_yet_implemented! __method__
    end
    alias_method :file_exist?, :file_exists?


    def respond_to? sym
      !!self.methods.include?(sym) || respond_to_missing?(sym)
    end

    def respond_to_missing? sym, include_private = true
      !!container_respond_to?(sym, include_private)
    end

    def method_missing method, *args, &block
      if respond_to_missing? method
        @container.send method, *args, &block
      end
    end

  private

    def not_yet_implemented! callee = nil, pos = nil
      raise NotYetImplemented, callee, pos
    end

    def container_respond_to? sym, include_private
      @container.respond_to? sym, include_private
    end

  end
end
