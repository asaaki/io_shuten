# encoding: utf-8
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rubygems"
require "benchmark"
require "bundler/setup"
require "io_shuten"
require "logger"

IOM = IO_shuten::Memory
IOB = IO_shuten::Buffer

loops_write  =  5000
loops_logger =  5000
loops_files  =  2000
loops_files_outer = 5

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

puts
puts "BENCHMARK: IO_shuten::Buffer vs IO_shuten::Memory #{ENV['TRAVIS'] ? '(TRAVIS CI)' : ''}"

puts
puts "WRITES"
puts
Benchmark.bmbm do |x|
  x.report "W  IO_shuten::Buffer" do
    IO_shuten::Buffer.purge_instances!
    loops_write.times do |i|
      iob = IO_shuten::Buffer.new("wbuff-#{i}")
      iob.write lorem_ipsum
    end
  end
  x.report "W  IO_shuten::Memory" do
    IO_shuten::Memory.purge_instances!
    loops_write.times do |i|
      iom = IO_shuten::Memory.new("wmem-#{i}")
      iom.write lorem_ipsum
    end
  end
end

puts
puts "LOGGING"
puts
Benchmark.bmbm do |x|
  x.report "L  IO_shuten::Buffer" do
    IO_shuten::Buffer.purge_instances!
    loops_logger.times do |i|
      logdev = IO_shuten::Buffer.new("logdev-#{i}")
      logger = Logger.new(logdev)
      logger.info lorem_ipsum
      logger.debug "counter: #{i}"
    end
  end
  x.report "L  IO_shuten::Memory" do
    IO_shuten::Memory.purge_instances!
    loops_logger.times do |i|
      logdev = IO_shuten::Memory.new("logdev-#{i}")
      logger = Logger.new(logdev)
      logger.info lorem_ipsum
      logger.debug "counter: #{i}"
    end
  end
end

puts
puts "FILE WRITES"
puts
Benchmark.bmbm do |x|
  x.report "FW IO_shuten::Buffer" do
    IO_shuten::Buffer.purge_instances!
    loops_files.times do |i|
      iob = IO_shuten::Buffer.new("#{tmp_path}/wbuff-#{i}")
      iob.write lorem_ipsum
      iob.save_to_file
    end
  end
  x.report "FW IO_shuten::Memory" do
    IO_shuten::Memory.purge_instances!
    loops_files.times do |i|
      iom = IO_shuten::Memory.new("#{tmp_path}/wmem-#{i}")
      iom.write lorem_ipsum
      iom.save_to_file
    end
  end
end

puts
puts "FILE READS"
puts
Benchmark.bmbm do |x|
  x.report "FR IO_shuten::Buffer" do
    loops_files_outer.times do
      IO_shuten::Buffer.purge_instances!
      loops_files.times do |i|
        iob = IO_shuten::Buffer.new("#{tmp_path}/wbuff-#{i}")
        iob.load_from_file
        iob.read
      end
    end
  end
  x.report "FR IO_shuten::Memory" do
    loops_files_outer.times do
      IO_shuten::Memory.purge_instances!
      loops_files.times do |i|
        iom = IO_shuten::Memory.new("#{tmp_path}/wmem-#{i}")
        iom.load_from_file
        iom.read
      end
    end
  end
end

Dir["#{tmp_path}/**/*"].each do |f|
  File.unlink f
end

puts
puts "/BENCHMARK"
