# encoding: utf-8
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rubygems"
require "viiite"
require "bundler/setup"
require "io_shuten"
require "logger"

lorem_ipsum = <<LOREM
Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod
tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren,
no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet,
consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et
dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo
dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem
ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed
diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam
voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd
gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
LOREM


ioc = IO_shuten.const_get $CUR_IMPL
ioc.redis = Redis::Namespace.new("io_shuten:benchmark", :redis => Redis.new)
runs = 1..5
outer_loops = 32
internal_loops = 128

Viiite.bench do |b|
  b.variation_point :ruby, Viiite.which_ruby
  b.variation_point :type, "#{$CUR_IMPL}:#{$CUR_BACKEND}:#{$CUR_TYPE}"

  b.range_over(runs, :run) do |run|

    ioc.purge_instances!
    b.report :writes do
      outer_loops.times do |o|
        iob = ioc.new("rbuff-#{run}-#{o}",$CUR_BACKEND,$CUR_TYPE)

        internal_loops.times do |i|
          iob.write lorem_ipsum
        end
      end
    end

    ioc.purge_instances!
    b.report :reads do
      outer_loops.times do |o|
        iob = ioc.new("rbuff-#{run}-#{o}",$CUR_BACKEND,$CUR_TYPE)

        internal_loops.times do |i|
          iob.read
        end
      end

    ioc.purge_instances!
    b.report :logging do
      outer_loops.times do |o|
        logdev = ioc.new("rlogdev-#{run}-#{o}",$CUR_BACKEND,$CUR_TYPE)
        logger = Logger.new(logdev)

        internal_loops.times do |i|
          logger.info lorem_ipsum
          logger.debug "counter: #{run}-#{o}"
        end
      end
    end

    end

    ioc.redis_clear!
  end

end
