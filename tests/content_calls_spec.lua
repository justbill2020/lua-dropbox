require 'busted.runner'()
local pp = require('../src/pprint')

describe("Dropbox Content calls", function()
  local dropbox
  local bigfile_1m
  local fname = '/a_testfile_content.txt'

  setup(function()
    dropbox = require('../src/dropbox')
    dropbox.set_token (os.getenv("DROPBOX_TOKEN"))
    -- write 1MB of data
    bigfile_1m = assert(io.tmpfile():write(string.rep('.', 1048576)))
    bigfile_1m:flush()
  end)

  describe("#upload", function()
    it("of a string, overwrite on", function()
      local result, err = dropbox.upload(fname, "this is a test string", true)
      assert.falsy(err)
      assert.is.equal(string.lower(fname), result.path_lower)
    end)

    it("of a 1MB file, overwrite on", function()
      local offset = 0
      local result, err = dropbox.upload_session_start()
      assert.truthy(result.session_id)
      assert.falsy(err)
      local session_id = result.session_id
      bigfile_1m:seek("set")

      repeat
        local chunk = bigfile_1m:read(102400)
        if chunk then
          local _, err = dropbox.upload_session_append(session_id, offset, chunk)
          assert.is.falsy(err)
          offset = offset + #chunk
          print("Uploaded "..offset.." bytes...")
        else
          pp("Finished")
        end
      until not chunk

      local final, _ = dropbox.upload_session_finish(session_id, offset, fname, true, nil)
      assert.is.equal(string.lower(fname), final.path_lower)
      assert.is.equal(offset, final.size)
    end)
  end)
end)
