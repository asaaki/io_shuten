# encoding: utf-8
module IO_shuten
  class Base

    class NodeNotFound < StandardError; end

    attr_reader :object_name
    attr        :object_content, :object_content_size

    def initialize(object_name = nil, *args)
      @object_name         = object_name
      @object_content      = StringIO.new("","w+")
      @object_content_size = @object_content.size
    end

    class << self

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
          raise NodeNotFound
        end
      end

      def exists? object_name
        false
      end
      alias_method :exist?, :exists?

    private

      def load object_name
        obj = Base.new object_name
        obj.send :set_object_content, ""
        obj
      end
      alias_method :load_object, :load

    end

    def close
    end

    def read
    end

    def each
    end
    alias_method :each_line, :each
    alias_method :lines,     :each

    def write str
      @object_content.puts str.to_s
    end

  private

    def set_object_content object_content
      @object_content.string = object_content.to_s
      @object_content_size = @object_content.size
    end

    def get_object_content
      @object_content.string
    end

  end
end
