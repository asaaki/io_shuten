# encoding: utf-8

module IO_shuten::Stores
  # Namespace for mongodb backends
  module Mongo
  end
end

require "io_shuten/stores/mongo/collection"
require "io_shuten/stores/mongo/gridfs"

