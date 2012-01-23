# encoding: utf-8

module IO_shuten
  # Namespace for the storage implementations
  module Stores
  end
end

require "io_shuten/stores/mongo"
require "io_shuten/stores/redis"

