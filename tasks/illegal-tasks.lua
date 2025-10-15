ILLEGAL = {
    --[[
    To create your own task (LEGAL or ILLEGAL) add a new entry that looks like this:
    {
        id = "UNIQUE_ID", -- must be unique eg "hack_bank_vault"
        scenario = "Scenario description",
        goal = "Goal description",
        hint = "Hint description",
        time = 200, -- Time in seconds
        maxLines = 20, -- The maximum number of lines allowed in the editor
        env = Config.SafeEnvs[1], -- Select a safe environment from the Config
        functions = {"forceTry"}, -- If you want to use functions from the function Registry insert them here as strings
        snippet = "SNIPPET", -- The snippet for the editor as a string
        beforeRun = function()
            -- Stuff to be executed before the run
        end,
        validator = function(_env, returned, prints)
            -- Your validator implementation:
            if condition is met then 
            return true, "Success message" 
            or:
            return false, "Failure message"
        end,
    },
    ]]
    {
        id = "brute_force_vault_1",
        scenario = "Bruteforce the vault password.",
        goal = "Execute the forceTry function 200 times!",
        hint = "Use for loop.",
        time = 120,
        maxLines = 20,
        env = Config.SafeEnvs[1],
        functions = {"forceTry"}, -- functions from the function Registry
        snippet = "-- Goal: execute the forceTry function 200 times\n-- Function: forceTry()\n\nfunction startBruteforce()\n    -- EDIT HERE\nend\n\nstartBruteforce()\n",
        beforeRun = function()
            -- give every attempt a fresh counter
            Functions.forceTry.reset()
        end,
        validator = function(_env, returned, prints)
            local calls = Functions.forceTry.__dataStore.totalCalls
            if calls == 200 then
                return true,  ("✔ Well done! forceTry() called exactly %d times."  ):format(calls)
            else
                return false, ("✖ forceTry() was called %d/200 times. Try again."):format(calls)
            end
        end,
    },
    {
        id        = "drain_shield_to_zero",
        scenario  = "The vault door is protected by a 100-HP energy shield.",
        goal      = "Keep calling decreaseShield() until it returns exactly 0.\n" ..
                    "Stop immediately when that happens (10 calls total).",
        hint      = "Use a while-loop that checks the return value.",
        time      = 120,
        maxLines  = 20,
        env       = Config.SafeEnvs[1],
        functions = {"decreaseShield"},
        snippet   = [[
-- Goal: drain the shield to 0 using decreaseShield()
-- Function: decreaseShield() -> returns remaining HP

function weakenShield()
    -- EDIT HERE
end

weakenShield()
        ]],
        beforeRun = function()
            Functions.decreaseShield.reset()
        end,
        validator = function(_env, returned, prints)
            local ds = Functions.decreaseShield.__dataStore
            if ds.value == 0 and ds.calls == 10 then
                return true, ("✔ Shield drained in %d calls. Door is vulnerable!"):format(ds.calls)
            else
                return false, ("✖ Shield value=%d, calls=%d (need value 0 in 10 calls)."):format(ds.value, ds.calls)
            end
        end,
    },
    {
        id        = "alternating_blows_20",
        scenario  = "Disable the guard with a flawless left-right combo.",
        goal      = "Call leftPunch() and rightPunch() **alternating**—L,R,L,R…—\n" ..
                    "for exactly 20 total calls (10 each).",
        hint      = "Inside a for-loop, use modulo (i % 2) to choose the side.",
        time      = 120,
        maxLines  = 20,
        env       = Config.SafeEnvs[1],
        functions = {"leftPunch", "rightPunch"},
        snippet   = [[
-- Goal: alternate leftPunch() and rightPunch() 20 times
-- Functions: leftPunch()  |  rightPunch()

function knockoutCombo()
    -- EDIT HERE
end

knockoutCombo()
        ]],
        beforeRun = function()
            Functions.leftPunch.reset()
            Functions.rightPunch.reset()
        end,
        validator = function(_env, returned, prints)
            local l = Functions.leftPunch.__dataStore
            local r = Functions.rightPunch.__dataStore
            local seq = l.seq  -- both share same sequence length
            local okPattern = true
            for i, tag in ipairs(seq) do
                if (i % 2 == 1 and tag ~= "L") or (i % 2 == 0 and tag ~= "R") then
                    okPattern = false
                    break
                end
            end
            if l.total == 10 and r.total == 10 and #seq == 20 and okPattern then
                return true, "✔ Combo executed perfectly—guard is out cold!"
            else
                return false, "✖ Incorrect punch pattern or counts. Try again."
            end
        end,
    },
}