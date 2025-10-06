--------------------------------------------------------------------------------
-- Globals
--------------------------------------------------------------------------------
_G.Functions = {}
_G.Functions.__functionRegistry = {}

--------------------------------------------------------------------------------
-- Function Registry
--------------------------------------------------------------------------------

--[[
    Function Registry
    ================

    This is the place where you can make functions which can be added to a task.
    The functions will be available in the task's environment.

    To make a new Function first create a new array:

    Functions.hit = {}

    Then if needed add Datastore to for example track progress:

    Functions.hit.__dataStore = {total_hits = 0}

    Then add the function:

    Functions.hit.func = function()
        -- With Datastore you can do:
        local d = Functions.hit.__dataStore.total_hits
        d = d + 1
    end

    And finally add the reset function:

    Functions.hit.reset = function()
        -- With Datastore you can do:
        Functions.hit.__dataStore.total_hits = 0
    end

    Now You can add additional functions to the task:

    Functions.hit.additional.get_hits = function()
        return Functions.hit.__dataStore.total_hits
    end
]]--

---@function Functions.forceTry.func 
---@function Functions.forceTry.reset
Functions.forceTry = {__dataStore = {totalCalls = 0}, additional = {}}
Functions.forceTry.func = function()
    local total = Functions.forceTry.__dataStore.totalCalls
    Functions.forceTry.__dataStore.totalCalls = total + 1
    return Functions.forceTry.__dataStore.totalCalls
end
Functions.forceTry.reset = function()
    Functions.forceTry.__dataStore.totalCalls = 0
end

Functions.forceTry.additional.get_calls = function() 
    return Functions.forceTry.__dataStore.totalCalls
end

-- -- -- --

---@function Functions.decreaseShield.func
---@function Functions.decreaseShield.reset
Functions.decreaseShield = {__dataStore = {value = 100, calls = 0}, additional = {}}
Functions.decreaseShield.func = function()
    local v = math.max(0, Functions.decreaseShield.__dataStore.value - 10)
    Functions.decreaseShield.__dataStore.value = v
    Functions.decreaseShield.__dataStore.calls = Functions.decreaseShield.__dataStore.calls + 1
    return v
end
Functions.decreaseShield.reset = function()
    Functions.decreaseShield.__dataStore.value  = 100
    Functions.decreaseShield.__dataStore.calls  = 0
end

-- -- -- --

---@function Functions.leftPunch.func
---@function Functions.rightPunch.func
---@function Functions.leftPunch.reset
---@function Functions.rightPunch.reset
Functions.leftPunch  = {__dataStore  = {total = 0, seq = {}}, additional = {}}
Functions.rightPunch = {__dataStore = {total = 0, seq = {}}, additional = {}}
local function makePunch(sideTag, store)
    return function()
        store.total  = store.total  + 1
        store.seq[#store.seq + 1] = sideTag
    end
end
Functions.leftPunch.func  = makePunch("L", Functions.leftPunch.__dataStore)
Functions.rightPunch.func = makePunch("R", Functions.rightPunch.__dataStore)
Functions.leftPunch.reset  = function()
    Functions.leftPunch.__dataStore.total = 0
    Functions.leftPunch.__dataStore.seq   = {}
end
Functions.rightPunch.reset = function()
    Functions.rightPunch.__dataStore.total = 0
    Functions.rightPunch.__dataStore.seq   = {}
end

-- -- -- --

-- Registry registration
_G.Functions.__functionRegistry = {
    ["forceTry"]      = Functions.forceTry,
    ["decreaseShield"]= Functions.decreaseShield,
    ["leftPunch"]     = Functions.leftPunch,
    ["rightPunch"]    = Functions.rightPunch,
}
