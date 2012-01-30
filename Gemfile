source "https://rubygems.org"

gem "iobuffer", "~> 1.0.0"

# REDIS STORE
gem "hiredis", "~> 0.4.4"
gem "redis", "~> 2.2.2", :require => ["redis/connection/hiredis", "redis"]
gem "redis-namespace"

# MONGO STORE
gem "bson_ext", "~> 1.5.2"
gem "mongo", "~> 1.5.2"

# ZMQ "STORE"
gem "ffi"
gem "ffi-rzmq"

group :development, :test do
  gem "rake"
  gem "jeweler"

  gem "rspec", "~> 2.8.0"
  gem "simplecov", :require => false
  gem "simplecov-rcov", :require => false
  gem "simplecov-csv", :require => false

  gem "redcarpet"
  gem "yard"
  gem "yard-blame"

  gem "pry"

  gem "alf"
  gem "fastercsv"
  gem "viiite"
end