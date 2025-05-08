-- Variables
_G.Functions = {}
_G.Functions.__functionRegistry = {}

-- Functions

---@function Functions.forceTry.func 
---@function Functions.forceTry.reset
Functions.forceTry = {}
Functions.forceTry.__dataStore = {totalCalls = 0}
Functions.forceTry.func = function()
    local total = Functions.forceTry.__dataStore.totalCalls
    total = total + 1
    Functions.forceTry.__dataStore.totalCalls = total
    return Functions.forceTry.__dataStore.totalCalls
end
Functions.forceTry.reset = function()
    Functions.forceTry.__dataStore.totalCalls = 0
end

-- -- -- --

---@function Functions.decreaseShield.func
---@function Functions.decreaseShield.reset
Functions.decreaseShield = {}
Functions.decreaseShield.__dataStore = {value = 100, calls = 0}
Functions.decreaseShield.func = function()
    local v = math.max(0, Functions.decreaseShield.__dataStore.value - 10)
    Functions.decreaseShield.__dataStore.value = v
    Functions.decreaseShield.__dataStore.calls =
        Functions.decreaseShield.__dataStore.calls + 1
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
Functions.leftPunch  = {}
Functions.rightPunch = {}
local function makePunch(sideTag, store)
    return function()
        store.total  = store.total  + 1
        store.seq[#store.seq + 1] = sideTag
    end
end
Functions.leftPunch.__dataStore  = {total = 0, seq = {}}
Functions.rightPunch.__dataStore = {total = 0, seq = {}}
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
