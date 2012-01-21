# IO::shuten 【五百::終点】

Use databases as IO handler like you would do with files and streams.


## Motivation

One purpose for creating this project is to have an IO like interface to database storages.

With this gem you should have the possibility to use redis or mongodb as endpoints for IO related tasks like logging.

Example:

```ruby
require "io_shuten"
require "logger"

logdev = IO_shuten::Redis.new( REDIS_INSTANCE )
logger = Logger.new(logdev)

logger.info "This message will be stored in redis."
```


## IO::shuten? 【五百::終点】(io shūten)!

In japanese `io` means *500* or *big amount*, `shū･ten` means *endpoint* (train terminus/last stop or mathematical endpoint).


## Types


### IO_shuten::Base

An in-memory storage system (handles simple StringIO objects).


### IO_shuten::Redis

Stores content in a redis database.


### IO_shuten::Mongo

Stores content in a mongodb database.


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

— [Christoph 'asaaki' Grabo](https://github.com/asaaki) 〆

