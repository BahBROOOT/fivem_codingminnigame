-- Variables

-- Functions

--[[findScenarioById]]
---@param scenarioid string
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

--[[setupEnvForScenario]]
---@param envCFG table
---@param scenario table
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
            end
        end
    end

    return env, scenarioData
end

--[[runSnippetClientside]]
---@param snippet string
---@param envCFG table
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
        --  print(table.concat(parts, "\t")) DEBUG!
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