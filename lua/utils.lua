local M = {}
local json = require("json")

function M.read_buffer(bufnr)
	return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
end

function M.encode(message)
	message = json.encode(message)
	local len = string.len(message)

	return "Content-Length: " .. tostring(len) .. "\r\n\r\n" .. message
end

-- function M.decode(message, callback)
-- 	local _, _, len, data = string.find(message, "^Content%-Length: (%d+)\r\n\r\n(.*)$")

-- 	if len == nil or tonumber(len) < string.len(data) then
-- 		callback(message)
-- 		error("bad input: " .. message)
-- 	end

-- 	return json.decode(string.sub(data, 1, tonumber(len)))
-- end

function M.initialize(uri, process_id)
	return {
		method = "initialize",
		params = {
			initializationOptions = {},
			rootUri = "file://" .. uri,
			capabilities = {
				workspace = {
					workspaceFolders = false,
					configuration = false,
					symbol = {
						dynamicRegistration = false,
					},
					applyEdit = false,
					didChangeConfiguration = {
						dynamicRegistration = false,
					},
				},
				textDocument = {
					documentSymbol = {
						dynamicRegistration = false,
						hierarchicalDocumentSymbolSupport = false,
					},
					references = {
						dynamicRegistration = false,
					},
					publishDiagnostics = {
						relatedInformation = true,
					},
					rename = {
						dynamicRegistration = false,
					},
					completion = {
						completionItem = {
							snippetSupport = false,
							commitCharactersSupport = false,
							preselectSupport = false,
							deprecatedSupport = false,
							documentationFormat = {
								"plaintext",
								"markdown",
							},
						},
						contextSupport = false,
						dynamicRegistration = false,
					},
					synchronization = {
						didSave = true,
						willSaveWaitUntil = false,
						willSave = false,
						dynamicRegistration = false,
					},
					codeAction = {
						codeActionLiteralSupport = {
							codeActionKind = {
								valueSet = {},
							},
						},
						dynamicRegistration = false,
					},
					typeDefinition = {
						dynamicRegistration = false,
					},
					hover = {
						dynamicRegistration = false,
						contentFormat = {
							"plaintext",
							"markdown",
						},
					},
					implementation = {
						dynamicRegistration = false,
						linkSupport = false,
					},
					definition = {
						dynamicRegistration = false,
						linkSupport = false,
					},
				},
			},
			rootPath = uri,
			processId = process_id,
		},
	}
end

function M.find_root(bufnr, target, is_file)
	local buffer = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")

	local path
	if is_file then
		path = vim.fn.findfile(target, buffer .. ";")
	else
		path = vim.fn.finddir(target, buffer .. ";")
	end

	if path ~= "" then
		return vim.fn.fnamemodify(path .. "/", ":p:h:h")
	end

	return ""
end

return M
