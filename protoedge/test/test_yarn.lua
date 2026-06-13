-----------------------------------------------------------------------------------------
--
-- Tests: Yarn and YarnBoss
--
-----------------------------------------------------------------------------------------

local YarnBoss = require('protoedge.yarn_boss')

return function()
    context('Yarn and YarnBoss', function()
        before(function()
        end)

        after(function()
        end)

        test('test example', function()
            assert(true)
            coroutine.yield()
            assert(true)
        end)
    end) -- Yarn and YarnBoss
end
