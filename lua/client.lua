local utils = require("utils")
local lsp = require("lsp")

local clients = {}
local versions = {}

local M = {}

function M.start_lsp(bufnr, ns)
	local name = lsp.get_client_name(bufnr)
	local client

	if clients[name] == nil then
		client = lsp:new(0, ns)
		clients[name] = client
		client:start()
	else
		client = clients[name]
	end
	versions[bufnr] = 2

	local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")
	local data = utils.read_buffer(bufnr)
	client.q:push({
		payload = {
			method = "textDocument/didOpen",
			params = {
				uri = "file://" .. filename,
				version = 1,
				languageId = "lua",
				text = data,
			},
		},
		notification = true,
	})
	client:flush()
	M.send_changes(bufnr)
end

function M.close(bufnr)
	local name = lsp.get_client_name(bufnr)
	local client = clients[name]
	local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")

	client.q:push({
		payload = {
			method = "textDocument/didClose",
			params = {
				textDocument = {
					uri = "file://" .. filename,
				},
			},
		},
		notification = true,
	})
	client:flush()

	versions[bufnr] = nil
end

function M.send_changes(bufnr)
	local name = lsp.get_client_name(bufnr)
	local client = clients[name]
	local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")
	local data = utils.read_buffer(bufnr)

	client.q:push({
		payload = {
			method = "textDocument/didChange",
			params = {
				textDocument = {
					uri = "file://" .. filename,
					version = versions[bufnr],
				},
				contentChanges = { { text = data } },
			},
		},
		notification = true,
	})
	client:flush()

	versions[bufnr] = versions[bufnr] + 1
end

return M
