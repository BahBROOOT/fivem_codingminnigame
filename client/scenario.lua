--------------------------------------------------------------------------------
-- Vars
--------------------------------------------------------------------------------

local scenarioPromise   = nil
local inScenario = false
local NUI_SHOWING = false
local currentScenario = nil
local currentENV = nil

--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------

local function dbg(msg)
    if Config.Debug then
        print("[DEBUG] " .. msg)
    end
end

function TaskPlayerScenario(scenarioid, cb)
    local scenario = findScenarioById(scenarioid)
    currentScenario = scenario

    local env, scenarioData = setupEnvForScenario(Config.SafeEnvs[1], scenario)

    if env and scenarioData then
        scenarioPromise = promise.new()

        showTerminal(scenarioData, env)
    end

    local data = Citizen.Await(scenarioPromise)
    scenarioPromise = nil

    hideTerminal()

    cb(data.solved == true, data.statusmsg)
    return data.solved == true, data.statusmsg
end

function doScenarioRun(code, env)
    if currentScenario.beforeRun then 
        currentScenario.beforeRun() 
    end

    local ok, returned, prints = runSnippetClientside(code, env)

    local solved, message
    if ok and currentScenario.validator then
        solved, message = currentScenario.validator(env, returned, prints)
        solved = solved and message ~= false
        message = message or "no validator message"
    else
        solved = ok          -- fallback: raw success of the chunk
        message = returned
    end

    return solved, message, prints
end

function showTerminal(scenarioData, env)
    local function cloneForNUI(src)
        local dst = {}
        for k, v in pairs(src) do
            if type(v) ~= "function" and k ~= "env" then   -- strip functions & heavy data
                dst[k] = v
            end
        end
        return dst
    end

    local scenarioJsonReady = cloneForNUI(scenarioData)

    scenarioJsonReady.env = nil
    scenarioJsonReady.beforeRun = nil
    scenarioJsonReady.validator = nil

    inScenario = true
    currentENV = env
    NUI_SHOWING = true
    SetNuiFocus(true, true)
    SendNUIMessage({ 
        action = "showTerminal",
        scenario = scenarioJsonReady
    })
end

function hideTerminal()
    inScenario = false
    NUI_SHOWING = false
    currentScenario = nil
    currentENV = nil
    SendNUIMessage({ 
        action = "hideTerminal"
    })
    SetNuiFocus(false, false)
end

function printTerminal(msg)
    SendNUIMessage({ 
        action = "printTerminal",
        msg = msg
    })
end

function handeRuncodeResponse(data)
    local code = data.code
    local solved, msg, prints = doScenarioRun(code, currentENV)

    local status = solved and "SUCCESS 🎉" or "FAILED ❌"
    local output = string.format(
        "%s\n%s\n%s",
        status,
        msg or "",
        table.concat(prints, "\n")
    )

    if scenarioPromise and solved == true then
        local data = {
            solved = solved,
            statusmsg = msg
        }
        scenarioPromise:resolve(data)
    end

    printTerminal(output)
end

function handleCloseResponse(data)
    local code = data.code
    local timeup = data.timeout
    local returnMSG = ""
    if scenarioPromise then
        if timeup then
            local data = {
                solved = solved,
                statusmsg = "TIMEOUT"
            }
            scenarioPromise:resolve(data)
        else
            local data = {
                solved = false,
                statusmsg = "CANCEL"
            }
            scenarioPromise:resolve(data)
        end
    end
    hideTerminal()
end

--------------------------------------------------------------------------------
-- Events, Exports and Callbacks
--------------------------------------------------------------------------------

RegisterNUICallback("runCode", handeRuncodeResponse)
RegisterNUICallback("close", handleCloseResponse)

exports("TaskPlayerScenario", TaskPlayerScenario)

RegisterNetEvent("f_codingminnigame:TaskPlayerScenario")
AddEventHandler("f_codingminnigame:TaskPlayerScenario", function(TaskPlayerScenario, cb_event)
    TaskPlayerScenario(TaskPlayerScenario, function(solved, statusMSG)
        if cb_event and cb_event.name then
            if cb_event.isServer then
                TriggerServerEvent(cb_event.name, solved, statusMSG)
            elseif cb_event.isClient and cb_event.cl then
                TriggerEvent(cb_event.name, cb_event.cl, solved, statusMSG)
            end
        else
            dbg("No callback-event found!")
        end
    end)
end)

-- RegisterCommand("scenario", function(source, args, rawCommand)
--     TaskPlayerScenario(tostring(args[1]), function(solved, statusMSG)
--         print(solved and "SUCCESS" or "FAILED")
--         print("MSG: "..statusMSG)
--     end)
-- end)