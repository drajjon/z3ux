local deftest = require('deftest.deftest')
local YarnBoss = require('protoedge.yarn_boss')

---@pkg TheTests
local TheTests = {}
local test_phase = 'start' ---@type string?
---@type nil|'success'|'warning'|'fail'
TheTests.test_status = nil
TheTests.test_summary = nil ---@type string?

---@return bool done true once tests are complete, false if you should call this again on the next update
function TheTests.run_or_resume()
    if test_phase then
        local test_result ---@type any?
        if test_phase == 'start' then
            -- LOAD ALL TESTS HERE
            deftest.add(require('protoedge.test.test_input'))
            deftest.add(require('protoedge.test.test_layer'))
            deftest.add(require('protoedge.test.test_yarn'))
            -- (end test loading)

            test_result = deftest.run({ no_exit = true })
            if not test_result then
                test_phase = 'run'
            end
        elseif test_phase == 'run' then
            test_result = deftest.resume()
        end
        if test_result then  -- 0 or 1
            test_phase = nil -- 'done'
            if test_result == 1 then
                TheTests.test_status = 'fail'
            else
                local yarns = YarnBoss.get_active_yarns()
                if yarns > 0 then
                    TheTests.test_status = 'warning'
                    TheTests.test_summary = string.format('CLEANUP: %s orphan yarn(s)', yarns)
                else
                    TheTests.test_status = 'success'
                end
            end
            return true -- done
        end
    end
    return false
end

return TheTests
