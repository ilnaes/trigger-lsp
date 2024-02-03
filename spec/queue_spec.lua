local queue = require("queue")

describe("Test queue", function()
	local q

	before_each(function()
		q = queue:new()
	end)

	it("Should initialize empty", function()
		assert.are.same(0, q:len())
	end)

	it("Should manipulate correctly", function()
		assert.are.same(0, q:len())
		assert.are.same(nil, q:pop())
		q:push(1)
		assert.are.same(1, q:peek())

		q:push(2)

		assert.are.same(2, q:len())
		assert.are.same(1, q:peek())

		local res = q:pop()

		assert.are.same(1, res)
		assert.are.same(1, q:len())
		assert.are.same(2, q:peek())

		local _ = q:pop()
		assert.are.same(nil, q:pop())
		assert.are.same(0, q:len())
	end)
end)
