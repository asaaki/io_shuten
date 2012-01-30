# encoding: utf-8

module IO_shuten::Stores::Redis::KeyValue
  # Redis Backend type for storing every data piece into its own key (namespace)
  module Collection

    def read
      result = read_collection
      result.join
    end

    def read_collection
      coll = @redis.keys("#{@node_name}:*").sort
      coll.inject([]) do |store, key|
        store << (@redis.get(key))
        store
      end
    end

    def write data
      counter = @redis.keys("#{@node_name}:*").size + 1
      @redis.set "#{@node_name}:#{counter}", data
    end

    def clear!
      coll = @redis.keys("#{@node_name}:*")
      coll.each{ |key| @redis.del key }
    end

  end
end
