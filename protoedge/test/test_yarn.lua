-----------------------------------------------------------------------------------------
--
-- Tests: Yarn and YarnBoss
--
-----------------------------------------------------------------------------------------

local YarnBoss = require('protoedge.yarn_boss')
local assert = require('test.assert')

return function()
    context('Yarn and YarnBoss', function()
        before(function()
        end)

        after(function()
            -- TODO: test for yarns clearing out of pool
            -- TODO: clear test-yarns after every test / suite
        end)

        test('basic threading', function()
            local a, b = 0, 0
            local yarn_a = YarnBoss.new_yarn { start = function(self)
                a = a + 1
                self:idle()
                a = a + 1
                self:idle()
                a = a + 1
            end }
            local yarn_b = YarnBoss.new_yarn { start = function(self)
                b = b + 1
                self:idle(2)
                b = b + 1
            end }
            assert.equal(0, a) -- Not started yet!
            assert.equal(0, b)
            coroutine.yield()  -- This finishes out the current fixed_update cycle and then reenters the test
            assert.equal(1, a)
            assert.equal(1, b)
            coroutine.yield()
            assert.equal(2, a)
            assert.equal(1, b)
            coroutine.yield()
            assert.equal(3, a)
            assert.equal(2, b)
            coroutine.yield() -- Yarns should auto-terminate at end
            coroutine.yield()
            coroutine.yield()
            assert.equal(3, a)
            assert.equal(2, b)
        end)

        test('basic messaging', function()
            local a, b = 0, 0
            local hello ---@type string?
            local yarn_a = YarnBoss.new_yarn {
                start = function(self)
                    repeat
                        a = a + 1
                        self:idle()
                    until false
                end,
                hello = function(self, params)
                    hello = params.abc
                end
            }
            local yarn_b = YarnBoss.new_yarn {
                start = function(self)
                    repeat
                        b = b + 1
                        self:idle()
                    until false
                end
            }
            -- Verify pre-event state
            coroutine.yield()
            coroutine.yield()
            assert.equal(2, a)
            assert.equal(2, b)
            -- Event sends, yarn b continues
            YarnBoss.send('hello', { abc = 'xyz' })
            assert.is_nil(hello)
            coroutine.yield()
            assert.equal(2, a)
            assert.equal(3, b)
            assert.equal('xyz', hello)
            -- Yarn a does nothing, yarn b continues
            hello = 'shh'
            coroutine.yield()
            assert.equal(2, a)
            assert.equal(4, b)
            assert.equal('shh', hello)
            -- Event works again after a delay
            coroutine.yield()
            YarnBoss.send('hello', { abc = 'xyz' })
            coroutine.yield()
            assert.equal(2, a)
            assert.equal('xyz', hello)
        end)
    end) -- Yarn and YarnBoss
end
