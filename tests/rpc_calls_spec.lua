require 'busted.runner'()
local pp = require('../src/pprint')

describe("Dropbox RPC calls", function()
  local dropbox

  setup(function()
    dropbox = require('../src/dropbox')
    dropbox.set_token (os.getenv("DROPBOX_TOKEN"))
  end)

  describe("#folders", function()
    local fname = '/a_testfolder'

    it("can be created", function()
      local result, err = dropbox.create_folder{path=fname}
      assert.falsy(err)
      assert.is.equal(string.lower(fname), result.path_lower)
    end)

    it("yields #error if created without a name", function()
      local result, err = dropbox.create_folder{path=""}
      assert.truthy(err)
    end)

    it("can be listed #magically", function()
      local result = dropbox.list_folder{path=fname}
      assert.is.truthy(result.entries)
      assert.is.equal(0, #result.entries)
    end)

    it("can be deleted", function()
      local result = dropbox.delete{path=fname}
      assert.is.equal("folder", result[".tag"])
      assert.is.equal(string.lower(fname), result.path_lower)
    end)

    it("doesn't accept unknown RPC calls", function()
      assert.has_error(function()
        local _ = dropbox.list_something()
      end)
    end)
  end)

  describe("#files", function()
    local fname = "/a_testfile.txt"
    local fname_copy = "/a_testfile_copy.txt"
    local content = "This is the content of the text file"

    teardown(function()
      local result = dropbox.delete{path=fname_copy}
    end)

    it("can be created with a string", function()
      local result = dropbox.upload(fname, content)
      assert.is.equal(string.lower(fname), result.path_lower)
      assert.is.equal(#content, result.size)
    end)

    it("can be copied", function()
      local result = dropbox.copy{from_path=fname, to_path=fname_copy}
      assert.is.equal("file", result[".tag"])
      assert.is.equal(string.lower(fname_copy), result.path_lower)
    end)

    it("can be downloaded", function()
      local data, meta, err = dropbox.download{path=fname}
      assert.is.equal(content, data)
      assert.is.same(#content, meta.size)
    end)

    it("can be deleted", function()
      local result = dropbox.delete{path=fname}
      assert.is.equal("file", result[".tag"])
      assert.is.equal(string.lower(fname), result.path_lower)
    end)
  end)

  describe("#users", function()
    it("can get current account info", function()
      local result, err = dropbox.get_current_account()
      assert.is.truthy(result.email)
    end)
  end)

--[[
  describe("#louis", function()
    it("iterate over test_10000 folder with 2805 items", function()
      local result = dropbox.list_folder('/test_10000', false, false, false)
      local i = 0
      for entry, pos in dropbox.cursor(result) do
        i = i + 1
      end
      assert(2805, i)
    end)
  end)
  ]]
end)
