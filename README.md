# IO::shuten 【五百::終点】 [![Build Status](https://secure.travis-ci.org/asaaki/io_shuten.png)](http://travis-ci.org/asaaki/io_shuten)

Use databases as IO handler like you would do with files and streams.

Backends are (or will be): Redis, MongoDB.

Special backend will be: ZeroMQ (not a database but cool message queue backend).

Wishes? MySQL, Postgres, Sqlite? Other NoSQLs, memcache? Tell me!

## Motivation

One purpose for creating this project is to have an IO like interface to database storages.

With this gem you should have the possibility to use redis or mongodb as endpoints for IO related tasks like logging.

And logging was my first idea for this project. I want to have the possibility to set my own logger (endpoint) in a Ruby/Rails app.

Also you could use different logger endpoints in the same app for different purposes but without bloating your app/tmp dir with huge files.

If you have more cool ideas, what to do with it, tell me (and I will put it in this README).

### Example

```ruby
require "io_shuten"
require "logger"

# use redis namespace to separate and avoid naming conflicts
IO_shuten::Redis.redis = Redis::Namespace.new("io_shuten:test", :redis => Redis.new)

# instantiate logdev and logger
logdev = IO_shuten::Redis.new(:app_log, :key_value, :collection)
logger = Logger.new(logdev)

# log something
logger.info "This message will be stored in redis as a single key."
logger.debug "And this message will be also a single key"

#check
puts logdev.read #=> will return both messages as a single string
```

And check in redis for the keys:

```bash
redis-cli KEYS "io_shuten/test"
```


## IO::shuten? 【五百::終点】(io shūten)!

In japanese `io` means *500* or *big amount*, `shū･ten` means *endpoint* (train terminus/last stop or mathematical endpoint).


## Storage Types


### IO_shuten::Redis

Stores content in a redis database.


#### Backends

The redis storage system provides two different backends: `KeyValue` and `PubSub`.


##### KeyValue

Has two different storage types: `Single` and `Collection`.


##### KeyValue::Single

Stores every message in a single key in redis (like a big document).

Choose this, if you have only small amount of chunks to store.
More reads, less writes.

```ruby
require "io_shuten"
IO_shuten::Redis.redis = Redis::Namespace.new("io_shuten:key_value:single:test", :redis => Redis.new)

io_object = IO_shuten::Redis.new(:my_node, :key_value, :single)

io_object.write "my awesome data!\n"
io_object.write "chunky bacon!!!\n"

io_object.read
```

After this you will have a single key in redis like:

```
$ redis-cli KEYS "io_shuten:key_value:collection:test:*"
1) "io_shuten:key_value:single:test:my_node"
```

The content is a LIST:

```
$ redis-cli LRANGE "io_shuten:key_value:single:test:my_node" 0 -1
1) "my awesome data!\n"
2) "chunky bacon!!!\n"
```

##### KeyValue::Collection

Stores every single message in its own key. The provided node_name acts as namespace.

Choose this if you have huge amounts of chunks, especially constantly coming in, like logging events.
More writes, less reads.

```ruby
require "io_shuten"
IO_shuten::Redis.redis = Redis::Namespace.new("io_shuten:key_value:collection:test", :redis => Redis.new)

io_object = IO_shuten::Redis.new(:my_node, :key_value, :collection)

io_object.write "my awesome data!\n"
io_object.write "chunky bacon!!!\n"

io_object.read
```

After this you will have two keys in redis like:

```
$ redis-cli KEYS "io_shuten:key_value:collection:test:*"
1) "io_shuten:key_value:collection:test:my_node:0000000000000000"
2) "io_shuten:key_value:collection:test:my_node:0000000000000001"
3) "io_shuten:key_value:collection:test:my_node:0000000000000002"
```
The first key with 16 zeros is a counter (to avoid long running key searches to get the count).

Numerical part is a 16 digit number, should be enough for 10 quadrillion (minus 1) messages per node.
(The reason is for internal sorting of the keys)

With messages of an average length of only 16 bytes this would end up in 160 petabytes of raw data.


##### PubSub

**Not yet implemented!**

Will have two types: `Publisher` and `Subscriber`.

As logger backend only the `PubSub::Publisher` will be usable,
but you can use a redis subscriber on the other side to receive the messages and do something with them.

### IO_shuten::Mongo

**Not yet implemented!**


### IO_shuten::Zmq

**Not yet implemented!**


### IO_shuten::Memory and IO_shuten::Buffer

**Maybe only useful as temporary storage for a session.**

_These implementations were the first tests and aren't intended to be used in production._

> An in-memory storage system (handles simple StringIO/IOBuffer objects).
>
> Offers write-to-disk for single instance and all instances.
>
> Provides all methods of StringIO respectively IOBuffer.
>
> _IOBuffer usage:_ Install it with `gem install iobuffer` first.
>
> Performance of both are nearly the same.
>
> Read the _documentation_ if you really want to use them.


## [Documentation](http://asaaki.github.com/io_shuten/doc/index.html)


## Future Plans

Maybe a special Logger, especially for Redis (to get benefits of the key search).


## Not for production!

This project is freshly started and currently not usable.

Everything can and maybe will change.

Feel free to contribute, write issues if you want to support me with your ideas and insights.


## git flowed

Development will happen in the `develop` branch, `master` should be in a deployable state.

Read more about `git flow` and the branching model here:

* http://nvie.com/posts/a-successful-git-branching-model/
* https://github.com/nvie/gitflow

I like this approach and try to use it whenever possible, also in one-man-development.

### Contribute

Fork it, create your feature in a `feature/branch` based on `develop`(!), make a pull request.

Hotfixes for master can be made out of master branch, of course. ;o)

## License

This gem/software is licensed under MIT/X11 license. See [LICENSE](https://raw.github.com/asaaki/io_shuten/develop/LICENSE) (or [LICENSE.de](https://raw.github.com/asaaki/io_shuten/develop/LICENSE.de) for german translation).

— [Christoph 'asaaki' Grabo](https://github.com/asaaki)
