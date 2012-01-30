# encoding: utf-8


module IO_shuten::Stores::Redis
  # Redis Backend container
  class Container
    include IO_shuten::Stores::BaseContainer

    attr_reader :redis
    attr :backend, :backend_type

    def initialize node_name, backend, type, redis_instance = nil
      @node_name = node_name
      use_backend backend
      use_type    type
      use_redis   redis_instance
    end

    def use_backend backend
      backends = {:key_value => KeyValue, :pub_sub => PubSub}
      if backends.keys.include?(backend)
        self.extend backends[backend]
        @backend = backend
      else
        raise ArgumentError, "Backend unknown. Use :key_value or :pub_sub"
      end
    end

    def use_redis redis
      @redis = redis unless redis == nil
    end

  end
end
