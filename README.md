# ExCoveralls [![Build Status](https://secure.travis-ci.org/parroty/excoveralls.png?branch=master "Build Status")](http://travis-ci.org/parroty/excoveralls) [![Coverage Status](https://coveralls.io/repos/parroty/excoveralls/badge.png?branch=master)](https://coveralls.io/r/parroty/excoveralls?branch=master)
============


A library to post coverage stats to [coveralls.io](https://coveralls.io/) service.
It uses Erlang's [cover](http://www.erlang.org/doc/man/cover.html) to generate coverage information, and post it to coveralls' json API.

It integrates with travis-ci at the moment.

# Setting
### mix.exs

```elixir
defp deps do
  [
    {:excoveralls, github: "parroty/excoveralls"}
  ]
end
```

### .travis.yml
Specify "MIX_ENV=coveralls_travis mix test --cover" as after_success section of .travis.yml

```
language: erlang
otp_release:
  - R16B
before_install:
  - git clone https://github.com/elixir-lang/elixir
  - cd elixir && make && cd ..
before_script: "export PATH=`pwd`/elixir/bin:$PATH"
script: "MIX_ENV=test mix do deps.get, test"
after_success:
  - "MIX_ENV=coveralls_travis mix test --cover"
```

### TODO
- It depends on curl command for posting JSON. Replace it with Elixir library.