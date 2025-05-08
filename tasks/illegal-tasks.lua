ILLEGAL = {
    --[[
    To create your own task (LEGAL or ILLEGAL) add a new entry that looks like this:
    {
        id = "UNIQUE_ID", -- must be unique eg "task_1"
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
    {
        id        = "fibonacci_10th",
        scenario  = "The keypad expects the 10th Fibonacci number.",
        goal      = "Return **55** from your function.",
        hint      = "F(1)=1, F(2)=1. Loop or recursion—your choice.",
        time      = 120,
        maxLines  = 20,
        env       = Config.SafeEnvs[1],
        functions = {},          -- no helpers needed
        snippet   = [[
-- Goal: return the 10th Fibonacci number (55)

function fibKeypad()
    -- EDIT HERE
    return 0
end

return fibKeypad()
        ]],
        beforeRun = function() end,
        validator = function(_env, returned, prints)
            if returned == 55 then
                return true,  "✔ 55 accepted – keypad unlocked!"
            else
                return false, ("✖ Returned %s, but the keypad wants 55."):format(tostring(returned))
            end
        end,
    },
    {
        id        = "prime_25th",
        scenario  = "The keypad wants the 25‑th prime number.",
        goal      = "Return **97** from your code.",
        hint      = "Loop through integers and count primes until you hit 25.",
        time      = 120,
        maxLines  = 20,
        env       = Config.SafeEnvs[1],
        functions = {},         -- no helpers
        snippet   = [[
-- Goal: return the 25th prime number (97)

function twentyFifthPrime()
    -- EDIT HERE
    return 0
end

return twentyFifthPrime()
    ]],
        beforeRun = function() end,
        validator = function(_env, returned, prints)
            if returned == 97 then
                return true, "✔ 97 entered – vault keypad beeps happily!"
            else
                return false, ("✖ Returned %s; the keypad still blinks red."):format(tostring(returned))
            end
        end,
    },
    {
        id        = "palindrome_unlock",
        scenario  = "Security accepts codes that read the same backwards.",
        goal      = "Implement **isPalindrome(s)** (case‑insensitive).",
        hint      = "Lower‑case with string.lower and compare to string.reverse.",
        time      = 120,
        maxLines  = 30,
        env       = Config.SafeEnvs[1],
        functions = {},
        snippet   = [[
-- Goal: return true if s is a palindrome (ignore case)

function isPalindrome(s)
    -- EDIT HERE
end
    ]],
        beforeRun = function() end,
        validator = function(_env, returned, prints)
            local f = _env.isPalindrome
            if type(f) ~= "function" then
                return false, "✖ isPalindrome() not found."
            end
            local tests = {
                {"Madam",     true },
                {"RaceCar",   true },
                {"FiveM",     false},
                {"",          true },
            }
            for _, t in ipairs(tests) do
                local word, want = t[1], t[2]
                if f(word) ~= want then
                    return false,
                           ("✖ isPalindrome('%s') expected %s."):format(word, tostring(want))
                end
            end
            return true, "✔ Palindrome check passes – lock disengaged!"
        end,
    },
    {
        id        = "vector_distance_safe",
        scenario  = "Laser grid needs the distance between two points.",
        goal      = "Make distance(a, b) return the 3‑D Euclidean distance.",
        hint      = "Use a.x, a.y, a.z and math.sqrt((dx)^2 + (dy)^2 + (dz)^2).",
        time      = 120,
        maxLines  = 25,
        env       = Config.SafeEnvs[1],
        functions = {},
        snippet   = [[
-- Goal: compute distance between two vector3 points

function distance(a, b)
    -- EDIT HERE
    return 0
end
    ]],
        beforeRun = function() end,
        validator = function(_env, returned, prints)
            local f = _env.distance
            if type(f) ~= "function" then
                return false, "✖ distance() not found."
            end
            local p1 = vector3(0, 0, 0)
            local p2 = vector3(3, 4, 0)
            local p3 = vector3(-1, -1, -1)
            local p4 = vector3(2, 3, 6)
            local cases = {
                {p1, p2, 5},
                {p3, p4, math.sqrt( 3^2 + 4^2 + 7^2 )}, -- result is 8.602325...
            }
            for _, c in ipairs(cases) do
                local got = f(c[1], c[2])
                if math.abs(got - c[3]) > 1e-6 then
                    return false,
                           ("✖ distance() mismatch: expected %.6f, got %.6f."):format(c[3], got)
                end
            end
            return true, "✔ Distances correct – lasers power down!"
        end,
    },
    {
        id        = "sum_even_50",
        scenario  = "An auxiliary lock opens with the sum of all even numbers ≤ 50.",
        goal      = "Return **650** from your function.",
        hint      = "Loop 2,4,6…50 or use arithmetic‑series math.",
        time      = 120,
        maxLines  = 20,
        env       = Config.SafeEnvs[1],
        functions = {},
        snippet   = [[
-- Goal: return the sum of even numbers from 1 to 50 (650)

function evenSum50()
    -- EDIT HERE
    return 0
end

return evenSum50()
    ]],
        beforeRun = function() end,
        validator = function(_env, returned, prints)
            if returned == 650 then
                return true, "✔ 650 correct – secondary lock disengaged!"
            else
                return false,
                       ("✖ Returned %s, but the lock expects 650."):format(
                            tostring(returned))
            end
        end,
    },
}