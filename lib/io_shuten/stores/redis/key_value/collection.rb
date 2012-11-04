# encoding: utf-8

module IO_shuten::Stores::Redis::KeyValue
  # Redis Backend type for storing every data piece into its own key (namespace)
  module Collection

    def counter_name
      "#{@node_name}:#{"%016d" % '0'}"
    end

    def read
      result = read_collection
      result.join
    end

    def read_collection
      coll = @redis.keys("#{@node_name}:*").sort
      coll.inject([]) do |store, key|
        store << (@redis.get(key)) unless key == counter_name
        store
      end
    end

    def write data
      counter = self.size + 1
      key     = "#{@node_name}:#{"%016d" % counter}"
      @redis.multi do
        @redis.set key, data
        @redis.incr counter_name
      end
    end

    def size
      @redis.get(counter_name).to_i || 0
    end

    def clear!
      coll = @redis.keys("#{@node_name}:*")
      coll.each{ |key| @redis.del key }
    end

  end
end
