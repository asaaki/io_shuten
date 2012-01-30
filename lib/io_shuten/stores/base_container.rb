# encoding: utf-8

module IO_shuten::Stores
  # Namespace for mongodb backends
  module BaseContainer
    def read
      # dummy
    end

    def write data
      # dummy
    end

    def close
      # dummy
      # we never close/quit the connection
      # because the instance can be a shared one
    end
  end
end
