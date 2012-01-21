# encoding: utf-8
module IO_shuten
  class Base

    class NodeNotFoundError < StandardError; end
    class NodeNameError < StandardError; end
    class NotYetImplemented < StandardError; end

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

      def load_from_file
        raise_not_implemented_yet
      end

      def save_to_file
        raise_not_implemented_yet
      end

      def file_exists? object_name = self.container.object_name
        raise_not_implemented_yet
      end
      alias_method :file_exist?, :file_exists?

    private

      def load object_name
        obj = Base.new object_name
        obj.string ""
        obj
      end
      alias_method :load_object, :load

    end

    def respond_to? sym
      if self.methods.include?(sym) || respond_to_missing?(sym)
        true
      else
        raise_not_implemented_yet sym
      end
    end

    def respond_to_missing? sym, include_private = true
      if container_respond_to?(sym, include_private)
        true
      else
        raise_not_implemented_yet sym
      end
    end

    def method_missing method, *args, &block
      if respond_to_missing? method
        @container.send method, *args, &block
      end
    end

  private

    def raise_not_implemented_yet sym = __callee__
      raise NotYetImplemented, "Method :#{sym} is not (yet) supported by #{self.class} or #{self.container.class}."
    end

    def container_respond_to? sym, include_private
      @container.respond_to? sym, include_private
    end

  end
end
