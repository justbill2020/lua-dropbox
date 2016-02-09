--- A Dropbox API v2 wrapper.
-- @license MIT
-- @author Louis Brauer <louis77@mac.com>
-- @release 0.1
-- @todo Create chunked file upload.

-- https://github.com/JakobGreen/lua-requests/wiki
local requests = require 'requests'
local json = require 'cjson.safe'
-- https://github.com/jagt/pprint.lua
local pp = require 'pprint'

local M = {}

-- Constants

local DROPBOX_RPC_ENDPOINT = 'https://api.dropboxapi.com/2/'
local DROPBOX_CONTENT_ENDPOINT = 'https://content.dropboxapi.com/2/'
local RPC_CALLS = {
  -- files
  list_folder         = 'files/list_folder',
  create_folder       = 'files/create_folder',
  copy                = 'files/copy',
  delete              = 'files/delete',
  get_metadata        = 'files/get_metadata',
  list_revisions      = 'files/list_revisions',
  move                = 'files/move',
  permanently_delete  = 'files/permanently_delete',
  restore             = 'files/restore',
  search              = 'files/search',
  -- sharing
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
  update_folder_policy              = 'sharing/update_folder_policy',
  -- users
  get_account         = 'users/get_account',
  get_account_batch   = 'users/get_account_batch',
  get_current_account = 'users/get_current_account',
  get_space_usage     = 'users/get_space_usage'
}

-- Module vars

local token

-- Private functions

local function add_auth(tbl)
  tbl["Authorization"] = "Bearer " .. token
  return tbl
end

local function json_resp(response)
  local err
  if response.status_code >= 400 then
    err = response.text
  end
  local result = response.headers['dropbox-api-result'] and json.decode(response.headers['dropbox-api-result']) or response.json()
  return result, err
end

local function make_rpc_request(reqfunc, endpoint, data)
  local headers = add_auth{}
  if data then
    headers["Content-Type"] = 'application/json'
  end
  local response = reqfunc(DROPBOX_RPC_ENDPOINT .. endpoint, {
    headers = headers,
    data = data
  })
  return json_resp(response)
end

local function make_content_upload_request(reqfunc, endpoint, data, content)
  local headers = add_auth{
    ["Dropbox-API-Arg"] = json.encode(data),
    ["Content-Type"] = 'application/octet-stream'
  }
  local response = reqfunc(DROPBOX_CONTENT_ENDPOINT .. endpoint, {
    headers = headers,
    data = content
  })
  return json_resp(response)
end

local function make_content_download_request(reqfunc, endpoint, data)
  local headers = add_auth{
    ["Dropbox-API-Arg"] = json.encode(data)
  }
  local response = reqfunc(DROPBOX_CONTENT_ENDPOINT .. endpoint, {
    headers = headers
  })
  return response.text, json_resp(response)
end


local magic_calls_mt = {}
magic_calls_mt.__index = function(_, w)
    local call = RPC_CALLS[w]
    if not call then
      error("Unknown API method '"..w.."'")
    end
    return function(args) return make_rpc_request(requests.post, call, args) end
end
setmetatable(M, magic_calls_mt)


local function list_folder_continue(cursor)
  return make_rpc_request(requests.post, 'files/list_folder/continue', {cursor=cursor})
end

-- Public functions

--- Set the access token for your Dropbox account.
-- Call this function first before you do any other calls.
-- @string tk Dropbox access token
function M.set_token(tk)
  token = tk
end


--- Iterate over a folder listing.
-- @param res raw response from list_folder
-- @return Iterable, can be used in for loops
function M.cursor(res)
  local results = res
  local pos = 0
  local local_pos = 0
  return function()
    pos = pos + 1
    local_pos = local_pos + 1
    if not results.entries[local_pos] and results.has_more then
      local_pos = 1
      results = list_folder_continue(results.cursor)
    end
    return results.entries[local_pos], pos
  end
end

--- Upload (create) a file.
-- Should only be used for smaller files.
-- @string path Path of file
-- @string data String or file handle
-- @return Raw response, contains meta info about created file
-- @return Error message if error occured during operation
function M.upload(path, data, overwrite)
  local body = data
  local message = {
    path = path,
    mode = overwrite and "overwrite" or "add",
    autorename = false,
    mute = false
  }
  if type(data) == 'userdata' and io.type(data) == 'file' then
    body = data:read("*a")
  end
  local result = make_content_upload_request(requests.post, 'files/upload', message, body)
  return result
end

function M.upload_session_start(chunk)
  return make_content_upload_request(requests.post, 'files/upload_session/start', nil, chunk)
end

function M.upload_session_append(session_id, offset, chunk)
  local message = {
    session_id = session_id,
    offset = offset
  }
  return make_content_upload_request(requests.post, 'files/upload_session/append', message, chunk)
end

function M.upload_session_finish(session_id, offset, path, overwrite, chunk)
  local message = {
    cursor = {
      session_id = session_id,
      offset = offset
    },
    commit = {
      path = path,
      mode = overwrite and "overwrite" or "add",
      autorename = false,
      mute = false
    }
  }
  return make_content_upload_request(requests.post, 'files/upload_session/finish', message, chunk)
end

--- Download file contents.
-- Should only be used for smaller files. Full file content is stores in a string.
-- @string path Path of file
-- @return File content
-- @return File meta info
-- @return Error message if error occured during operation
function M.download(path)
  return make_content_download_request(requests.get, 'files/download', path)
end

return M
