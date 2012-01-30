# encoding: utf-8

module IO_shuten::Stores::Redis
  # Redis Backend for pub-sub (event/message) based storage
  module PubSub

    def use_type type
      if [:publisher,:subscriber].include?(type)
        @backend_type = type
      else
        raise ArgumentError, "Type for backend unknown. Use :single or :collection"
      end
    end

  end
end

require "io_shuten/stores/redis/pub_sub/publisher"
require "io_shuten/stores/redis/pub_sub/subscriber"
