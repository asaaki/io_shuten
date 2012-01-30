# encoding: utf-8

module IO_shuten::Stores::Redis::KeyValue
  # Redis Backend type for storing data into a single key (content => array/hash)
  module Single

    def read
      result = read_raw
      result.join
    end

    def read_raw
      @redis.lrange @node_name, 0, -1
    end

    def write data
      @redis.rpush @node_name, data
    end

    def clear!
      @redis.del @node_name
    end

  end
end
