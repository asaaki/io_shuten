# encoding: utf-8

require "redis"

module IO_shuten
  # Implementation of the Redis storage
  #
  # Two backends are possible: simple key-value and pub-sub messaging
  #
  # KeyValue
  # has different node types.
  # Incremental single message store: each write will create a new key.
  # Message collection store: all writes go to a single key.
  # Good for events or logs.
  #
  # PubSub
  # has different node types: publisher and subscriber.
  # In future maybe a combined publisher-subscriber type possible, but in general less needed.
  # Good for live event messaging.
  #
  # @todo Needs two backends (default database interface and pub/sub interface)!
  class Redis < IO_shuten::Base

    # Global redis client instance for the pool
    # @return [Object] Redis instance
    @@redis = ::Redis.new

    # @param [String] node_name
    # @param [Symbol] node_name
    # @param [Symbol] backend :key_value, :pub_sub
    # @param [Symbol] type for backend :key_value => [:single,:collection], for backend :pub_sub => [:publisher,:subscriber]
    # @param [Object] Redis an instance for this specific node, otherwise the Redis.redis instance will be used
    def initialize node_name, backend, type, redis_instance = nil
      # based on the backend type it should instantiate the corresponding backend store module
      node = :nil
      case backend
        when :key_value
          Stores::Redis::KeyValue #.create(type)
        when :pub_sub
          Stores::Redis::PubSub #.create(type)
        else
          raise ArgumentError, "Backend type unknown. Use :key_value or :pub_sub"
      end
      @@instances << node
    end

    ### class methods ###

    class << self

      # @return [Object] current redis client
      def redis
        @@redis
      end

      # Sets a new global redis client for the pool
      # @return [Object] new redis client
      def redis= new_redis
        @redis = new_redis
      end
    end

    ### instance methods ###

    def read
    end

    def write
    end

    def close
    end

  end
end
