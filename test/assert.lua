--
-- Extra assert methods for testing and debug builds
--

local telescope = require('deftest.telescope')
local tasserts = telescope.get_assertions()

-- Most functions are stubs, calling `assert_*` methods that are normally injected into the test environment via `telescope.lua`
-- and therefore do not normally function outside of tests. They still work inside tests- calling the telescope variants
-- ensures `assertion_callback` gets called and tests can track assertions.
--
-- IMPORTANT: These throw tables as errors, so outside tests you may want a top-level error handler.
local global_assert = function(self, ...) return tasserts.assert(...) end
local assert = {}
setmetatable(assert, { __call = global_assert }) -- Allow assert(...) calling style

--
-- From `deftest/telescope.lua`
--

-- Assert is `nil` or `''`.
---@param value any
function assert.blank(value) tasserts.assert_blank(value) end

-- Assert is `{}`.
---@param value any
function assert.empty(value) tasserts.assert_empty(value) end

-- Assert calling `func()` throws an error, optionally checking for equality of error message thrown.
---@param func function
---@param error any?
function assert.error(func, error) tasserts.assert_error(func, error) end

-- Assert calling `func()` throws an error that matches a regex pattern.
---@param func function
---@param pattern string
function assert.error_matches(func, pattern) tasserts.assert_error_matches(func, pattern) end

-- Assert is `false` specifically. (`nil` will not count)
---@param value any
function assert.is_false(value) -- intentional clarification of name
    tasserts.assert_false(value)
end

-- Assert is `false` or `nil`.
---@param value any
function assert.falsy(value) -- extension of `assert_false`
    tasserts.assert_false(value and true or false)
end

-- Assert `a > b`.
---@param a any
---@param b any
function assert.greater_than(a, b) tasserts.assert_greater_than(a, b) end

-- Assert `a >= b`.
---@param a any
---@param b any
function assert.gte(a, b) tasserts.assert_gte(a, b) end

-- Assert `a < b`.
---@param a any
---@param b any
function assert.less_than(a, b) tasserts.assert_less_than(a, b) end

-- Assert `a <= b`.
---@param a any
---@param b any
function assert.lte(a, b) tasserts.assert_lte(a, b) end

-- Assert that a value, as a string, matches the regex in `pattern`.
---@param pattern string
---@param value any
function assert.match(pattern, value) tasserts.assert_match(pattern, value) end

-- Assert is `nil` specifically.
---@param value any
---@param message string?
function assert.is_nil(value, message) tasserts.assert_is_nil(value, message) end

-- Assert is `true` specifically.
---@param value any
function assert.is_true(value) -- intentional clarification of name
    tasserts.assert_true(value)
end

-- Assert is truthy e.g. neither `false` nor `nil`.
---@param value any
function assert.truthy(value) -- extension of `assert_truthy`
    tasserts.assert_true(value and true or false)
end

-- Assert that a value has a given `type(...)`.
---@param value any
---@param type string
function assert.type(value, type) tasserts.assert_type(value, type) end

-- Assert is neither `nil` nor `''`.
---@param value any
function assert.not_blank(value) tasserts.assert_not_blank(value) end

-- Assert is a table with at least one element.
---@param value any
function assert.not_empty(value) tasserts.assert_not_empty(value) end

-- Assert `expected ~= actual`.
---@param expected any
---@param actual any
function assert.not_equal(expected, actual) tasserts.assert_not_equal(expected, actual) end

-- Assert calling `func()` does not throw an error.
---@param func function
function assert.not_error(func) tasserts.assert_not_error(func) end

-- Assert that a value, as a string, does not match the regex in `pattern`.
---@param value any
---@param pattern any
function assert.not_match(pattern, value) tasserts.assert_not_match(pattern, value) end

-- Assert is anything other than `nil`.
---@param value any
---@param message string?
function assert.not_nil(value, message) tasserts.assert_not_nil(value, message) end

-- Assert that a value does not have the given `type(...)`.
---@param value any
---@param type string
function assert.not_type(value, type) tasserts.assert_not_type(value, type) end

--
-- From `deftest/deftest.lua`
--

-- Assert `expected == actual`, with deep compare of tables. THIS IS NOT HIGHLY PERFORMANT, do NOT use outside debug/tests!
---@param expected any
---@param actual any
---@param ... any Additional values to compare to the others (all must be same)
function assert.same(expected, actual, ...) tasserts.assert_same(expected, actual, ...) end

-- Assert `expected ~= actual`, with deep compare of tables. THIS IS NOT HIGHLY PERFORMANT, do NOT use outside debug/tests!
---@param expected any
---@param actual any
---@param ... any Additional values to compare to the others (all must be unique)
function assert.unique(expected, actual, ...) tasserts.assert_unique(expected, actual, ...) end

-- Assert `expected == actual`.
---@param expected any
---@param actual any
---@param message string?
function assert.equal(expected, actual, message) tasserts.assert_equal(expected, actual, message) end

return assert
