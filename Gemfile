source "https://rubygems.org"

gem "hiredis", "~> 0.4.4"
gem "redis", "~> 2.2.2", :require => ["redis/connection/hiredis", "redis"]

gem "bson_ext", "~> 1.5.2"
gem "mongo", "~> 1.5.2"

group :development, :test do
  gem "rake"
  gem "jeweler"

  gem "rspec", "~> 2.8.0"
  gem "simplecov", :require => false
  gem "simplecov-rcov", :require => false
  gem "simplecov-csv", :require => false

  gem "redcarpet"
  gem "rdoc"
  gem "yard"
  #gem "yard-rspec" # not working :(
  gem "yard-blame"

  gem "pry"
  gem "pry-doc"
end


