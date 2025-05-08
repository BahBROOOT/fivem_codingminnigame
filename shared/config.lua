Config = {}

-- Safe Functions setup and init
Config.SafeEnvs = {
    [1] = {
        _VERSION = "FiveM Minnigame Save ENV 1.0",
        print    = print,
        pairs    = pairs,
        ipairs   = ipairs,
        tonumber = tonumber,
        tostring = tostring,
        math     = math,
        string   = string,
        table    = table,
        type     = type,
        json     = json,
        vector3  = vector3,
        -- add anything else you trust…
    },
    -- more safe envs
}

for k,v in pairs(Config.SafeEnvs) do
    setmetatable(v, { __index = _G })
end
