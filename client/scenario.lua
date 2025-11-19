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
    local timeup = data.timeout

    if scenarioPromise then
        local result
        if timeup then
            result = {
                solved = false,
                statusmsg = "TIMEOUT"
            }
        else
            result = {
                solved = false,
                statusmsg = "CANCEL"
            }
        end

        scenarioPromise:resolve(result)
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
AddEventHandler("f_codingminnigame:TaskPlayerScenario", function(scenario, cb_event)
    TaskPlayerScenario(scenario, function(solved, statusMSG)
        if type(cb_event) ~= "table" or type(cb_event.name) ~= "string" then
            dbg("Invalid cb_event payload"); return
        end

        local target = cb_event.target -- "server" or "client"
        if target == "server" then
            if Config.ALLOWED_SERVER_CALLBACKS[cb_event.name] then
                TriggerServerEvent(cb_event.name, solved, statusMSG)
            else
                dbg(("Blocked server callback: %s"):format(cb_event.name))
            end
        elseif target == "client" then
            if cb_event.extra ~= nil then
                TriggerEvent(cb_event.name, cb_event.extra, solved, statusMSG)
            else
                dbg("No valid client id!")
            end
        else
            dbg("No valid callback target specified")
        end
    end)
end)

RegisterCommand("scenario", function(source, args, rawCommand)
    TaskPlayerScenario(tostring(args[1]), function(solved, statusMSG)
        print(solved and "SUCCESS" or "FAILED")
        print("MSG: "..statusMSG)
    end)
end)