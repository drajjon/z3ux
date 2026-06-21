-----------------------------------------------------------------------------------------
--
-- Tests: InputBoss
--
-----------------------------------------------------------------------------------------
local SmoothInput = require('input.smooth_input')
local InputBoss = require('input.input_boss')
local YarnBoss = require('protoedge.yarn_boss')
local assert = require('test.assert')

---@param dir 'left'|'right'|'up'|'down'
local function fake_dir(dir)
    InputBoss.on_input(hash(dir), { pressed = true, value = 1.0 })
end

return function()
    context('InputBoss', function()
        local in_move_results = {}
        local move_yarn ---@type Yarn?
        local input_handler ---@type IInputHandler?

        before(function()
            input_handler = SmoothInput.new()
            in_move_results = {}
            move_yarn = YarnBoss.new_yarn{
                in_move = function(self, params)
                    table.insert(in_move_results, params)
                end,
            }
        end)

        after(function()
            if input_handler then
                InputBoss.unregister_handler(input_handler)
                input_handler = nil
            end
            if move_yarn then
                move_yarn:die()
                move_yarn = nil
            end
        end)

        print('basic gamepad', function()
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
