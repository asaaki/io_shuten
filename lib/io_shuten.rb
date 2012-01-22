# encoding: utf-8

# Namespace of the IO implementations
module IO_shuten; end

require "io_shuten/errors"
require "io_shuten/base"
require "io_shuten/redis"
require "io_shuten/mongo"

# IO::Mongo for a more intuitive usage
IO::Mongo = IO_shuten::Mongo

# IO::Redis for a more intuitive usage
IO::Redis = IO_shuten::Redis

