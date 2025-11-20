# Coding Minigame for FiveM — README

A coding terminal - task system for **FiveM**. Players solve Lua challenges in a secure sandbox using a NUI editor. Admins can add new tasks and helper functions with a few lines of code.

---

<img src="Screenshot_4.png" alt="isolated" width="500"/>

---

## Features

- **Terminal UI** with run/cancel, timer bar, line limit, and live console output.
- **Sandboxed ENV** (`shared/config.lua`) exposing only trusted functions (`math`, `string`, `table`, `vector3`, ...).
- **Task system** via tables in `tasks/legal-tasks.lua` and `tasks/illegal-tasks.lua`.
- **Function registry** (`client/func/func_regist.lua`) to expose reusable helpers with optional state + reset.
- **Exports + command**: `exports("TaskPlayerScenario")` and `/scenario <id>` for quick testing. (Command in scenario.lua - not bound to any restrictions)

---

## Install

1. Copy the resource folder into your FiveM `resources` directory.
2. In `server.cfg` add:  
   `ensure fivem_codingminnigame`
3. Restart the server.

**Tree**

```
fivem_codingminnigame/
├─ fxmanifest.lua
├─ client/
│  ├─ eval.lua
│  ├─ scenario.lua
│  └─ func/func_regist.lua
├─ shared/config.lua
├─ tasks/
│  ├─ legal-tasks.lua
│  └─ illegal-tasks.lua
└─ nui/index.html
```

---

## Quickstart

### Start a scenario
```lua
-- In game:
/scenario brute_force_vault_1

-- Or from Lua (client):
exports["fivem_codingminnigame"]:TaskPlayerScenario("brute_force_vault_1", function(solved, msg)
    print("Solved?", solved, "Msg:", msg)
end)
```

### What happens
- The terminal opens with a starter snippet + goal + hint.
- Press **Run** to execute in a safe environment.
- On each run the scenario’s `validator(env, returned, prints)` decides success and prints a message.

---

## Add a task

Create an entry in **`tasks/legal-tasks.lua`** or **`tasks/illegal-tasks.lua`**:

```lua
{
    id        = "UNIQUE_ID",
    scenario  = "Short story / setup",
    goal      = "What the player must achieve",
    hint      = "Helpful clue for the player",
    time      = 120,                 -- seconds
    maxLines  = 20,                  -- editor line cap
    env       = Config.SafeEnvs[1],  -- sandbox from shared/config.lua
    functions = {"myHelper"},        -- names from the function registry
    snippet   = [[
-- Starter snippet
function solve()
    -- TODO
end
return solve()
    ]],

    beforeRun = function()
        -- reset any helper state here
        -- e.g.: Functions.myHelper.reset()
    end,

    validator = function(env, returned, prints)
        if returned == 42 then
            return true, "✔ Nice!"
        else
            return false, "✖ Not quite. Try again."
        end
    end,
},
```

> Tip: Keep IDs unique and write validators that check both return values **and** any helper-state you expect to change.

---

## Add a helper function (registry)

Edit **`client/func/func_regist.lua`**:

```lua
-- 1) Define storage + table
Functions.myHelper = { __dataStore = { count = 0 }, additional = {} }

-- 2) Main function players can call
Functions.myHelper.func = function()
    local s = Functions.myHelper.__dataStore
    s.count = s.count + 1
    return s.count
end

-- 3) Reset between runs
Functions.myHelper.reset = function()
    Functions.myHelper.__dataStore.count = 0
end

-- 4) Optional extra helpers exposed to the sandbox
Functions.myHelper.additional.get_count = function()
    return Functions.myHelper.__dataStore.count
end

-- 5) Register name for use in tasks.functions = { "myHelper" }
Functions.__functionRegistry["myHelper"] = Functions.myHelper
```

Use it from a task by including `"myHelper"` in the task’s `functions` list, then call `myHelper()` from the player’s code.

---

## Safe environment

Configured in **`shared/config.lua`**. Add only APIs you trust:
```lua
Config.SafeEnvs = {
  [1] = {
    _VERSION = "FiveM Minigame Safe ENV 1.0",
    print = print, pairs = pairs, ipairs = ipairs,
    tonumber = tonumber, tostring = tostring,
    math = math, string = string, table = table, type = type,
    json = json, vector3 = vector3,
  },
}
```
Each env is metatables to `_G` to resolve anything not overridden; keep it tight.

---

## License

MIT — see header in the source file.
