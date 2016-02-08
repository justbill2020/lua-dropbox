lua-dropbox
====
[![License](http://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)
[![Coverage Status](https://coveralls.io/repos/louis77/lua-dropbox/badge.svg?branch=master&service=github)](https://coveralls.io/github/louis77/lua-dropbox?branch=master)


A non-official wrapper around Dropbox API v2

TODO
====
Exception handling
Implement rest of API


Usage
====

	> dropbox = require('dropbox')
  > dropbox.set_token "PUT_YOUR_ACCESS_TOKEN_HERE"
	> response = dropbox.create_folder('/new_folder')

The rest of the API documentation is on the [doc](http://github.com/louis77/lua-dropbox/doc) page.


Dependencies
====

todo


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
