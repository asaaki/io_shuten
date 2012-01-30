# encoding: utf-8

module IO_shuten::Stores
  # Namespace for redis backends
  module Redis
  end
end

require "redis"
require "redis-namespace"

require "io_shuten/stores/redis/key_value"
require "io_shuten/stores/redis/pub_sub"
require "io_shuten/stores/redis/container"
