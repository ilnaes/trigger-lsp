vim.api.nvim_create_augroup("MyLSP", { clear = true })
local ns = vim.api.nvim_create_namespace("MyLSP")

vim.api.nvim_create_autocmd("BufEnter", {
	group = "MyLSP",
	callback = function(evt)
		if os.getenv("LSP") == "TEST" and vim.bo.filetype == "lua" then
			require("lsp").start_lsp(evt.buf, ns)
		end
	end,
})
vim.api.nvim_create_autocmd("BufWritePost", {
	group = "MyLSP",
	callback = function(evt)
		if os.getenv("LSP") == "TEST" and vim.bo.filetype == "lua" then
			require("lsp").send_changes(evt.buf)
		end
	end,
})
