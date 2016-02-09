lua-dropbox
====
[![License](http://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)
[![Travis](https://img.shields.io/travis/louis77/lua-dropbox.svg)]()

A non-official wrapper around Dropbox API v2

TODO
====

- [ ] Better exception handling
- [ ] Documentation on Uploading and Downloading files


Usage
====

## Setup

```lua
dropbox = require('dropbox')
dropbox.set_token "PUT_YOUR_ACCESS_TOKEN_HERE"
```

## Files and folders

Example:

```lua
result, err = dropbox.copy{
    from_path = 'source.txt',
    to_path = 'to_path'
}
```

The following calls to the RPC endpoints are supported and mapped 1:1 as
described in the HTTP API documentation. The functions always return the
original Dropbox response plus an error code, if there was an error.

Please lookup the [Dropbox API doc] for the details.(https://www.dropbox.com/developers/documentation/http/documentation)

```lua
list_folder         = 'files/list_folder',
create_folder       = 'files/create_folder',
copy                = 'files/copy',
delete              = 'files/delete',
get_metadata        = 'files/get_metadata',
list_revisions      = 'files/list_revisions',
move                = 'files/move',
permanently_delete  = 'files/permanently_delete',
restore             = 'files/restore',
search              = 'files/search'
```

## Sharing

```lua
add_folder_member                 = 'sharing/add_folder_member',
check_job_status                  = 'sharing/check_job_status',
check_share_job_status            = 'sharing/check_share_job_status',
create_shared_link_with_settings  = 'sharing/create_shared_link_with_settings',
get_folder_metadata               = 'sharing/get_folder_metadata',
get_shared_link_metadata          = 'sharing/get_shared_link_metadata',
list_folder_members               = 'sharing/list_folder_members',
list_folders                      = 'sharing/list_folders',
list_shared_links                 = 'sharing/list_shared_links',
modify_shared_link_settings       = 'sharing/modify_shared_link_settings',
mount_folder                      = 'sharing/mount_folder',
relinquish_folder_membership      = 'sharing/relinquish_folder_membership',
remove_folder_member              = 'sharing/remove_folder_member',
revoke_shared_link                = 'sharing/revoke_shared_link',
share_folder                      = 'sharing/share_folder',
transfer_folder                   = 'sharing/transfer_folder',
unmount_folder                    = 'sharing/unmount_folder',
unshare_folder                    = 'sharing/unshare_folder',
update_folder_member              = 'sharing/update_folder_member',
update_folder_policy              = 'sharing/update_folder_policy'
```

## Account

```lua
get_account         = 'users/get_account',
get_account_batch   = 'users/get_account_batch',
get_current_account = 'users/get_current_account',
get_space_usage     = 'users/get_space_usage'
```


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
