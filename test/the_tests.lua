local deftest = require('deftest.deftest')

---@pkg TheTests
local TheTests = {}
local test_phase = 'start' ---@type string?
TheTests.test_failures = false

---@return bool done true once tests are complete, false if you should call this again on the next update
function TheTests.run_or_resume()
    if test_phase then
        local test_result ---@type any?
        if test_phase == 'start' then
            -- LOAD ALL TESTS HERE
            deftest.add(require('protoedge.test.test_layer'))
            deftest.add(require('protoedge.test.test_yarn'))
            -- (end test loading)

            test_result = deftest.run({ no_exit = true })
            if not test_result then -- nil (or something returned from a yield)
                test_phase = 'run'
            end
        elseif test_phase == 'run' then
            test_result = deftest.resume()
        end
        if test_result then  -- 0 or 1
            test_phase = nil -- 'done'
            if test_result == 1 then
                TheTests.test_failures = true
            end
            return true -- done
        end
    end
    return false
end

return TheTests
