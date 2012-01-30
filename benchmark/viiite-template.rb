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

tmp_path = File.expand_path("../../tmp", __FILE__)
Dir.mkdir(tmp_path) unless File.exists?(tmp_path)

ioc = IO_shuten.const_get $CUR_IMPL
runs = 1..5
internal_loops = 1_024

Viiite.bench do |b|
  b.variation_point :ruby, Viiite.which_ruby
  b.variation_point :type, $CUR_IMPL

  b.range_over(runs, :run) do |run|

    ioc.purge_instances!
    b.report :writes do
      internal_loops.times do |i|
        iob = ioc.new("wbuff-#{run}-#{i}")
        iob.write lorem_ipsum
      end
    end

    ioc.purge_instances!
    b.report :logging do
      internal_loops.times do |i|
        logdev = ioc.new("logdev-#{run}-#{i}")
        logger = Logger.new(logdev)
        logger.info lorem_ipsum
        logger.debug "counter: #{run}-#{i}"
      end
    end

    ioc.purge_instances!
    b.report :file_writes do
      internal_loops.times do |i|
        iob = ioc.new("#{tmp_path}/wbuff-#{run}-#{i}")
        iob.write lorem_ipsum
        iob.save_to_file
      end
    end

    ioc.purge_instances!
    b.report :file_reads do
      internal_loops.times do |i|
        iob = ioc.new("#{tmp_path}/wmem-#{run}-#{i}")
        iob.write lorem_ipsum
        iob.save_to_file
      end
    end

  end

  # File cleaning …
  Dir["#{tmp_path}/**/*"].each do |f|
    File.unlink f
  end

end
