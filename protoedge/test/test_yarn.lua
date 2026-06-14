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
        end)

        test('Threading Test', function()
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
    end) -- Yarn and YarnBoss
end
