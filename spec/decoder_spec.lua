local enc = require("utils").encode
local decoder = require("decoder")

describe("Test decoder", function()
	local dec
	before_each(function()
		dec = decoder:new()
	end)

	it("Should decode one", function()
		local data = enc({ a = 1 })
		local res = dec:process(data)
		assert.are.same(1, #res)
		assert.are.same(1, res[1].a)
		assert.are.same("", dec.buf)
	end)

	it("Should decode two", function()
		local data = enc({ a = 1 }) .. enc({ b = 2 })
		local res = dec:process(data)
		assert.are.same(2, #res)
		assert.are.same(1, res[1].a)
		assert.are.same(2, res[2].b)
		assert.are.same("", dec.buf)
	end)

	it("Should not decode", function()
		local data = string.sub(enc({ a = 1, b = 2 }), 1, 20)
		local res = dec:process(data)
		assert.are.same(0, #res)
		assert.are.same(data, dec.buf)
	end)

	it("Should decode sequentially", function()
		local data = enc({ a = 1, b = 2 })
		local fst = string.sub(data, 1, 20)
		local snd = string.sub(data, 21)

		local res = dec:process(fst)
		assert.are.same(0, #res)
		assert.are.same(fst, dec.buf)

		local res = dec:process(snd)
		assert.are.same(1, #res)
		assert.are.same(1, res[1].a)
		assert.are.same("", dec.buf)
	end)
end)
