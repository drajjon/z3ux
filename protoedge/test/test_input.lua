-----------------------------------------------------------------------------------------
--
-- Tests: InputBoss
--
-----------------------------------------------------------------------------------------

local InputBoss = require('protoedge.input_boss')
local YarnBoss = require('protoedge.yarn_boss')
local assert = require('test.assert')

---@param dir 'left'|'right'|'up'|'down'
local function fake_dir(dir)
    InputBoss.on_input(hash(dir), { pressed = true, value = 1.0 })
end

return function()
    context('InputBoss', function()
        local in_move_results = {}

        before(function()
            in_move_results = {}
            YarnBoss.new_yarn {
                in_move = function(self, params)
                    table.insert(in_move_results, params)
                end
            }
        end)

        after(function()
            -- TODO: clear test-yarns after every test / suite
        end)

        test('basic gamepad', function()
            fake_dir('left')
            assert.same(in_move_results, {})
            coroutine.yield()
            assert.same(in_move_results, { { dx = -1, dy = 0 } })

            -- Only one move "per frame"
            in_move_results = {}
            fake_dir('up')
            fake_dir('up')
            assert.same(in_move_results, {})
            coroutine.yield()
            coroutine.yield() -- ...and they don't queue
            assert.same(in_move_results, { { dx = 0, dy = -1 } })
        end)

        -- TODO: Diagonal support
        -- TODO: need to clear out yarns :)
        print('diagonal gamepad', function()
            fake_dir('down')
            fake_dir('right')
            assert.same(in_move_results, {})
            coroutine.yield()
            assert.same(in_move_results, { { dx = 1, dy = 1 } })
        end)

        print('conflicting gamepad', function()
            fake_dir('down')
            fake_dir('up')
            assert.same(in_move_results, {})
            coroutine.yield()
            -- TBH don't care which `dy` is, as long as it's either +1 or -1
            assert.same(in_move_results, { { dx = 0, dy = -1 } })
        end)
    end) -- InputBoss
end
