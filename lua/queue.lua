local queue = {}

function queue:len()
	return self.right - self.left
end

function queue:push(obj)
	self.q[self.right] = obj
	self.right = self.right + 1
end

function queue:pop()
	if self:len() == 0 then
		return nil
	end

	local res = self.q[self.left]
	self.left = self.left + 1

	return res
end

function queue:peek()
	if self:len() == 0 then
		return nil
	end

	return self.q[self.left]
end

function queue:new()
	local res = {
		left = 1,
		right = 1,
		q = {},
	}

	self.__index = self
	return setmetatable(res, self)
end

return queue
