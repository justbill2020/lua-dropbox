lua-dropbox
====
[![License](http://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)
[![Travis](https://img.shields.io/travis/louis77/lua-dropbox.svg)]()

A non-official wrapper around Dropbox API v2

TODO
====
Exception handling
Implement rest of API


Usage
====

	> dropbox = require('dropbox')
  > dropbox.set_token "PUT_YOUR_ACCESS_TOKEN_HERE"


For the full set of features consult the [documentation](http://louis77.github.io/lua-dropbox/) page.



Dependencies
====

 	- Lua 5.1, 5.2, LuaJit 2.0, LuaJit 2.1


Tests
====

Tests are located in the tests directory and are written using [busted](http://olivinelabs.com/busted/ "Busted home page").

Install `busted`:

	$ luarocks install busted

Run Tests (using the packaged .busted config):

	$ busted

Licensing
====

`lua-dropbox` is licensed under the MIT license. See LICENSE.md for details on the MIT license.
