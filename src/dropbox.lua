--- A Dropbox API v2 wrapper.
-- @license MIT
-- @author Louis Brauer <louis77@mac.com>
-- @release 0.1
-- @todo Create chunked file upload.

-- https://github.com/JakobGreen/lua-requests/wiki
local requests = require 'requests'
local json = require 'cjson.safe'
local pp = require 'pprint'

local M = {}

-- Constants

local DROPBOX_RPC_ENDPOINT = 'https://api.dropboxapi.com/2/'
local DROPBOX_CONTENT_ENDPOINT = 'https://content.dropboxapi.com/2/'

-- Module vars

local token

-- Private functions

local function add_auth(tbl)
  tbl["Authorization"] = "Bearer "..token
  return tbl
end

local function json_resp(response)
  local err
  if response.status_code >= 400 then
    err = response.text
  end
  return response.json(), err
end

local function make_rpc_request(reqfunc, endpoint, data)
  local headers = add_auth{
    ["Content-Type"] = 'application/json'
  }
  local response = reqfunc(DROPBOX_RPC_ENDPOINT .. endpoint, {
    headers = headers,
    data = data
  })
  return json_resp(response)
end

local function make_content_request(reqfunc, endpoint, data, content)
  local headers = add_auth{
    ["Content-Type"] = 'application/octet-stream',
    ["Dropbox-API-Arg"] = json.encode(data)
  }
  local response = reqfunc(DROPBOX_CONTENT_ENDPOINT .. endpoint, {
    headers = headers,
    data = content
  })
  return json_resp(response)
end

-- Public functions

--- Set the access token for your Dropbox account.
-- Call this function first before you do any other calls.
-- @string tk Dropbox access token
function M.set_token(tk)
  token = tk
end

--- List contents of a folder.
-- @string path Folder path, use empty string for ROOT level
-- @bool recursive
-- @bool include_media_info
-- @bool include_deleted
-- @see cursor
-- @return Raw response, pass it to cursor() to iterate and paginate over the results
-- @return Error message if error occured during operation
-- otherwise you'll get only the first few hundred results
function M.list_folder(path, recursive, include_media_info, include_deleted)
  -- https://www.dropbox.com/developers/documentation/http/documentation#files-list_folder
  local message = {
    path = path,
    recursive = recursive,
    include_media_info = include_media_info,
    include_deleted = include_deleted
  }
  return make_rpc_request(requests.post, 'files/list_folder', message)
end

local function list_folder_continue(cursor)
  -- https://www.dropbox.com/developers/documentation/http/documentation#files-list_folder-continue
  local message = {
    cursor = cursor
  }
  return make_rpc_request(requests.post, 'files/list_folder/continue', message)
end

--- Create a folder.
-- @string path Folder path and name, e.g. "/Homework/NewFolder"
-- @return Raw response
-- @return Error message if error occured during operation
function M.create_folder(path)
  local message = {
    path = path
  }
  return make_rpc_request(requests.post, 'files/create_folder', message)
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
-- @string data Raw contents of file, can be text or binary
-- @return Raw response, contains meta info about created file
-- @return Error message if error occured during operation
function M.upload(path, data)
  -- https://www.dropbox.com/developers/documentation/http/documentation#files-upload
  -- TODO This function should only be used for small files,
  --      Dropbox limit 150 MB
  local message = {
    path = path,
    mode = "add",
    autorename = true,
    mute = false
  }
  return make_content_request(requests.post, 'files/upload', message, data)
end

--- Copy a file.
-- @string from_path Source file path
-- @string to_path Destination file path
-- @return Raw response
-- @return Error message if error occured during operation
function M.copy(from_path, to_path)
  local message = {
    from_path = from_path,
    to_path = to_path
  }
  return make_rpc_request(requests.post, 'files/copy', message)
end

--- Delete a file or folder.
-- Will delete all the contents in a folder along with it.
-- @string path Folder or file path, e.g. "/Homework/Folder"
-- @return Raw response
-- @return Error message if error occured during operation
function M.delete(path)
  local message = {
    path = path
  }
  return make_rpc_request(requests.post, 'files/delete', message)
end

return M
