source "https://rubygems.org"

gem "iobuffer", "~> 1.1.2"

# REDIS STORE
gem "hiredis", "~> 0.4.5"
gem "redis", "~> 3.0.2", :require => ["redis/connection/hiredis", "redis"]
gem "redis-namespace", "~> 1.2.1"

# MONGO STORE
#gem "bson_ext", "~> 1.7.0"
#gem "mongo", "~> 1.7.0"

# ZMQ "STORE"
#gem "ffi", "~> 1.1.5"
#gem "ffi-rzmq", "~> 0.9.6"

group :development, :test do
  gem "rake"
  gem "jeweler"

  gem "rspec", "~> 2.11.0"

  gem "pry"
  gem "pry-doc"

  gem "alf"
  gem "fastercsv"
  gem "viiite"
end
