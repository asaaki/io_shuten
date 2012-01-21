# encoding: utf-8
module IO_shuten; end

require "io_shuten/base"
require "io_shuten/redis"
require "io_shuten/mongo"

# handy and short aliases
IOM = IO::Mongo = IO_shuten::Mongo
IOR = IO::Redis = IO_shuten::Redis

