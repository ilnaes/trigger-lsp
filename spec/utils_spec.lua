local utils = require("utils")
local stub = require("luassert.stub")

describe("Test example", function()
	it("Should find dir", function()
		stub(vim.api, "nvim_buf_get_name")
		vim.api.nvim_buf_get_name.returns(os.getenv("PWD") .. "/lua/lsp.lua")

		local res = utils.find_root(1, ".git", false)
		assert.are.same(os.getenv("PWD"), res)
		vim.api.nvim_buf_get_name:revert()
	end)

	it("Should find file", function()
		stub(vim.api, "nvim_buf_get_name")
		vim.api.nvim_buf_get_name.returns(os.getenv("PWD") .. "/lua/lsp.lua")

		local res = utils.find_root(1, ".luarc.json", true)
		assert.are.same(os.getenv("PWD"), res)
		vim.api.nvim_buf_get_name:revert()
	end)

	it("Should not find file", function()
		stub(vim.api, "nvim_buf_get_name")
		vim.api.nvim_buf_get_name.returns(os.getenv("PWD") .. "/lua/lsp.lua")

		local res = utils.find_root(1, ".luarcn", true)
		assert.are.same("", res)
		vim.api.nvim_buf_get_name:revert()
	end)

	it("Should count correctly", function()
		local message = utils.encode("ASD")
		assert.are.same("Content-Length: 3\r\n\r\nASD", message)
	end)

	-- it("Should get ft", function()
	-- 	local ft = vim.api.nvim_get_option_value("filetype", { buf = 1 })
	-- 	print("FT: ", vim.fn.bufnr("$"))
	-- 	assert.are.same("lua", ft)
	-- end)
end)
