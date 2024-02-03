local M = {}

function M.get_diagnostics(diagnostics, bufnr)
	local res = {}

	for _, d in ipairs(diagnostics) do
		table.insert(res, {
			bufnr = bufnr,
			lnum = d.range["start"].line,
			end_lnum = d.range["end"].line,
			col = d.range["start"].character,
			end_col = d.range["end"].character,
			severity = d.severity,
			message = d.message,
			source = d.source,
			code = d.code,
		})
	end

	return res
end

function M.show_diagnostics(params, ns)
	vim.schedule(function()
		local filepath = string.sub(params.uri, 8)
		local bufnr = vim.fn.bufnr(filepath)
		local diagnostics = M.get_diagnostics(params.diagnostics, bufnr)

		vim.diagnostic.set(ns, bufnr, diagnostics, {
			virtual_text = true,
		})
	end)
end

return M
