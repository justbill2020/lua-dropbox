rockspec_format = "1.0"
package = "lua-dropbox"
version = "0.1-0"
source = {
  url = "git://github.com/loui77/lua-dropbox.git"
}
description = {
  summary = "A wrapper for Dropbox API v2",
  detailed = [[lua-dropbox is a wrapper around the Dropbox API v2.
    This is not an offical library from Dropbox.
    The docs for Dropbox API can be found here:
    https://www.dropbox.com/developers/documentation/http/overview
  ]],
  homepage = "http://github.com/louis77/lua-dropbox",
  license = "MIT",
  maintainer = "Louis Brauer <louis77@mac.com>"
}
dependencies = {
  "lua >= 5.1",
  "lua-requests-https >= 1.1"
}

build = {
  type = "builtin",
  modules = {
    requests = "src/dropbox.lua"
  }
}
