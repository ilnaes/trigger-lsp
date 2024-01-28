vim.api.nvim_create_augroup("MyLSP", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
	group = "MyLSP",
	callback = function()
		if os.getenv("LSP") == "TEST" and vim.bo.filetype == "lua" then
			require("lsp").start_lsp()
		end
	end,
})
