local uv = vim.loop
local encode = require("utils").encode
local json = require("json")
local utils = require("utils")

local progs = {
	lua = "lua-language-server",
}

local clients = {}

local function get_client_name(bufnr)
	local root = utils.find_root(bufnr)
	local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

	if root == "" or progs[ft] == nil then
		return ""
	else
		return root .. ":" .. progs[ft]
	end
end

Lsp = {}
function Lsp:send(message, notification)
	message.jsonrpc = "2.0"

	if notification then
		message.id = self.idx
		self.idx = self.idx + 1
	end

	local data = encode(json.encode(message))
	uv.write(self.stdin, data)
	uv.fs_write(self.infile, data .. "\n")
	uv.fs_write(self.infile, "-----------" .. "\n")
end

function Lsp:send_init()
	local uri = utils.find_root(vim.api.nvim_get_current_buf(), ".git", false)
	local init_req = utils.initialize(uri, 1)
	self:send(init_req, true)
end

function Lsp:handle_message(data)
	if data then
		uv.fs_write(self.outfile, data .. "\n")
		uv.fs_write(self.outfile, "-----------" .. "\n")
	end
end

function Lsp:new(bufnr)
	local name = get_client_name(bufnr)
	local lsp = {
		idx = 1,
		name = name,
		initialized = false,
	}

	self.__index = self
	return setmetatable(lsp, self)
end

function Lsp:start()
	self.stdin = uv.new_pipe()
	self.stdout = uv.new_pipe()
	self.infile = uv.fs_open("in", "w", 438)
	self.outfile = uv.fs_open("out", "w", 438)

	local handle, pid = uv.spawn("lua-language-server", {
		stdio = { self.stdin, self.stdout },
	}, function() -- on exit
		uv.fs_close(self.outfile)
	end)

	uv.read_start(self.stdout, function(err, data)
		assert(not err, err)
		self:handle_message(data)
	end)

	self:send_init()
end

local M = {}

function M.start_lsp()
	print("START")
	local name = get_client_name(0)
	if clients[name] == nil then
		local client = Lsp:new(0)
		clients[name] = client
		client:start()
	end
end

return M

-- local initialized = [[
-- {
--   "jsonrpc": "2.0",
--   "method": "initialized",
--   "params": {}
-- }
-- ]]

-- local reqs = { initReq, initialized }

-- local function process(arr)
-- 	if next(arr) == nil then
-- 		return
-- 	end

-- 	uv.write(stdin, encode(arr[1]))
-- 	local timer = uv.new_timer()
-- 	timer:start(2000, 0, function()
-- 		table.remove(arr, 1)
-- 		process(arr)
-- 		timer:close()
-- 	end)
-- end

-- process(reqs)
