require("MainEntry")

describe("FormDB", function()
	it("should be a top level table", function()
		assert.truthy(_G["FormDB"])
		assert.True(type(_G["FormDB"]) == "table")
	end)
end)

describe("Data access", function()
	describe("Allow setting values by path", function()
		it("should allow setting differet types transparently", function()
			-- Set value by simple key
			-- This should be the same as a simple assignment like t[k]=v
			assert.are.same(
				{ hello = 1 },
				table_set_by_path({}, "hello", 1))

			-- We should be able to deal with different types
			assert.are.same(
				{ hello = 1.5 },
				table_set_by_path({}, "hello", 1.5))

			-- We should be able to deal with different types
			assert.are.same(
				{ hello = "skyrim" },
				table_set_by_path({}, "hello", "skyrim"))

			assert.are.same(
				{ hello = true },
				table_set_by_path({}, "hello", true))

			-- Assign a new table
			assert.are.same(
				{ hello = { world = 1 }} ,
				table_set_by_path({}, "hello", { world = 1 }))
		end)

		it("should make setting deeply nested tables simple", function()
			assert.are.same(
				{ hello = { world = 1 }},
				table_set_by_path({}, "hello/world", 1))

			assert.are.same(
				{ hello = { small = { world = 1}} },
				table_set_by_path({}, "hello/small", { world = 1 }))

			assert.are.same(
				{ hello = { small = { world = { things = { should = { be = "easy" }}}}}},
				table_set_by_path({}, "hello/small/world/things/should/be", "easy"))
		end)

		it("should not disturb unrelated keys in the table", function()
			assert.are.same(
				{ hello = 1,
					skyui =
						{item_is_new = 1}},
				table_set_by_path({hello = 1}, "skyui/item_is_new", 1))
		end)

		it("should tolerate consecutive path separators", function()
			assert.are.same(
				{ hello = 1 },
				table_set_by_path({}, "hello//", 1))

			assert.are.same(
				{ hello = { world = 1 }},
				table_set_by_path({}, "hello//world", 1))
		end)

		it("should ignore leading or trailing path separators", function()
			assert.are.same(
				{ hello = 1 },
				table_set_by_path({}, "hello/", 1))

			assert.are.same(
				{ hello = 1 },
				table_set_by_path({}, "/hello", 1))
		end)

		it("should report errors if the path is not reachable", function()
			local result, err = table_set_by_path({hello = 1}, "hello/world", 1)
			assert.truthy(err)
			assert.True(result == nil)
		end)
	end)

	describe("Fetching data by path", function()
		it("should allow fetching values by path", function()
			assert.are.same(
				1,
				table_get_by_path({hello = 1}, "hello"))

			assert.are.same(
				1,
				table_get_by_path({hello = {world = 1}}, "hello/world"))
		end)

		it("should reply with the default value if data doesn't exist", function()
			assert.are.same(
				"not there",
				table_get_by_path({a = {b = {}}}, "b/c", "not there"))
		end)

		it("should reply with an error if the path cannot be reached", function()
			local result, err = table_get_by_path({a = {b = 1}}, "a/b/c", "not there")
			assert.are.same("not there", result)
			assert.truthy(err)
		end)
	end)

	it("should remove empty tables", function()
		assert.are.same(
			{ some_field = true },
			table_set_by_path({hello = {world = {again = 1}}, some_field = true}, "hello/world/again", nil))
	end)


end)

it("FormDB basics", function()
	FormDB_init()

	-- Associate some data with a form
	Form_SetVal(123, "inv/item_new", true)
	Form_SetVal(123, "inv/hidden", true)

	-- Fetch the data again
	assert.True(Form_GetVal(123, "inv/item_new"))

	-- The FormDB is just a table
	assert.are.same(
		{[123] =
			{inv =
				{item_new = true,
				 hidden = true }}},
		FormDB)

	-- Fetch the data again
	assert.True(Form_GetVal(123, "inv/item_new"))

	-- Fetching data that doesn't exist results in nil
	assert.is_nil(Form_GetVal(456, "inv/item_new"))

	-- Fetching data that doesn't exist can return a default value
	assert.is_equal("default", Form_GetVal(456, "inv/item_new", "default"))

	Form_RemoveField(123, "inv/item_new")
	assert.is_equal("nada", Form_GetVal(123, "inv/item_new", "nada"))

	assert.are.same(
		{[123] =
			{inv =
				{hidden = true}}},
			FormDB)

	-- FormDB is kept compacted as data is removed out of it
	Form_RemoveField(123, "inv/hidden")
	assert.are.same(
		{},
		FormDB)

	-- Removing all data associated with a FormID all at once
	Form_SetVal(123, "inv/item_new", true)
	Form_SetVal(123, "inv/hidden", true)
	Form_RemoveAllFields(123)
	assert.are.same(
		{},
		FormDB)

end)
