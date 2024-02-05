local queue = require("queue")
local diagnostics = require("diagnostics")
local uv = vim.loop
local encode = require("utils").encode
local json = require("json")
local decoder = require("decoder")
local utils = require("utils")

local progs = {
	lua = "lua-language-server",
}

--- Generates a unique name for a buffer
--- given by the project root and the program
---@param bufnr integer buffer number

local lsp = {}
function lsp:send(message, notification)
	message.jsonrpc = "2.0"

	if not notification then
		message.id = self.idx
		self.idx = self.idx + 1
	end

	local data = encode(message)
	uv.write(self.stdin, data)
	uv.fs_write(self.logfile, "SENDING\n")
	uv.fs_write(self.logfile, data .. "\n")
	uv.fs_write(self.logfile, "-----------" .. "\n")
end

function lsp:send_init()
	local uri = utils.find_root(vim.api.nvim_get_current_buf(), ".git", false)
	local init_req = utils.initialize(uri, 1)
	self:send(init_req, false)
end

function lsp:flush()
	if not self.initialized then
		return
	end

	local message = self.q:pop()
	while message ~= nil do
		self:send(message.payload, message.notification)
		message = self.q:pop()
	end
end

function lsp:handle_message(message)
	uv.fs_write(self.logfile, "GOT\n")
	uv.fs_write(self.logfile, json.encode(message) .. "\n")

	if message.result ~= nil then
		if message.result.capabilities ~= nil and not self.initialized then
			self:send({ method = "initialized", params = {} }, true)
			self.initialized = true
			self:flush()
		end
	else
		if message.method == "textDocument/publishDiagnostics" then
			diagnostics.show_diagnostics(message.params, self.ns)
		end
	end
end

--- Converts string input to messages to be processed
---@param data string input from server
function lsp:process_input(data)
	uv.fs_write(self.logfile, "RECEIVING\n")
	uv.fs_write(self.logfile, data .. "\n")

	local messages = self.dec:process(data)

	for _, message in ipairs(messages) do
		self:handle_message(message)
	end
	uv.fs_write(self.logfile, "-----------" .. "\n")
end

function lsp:new(bufnr, ns)
	local name = self.get_client_name(bufnr)
	local obj = {
		idx = 1,
		name = name,
		initialized = false,
		dec = decoder:new(),
		q = queue:new(),
		ns = ns,
	}

	self.__index = self
	return setmetatable(obj, self)
end

function lsp:start()
	self.stdin = uv.new_pipe()
	self.stdout = uv.new_pipe()
	self.logfile = uv.fs_open("log", "w", 438)
	self.errfile = uv.fs_open("err", "w", 438)

	local handle, pid = uv.spawn("lua-language-server", {
		stdio = { self.stdin, self.stdout },
	}, function() -- on exit
		uv.fs_close(self.outfile)
	end)

	uv.read_start(self.stdout, function(err, data)
		assert(not err, err)
		if data then
			self:process_input(data)
		end
	end)

	self:send_init()
end

function lsp.get_client_name(bufnr)
	local root = utils.find_root(bufnr)
	local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

	if root == "" or progs[ft] == nil then
		return ""
	else
		return root .. ":" .. progs[ft]
	end
end

return lsp
