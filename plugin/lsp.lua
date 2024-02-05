vim.api.nvim_create_augroup("MyLSP", { clear = true })
local ns = vim.api.nvim_create_namespace("MyLSP")

vim.api.nvim_create_autocmd("BufReadPost", {
	group = "MyLSP",
	pattern = { "*.lua" },
	callback = function(evt)
		require("client").start_lsp(evt.buf, ns)
	end,
})

vim.api.nvim_create_autocmd("BufWrite", {
	group = "MyLSP",
	pattern = { "*.lua" },
	callback = function(evt)
		require("client").send_changes(evt.buf)
	end,
})

vim.api.nvim_create_autocmd("BufDelete", {
	group = "MyLSP",
	pattern = { "*.lua" },
	callback = function(evt)
		require("client").close(evt.buf)
	end,
})
