# encoding: utf-8

require "redis"
require "redis-namespace"

module IO_shuten
  # Implementation of the Redis storage
  #
  # Two backends are possible: simple key-value and pub-sub messaging
  #
  # KeyValue
  # has different node types.
  #   Single: all writes go into a single key
  #   Collection: every write will create a new key (namespaced)
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
    @@redis = ::Redis::Namespace.new(:io_shuten, :redis => ::Redis.new)

    # @param [String] node_name
    # @param [Symbol] node_name
    # @param [Symbol] backend :key_value, :pub_sub
    # @param [Symbol] type for backend :key_value => [:single,:collection], for backend :pub_sub => [:publisher,:subscriber]
    # @param [Object] Redis an instance for this specific node, otherwise the Redis.redis instance will be used
    def initialize node_name, backend, type, redis_instance = nil
      if [String, Symbol].include?(node_name.class)
        unless Redis.instance_exists? node_name
          @node_name      = node_name
          redis_instance  ||= @@redis
          @container      = Stores::Redis::Container.new(node_name, backend, type, redis_instance)
          @@instances     << self unless @@instances.include?(self)
        else
          raise Errors::NodeExistsError, "Node already in pool, replacement is not allowed."
        end
      else
        raise Errors::NodeNameError, "Name must be kind of String or Symbol and can't be nil."
      end

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
        @@redis = new_redis
      end

      def redis_clear!
        keys = @@redis.keys
        keys.each do |key|
          @@redis.del key
        end
      end

    end

  end
end
