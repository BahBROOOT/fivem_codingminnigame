LEGAL = {
    {
        id        = "fix_addition_bug",
        scenario  = "A sloppy intern broke the keypad math.",
        goal      = "Make addNumbers(a, b) return **a + b** for any numbers.",
        hint      = "There are exactly **three** typos in the starter code.",
        time      = 120,
        maxLines  = 20,
        env       = Config.SafeEnvs[1],
        functions = {},                     -- no helpers needed
        snippet   = [[
-- Goal: fix this function so it returns a + b
-- There are exactly THREE typos.
fucntion addNumbers(a, b)
    retrun a - b
end
        ]],
        beforeRun = function() end,
        validator = function(_env, returned, prints)
            local f = _env.addNumbers
            if type(f) ~= "function" then
                return false, "✖ Function addNumbers() was not found."
            end
            local tests = {
                {10,  2}, {-3, 7}, {0, 0}, {101, 99},
            }
            for _, t in ipairs(tests) do
                if f(t[1], t[2]) ~= (t[1] + t[2]) then
                    return false, "✖ addNumbers() still adds wrong. Check your fixes."
                end
            end
            return true, "✔ addNumbers() fixed – keypad happy!"
        end,
    },
    {
        id        = "fix_factorial_bug",
        scenario  = "The vault’s code wheel expects n! but the script is off-by-one…and worse.",
        goal      = "Make factorial(n) return **n!** for 0 ≤ n ≤ 10.",
        hint      = "Six typos + a logic error on n == 0.",
        time      = 150,
        maxLines  = 30,
        env       = Config.SafeEnvs[1],
        functions = {},
        snippet   = [[
-- Goal: return n! (factorial)
-- SIX typos and an off-by-one bug lurk below.
fucntion factorial(n)
    if n == 0 then
        retrun 0         -- logic bug: 0! should be 1
    en
    local reslt = 1
    for i = 2, n do
        result = result * i   -- var name mismatch
    emd
    retur result
end
        ]],
        beforeRun = function() end,
        validator = function(_env, returned, prints)
            local f = _env.factorial
            if type(f) ~= "function" then
                return false, "✖ factorial() not found."
            end
            local correct = {1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800}
            for n = 0, 10 do
                if f(n) ~= correct[n + 1] then
                    return false,
                        ("✖ factorial(%d) returned %s, expected %d.")
                        :format(n, tostring(f(n)), correct[n + 1])
                end
            end
            return true, "✔ factorial() fixed – code wheel spins freely!"
        end,
    },
    {
        id        = "fix_sum_array_bug",
        scenario  = "The vault scale reads total weight, but the helper code mis-adds.",
        goal      = "Make sumArray(t) return the **sum of all numeric elements** in table *t*.",
        hint      = "Six typos: bad keywords, misspelled API, wrong operator, bad var names.",
        time      = 150,
        maxLines  = 35,
        env       = Config.SafeEnvs[1],
        functions = {},          -- no helpers needed
        snippet   = [[
-- Goal: return the sum of numbers in table t
-- Six typos + one operator error lurk below.

functon sumArray(t)
    -- handle nil input gracefully
    if t == nill then
        return 0
    end

    local total == 0   -- wrong operator (== instead of =)

    -- iterate over list-style table
    for i, v in iprairs(t) do  -- API misspelled
        totl = totl + v        -- variable name mismatch
    end

    retern total
end
        ]],
        beforeRun = function() end,
        validator = function(_env, returned, prints)
            local f = _env.sumArray
            if type(f) ~= "function" then
                return false, "✖ sumArray() not found."
            end
    
            local tests = {
                { {},                 0 },
                { {1, 2, 3},          6 },
                { {-5, 5},            0 },
                { {10},              10 },
                { {4, 1, -2, 7, 0},  10 },
            }
    
            for _, case in ipairs(tests) do
                local input, want = case[1], case[2]
                -- copy to avoid mutation side effects
                local copy = {table.unpack(input)}
                local got  = f(copy)
                if got ~= want then
                    return false,
                        ("✖ sumArray({%s}) returned %s; expected %s.")
                        :format(table.concat(copy, ","), tostring(got), want)
                end
            end
            return true, "✔ sumArray() fixed – scale now reads correctly!"
        end,
    },
    {
        id        = "fix_concat_string_bug",
        scenario  = "Name‑badge printer joins first + last names, but outputs gibberish.",
        goal      = "Fix **concatStr(a, b)** to return `a .. \" \" .. b`.",
        hint      = "Four typos & wrong operator.",
        time      = 120,
        maxLines  = 25,
        env       = Config.SafeEnvs[1],
        functions = {},
        snippet   = [[
-- Goal: concatenate two strings with exactly **one space** between them.
-- Four typos + wrong operator below.

fuunction concatStr(first, last)
    retunr first + " " + last   -- uses + instead of ..
end
    ]],
        beforeRun = function() end,
        validator = function(_env, returned, prints)
            local f = _env.concatStr
            if type(f) ~= "function" then
                return false, "✖ concatStr() not found."
            end
            local cases = {
                {"John",  "Doe",  "John Doe"},
                {"FiveM", "Heist", "FiveM Heist"},
            }
            for _, c in ipairs(cases) do
                if f(c[1], c[2]) ~= c[3] then
                    return false,
                           ("✖ concatStr('%s','%s') returned '%s'.")
                           :format(c[1], c[2], tostring(f(c[1], c[2])))
                end
            end
            return true, "✔ concatStr() fixed – badges print perfectly!"
        end,
    },
}