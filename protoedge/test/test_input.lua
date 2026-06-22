-----------------------------------------------------------------------------------------
--
-- Tests: InputBoss
--
-----------------------------------------------------------------------------------------
local SmoothInput = require('input.smooth_input')
local InputBoss = require('input.input_boss')
local YarnBoss = require('protoedge.yarn_boss')
local assert = require('test.assert')

---@param dir direction
---@param magnitude number?
local function press_dir(dir, magnitude)
    InputBoss.on_input(hash(dir), { pressed = true, value = magnitude or 1.0 })
end

---@param dir direction
---@param magnitude number?
local function hold_dir(dir, magnitude)
    InputBoss.on_input(hash(dir), { value = magnitude or 1.0 })
end

---@param dir direction
local function release_dir(dir)
    InputBoss.on_input(hash(dir), { released = true, value = 0 })
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

        test('basic gamepad', function()
            press_dir('left')
            assert.same(in_move_results, {})
            coroutine.yield()
            local SPEED = 0.25
            local LEFT = { dx = -SPEED, dy = 0, v = vmath.vector3(-SPEED,0,0) }
            assert.same(in_move_results, { LEFT })
            coroutine.yield()
            assert.same(in_move_results, { LEFT, LEFT })
            hold_dir('left')
            coroutine.yield()
            assert.same(in_move_results, { LEFT, LEFT,LEFT })
            release_dir('left')
            coroutine.yield()
            assert.same(in_move_results, { LEFT, LEFT, LEFT })

            -- Only one move "per frame"
            in_move_results = {}
            press_dir('up')
            press_dir('up')
            hold_dir('up')
            assert.same(in_move_results, {})
            coroutine.yield()
            local UP = { dx = 0, dy = -SPEED, v = vmath.vector3(0,-SPEED,0) }
            assert.same(in_move_results, { UP })
        end)

        -- TODO: Diagonal support
        -- TODO: need to clear out yarns :)
        print('diagonal gamepad', function()
            press_dir('down')
            press_dir('right')
            assert.same(in_move_results, {})
            coroutine.yield()
            assert.same(in_move_results, { { dx = 1, dy = 1 } })
        end)

        print('conflicting gamepad', function()
            press_dir('down')
            press_dir('up')
            assert.same(in_move_results, {})
            coroutine.yield()
            -- TBH don't care which `dy` is, as long as it's either +1 or -1
            assert.same(in_move_results, { { dx = 0, dy = -1 } })
        end)
    end) -- InputBoss
end
