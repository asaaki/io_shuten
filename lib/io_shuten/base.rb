# encoding: utf-8
module IO_shuten
  class Base

    class NodeNotFoundError < StandardError; end
    class NodeNameError < StandardError; end
    class NotImplementedYet < StandardError; end

    @@instances = []

    attr_reader  :object_name
    attr         :container, :container_size

    def initialize(object_name = nil, *args)
      if [String,Symbol,NilClass].include?(object_name.class)
        @object_name    = object_name
        @container      = StringIO.new("","w+")
        @container_size = @container.size

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

      def exists? object_name
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

    def respond_to_missing? sym, include_private = true
      unless object_respond_to?(sym, include_private)
        raise NotImplementedYet, "Method :#{sym} is not (yet) supported by #{self.class} or #{self.container.class}."
      else
        true
      end
    end

  private

    def object_respond_to? sym, include_private
      @container.respond_to? sym, include_private
    end

    def set_object_content object_content
      @container.string = object_content.to_s
      @container_size = @container.size
    end

  end
end
