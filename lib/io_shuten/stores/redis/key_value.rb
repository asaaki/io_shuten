# encoding: utf-8

module IO_shuten::Stores::Redis
  # Redis Backend for key-value based storage
  module KeyValue

    def use_type type
      types = {:single => KeyValue::Single, :collection => KeyValue::Collection}
      if types.keys.include?(type)
        self.extend types[type]
        @backend_type = type
      else
        raise ArgumentError, "Type for backend unknown. Use :single or :collection"
      end
    end

  end
end

require "io_shuten/stores/redis/key_value/single"
require "io_shuten/stores/redis/key_value/collection"
