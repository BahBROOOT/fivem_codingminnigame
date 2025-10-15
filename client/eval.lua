--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------

local function dbg(msg)
    if Config.Debug then
        print("[DEBUG] " .. msg)
    end
end

function findScenarioById(scenarioid)
    for key, scenario in ipairs(LEGAL) do
        if scenario.id == scenarioid then
            return scenario
        end
    end
    for key, scenario in ipairs(ILLEGAL) do
        if scenario.id == scenarioid then
            return scenario
        end
    end
    return nil
end

function setupEnvForScenario(envCFG, scenario)
    local env = envCFG
    local scenarioData = scenario
    local scenarioFunctions = scenarioData.functions
    env.__scenarioid = scenarioData.id 

    for key, funcName in ipairs(scenarioFunctions) do
        if Functions.__functionRegistry[funcName] then
            local regist = Functions.__functionRegistry[funcName]
            if regist.func then
                env[funcName] = regist.func

                -- Make sure that additional functions are available
                if regist.additional then
                    for k, v in pairs(regist.additional) do
                        env[k] = v
                    end
                end
            end
        end
    end

    return env, scenarioData
end

function runSnippetClientside(snippet, envCFG)
    local env = envCFG
    local captured = {}
    env.print = nil -- Delete print
    env.print = function(...) -- Override print
        local parts = {}
        for i = 1, select("#", ...) do
            parts[#parts + 1] = tostring(select(i, ...))
        end
        captured[#captured + 1] = table.concat(parts, "\t")
        dbg(table.concat(parts, "\t"))
    end

    local fn, err = load(snippet, "@challenge", "t", env--[[, env]])
    if not fn then 
        return false, "Structure Error(syntax): "  .. err, captured
    end
    -- 5.1 compatibility
    -- if setfenv then 
    --     setfenv(fn, env) 
    -- end
    ok, res = pcall(fn)
    if not ok then 
        return false, "Error while executing(runtime): " .. res, captured
    end
    return true, res, captured
end