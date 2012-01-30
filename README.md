# IO::shuten 【五百::終点】 [![Build Status](https://secure.travis-ci.org/asaaki/io_shuten.png)](http://travis-ci.org/asaaki/io_shuten)

Use databases as IO handler like you would do with files and streams.


## Motivation

One purpose for creating this project is to have an IO like interface to database storages.

With this gem you should have the possibility to use redis or mongodb as endpoints for IO related tasks like logging.

Example:

```ruby
require "io_shuten"
require "logger"

# use redis namespace to separate and avoid naming conflicts
IO_shuten::Redis.redis = Redis::Namespace.new("io_shuten/test", :redis => Redis.new)

# instantiate logdev and logger
logdev = IO_shuten::Redis.new(:app_log, :key_value, :collection)
logger = Logger.new(logdev)

# log something
logger.info "This message will be stored in redis as a single key."
logger.debug "And this message will be also a single key"

#check
logdev.read #=> will return both messages as a single string
```

```bash
# check in redis for the keys
redis-cli KEYS "io_shuten/test"
```

## IO::shuten? 【五百::終点】(io shūten)!

In japanese `io` means *500* or *big amount*, `shū･ten` means *endpoint* (train terminus/last stop or mathematical endpoint).


## Types


### IO_shuten::Memory

An in-memory storage system (handles simple StringIO objects).

Offers write-to-disk for single instance and all instances.

Provides all methods of StringIO.

### IO_shuten::Buffer

Like IO_shuten::Memory but with IO::Buffer as container instead of StringIO.
(Install it with `gem install iobuffer`.)

Performance depends on machine and ruby version. Almost same throughput, on 1.9.3 is the native StringIO better than the IO::Buffer cext.

### IO_shuten::Redis

Stores content in a redis database.

Provides basic methods like `#read`, `#write` and `#close`.
A logger only needs write and close methods of an IO object.

### IO_shuten::Mongo

Stores content in a mongodb database.

Provides basic methods like `#read`, `#write` and `#close`.
A logger only needs write and close methods of an IO object.

### IO_shuten::Zmq

"Stores" content in a zmq socket.

Provides basic methods like `#read`, `#write` and `#close`.
A logger only needs write and close methods of an IO object.


## Not for production!

This project is freshly started and currently not usable.

Everything can and maybe will change.

Feel free to contribute, write issues if you want to support me with your ideas and insights.


## git flowed

Development will happen in the `develop` branch now, master should be in a deployable state.

Read more about `git flow` and the branchin model here:

* http://nvie.com/posts/a-successful-git-branching-model/
* https://github.com/nvie/gitflow

I like this approach and try to use it whenever possible, also in one-man-development.


## License

This gem/software is licensed under MIT/X11 license. See [LICENSE](https://raw.github.com/asaaki/io_shuten/develop/LICENSE) (or [LICENSE.de](https://raw.github.com/asaaki/io_shuten/develop/LICENSE.de) for german translation).

— [Christoph 'asaaki' Grabo](https://github.com/asaaki)
