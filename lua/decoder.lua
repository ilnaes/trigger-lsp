local decoder = {}
local json = require("json")

function decoder:process(data)
	local message = self.buf .. data
	self.buf = message
	local res = {}

	while true do
		local _, j, len = string.find(message, "^Content%-Length: (%d+)\r\n\r\n")

		if j == nil then
			return res
		end

		local l = tonumber(len)
		if l == 0 or l > string.len(message) - j then
			return res
		end

		res[#res + 1] = json.decode(string.sub(message, j + 1, j + l))

		message = string.sub(message, j + l + 1)
		self.buf = message
	end
end

function decoder:new()
	local res = {
		buf = "",
	}
	self.__index = self
	return setmetatable(res, self)
end

return decoder
