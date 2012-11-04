# encoding: utf-8
$LOAD_PATH.unshift File.expand_path("../../benchmark", __FILE__)

$CUR_IMPL    = "Redis"
$CUR_BACKEND = :key_value
$CUR_TYPE    = :collection

require "viiite-template-redis.rb"
