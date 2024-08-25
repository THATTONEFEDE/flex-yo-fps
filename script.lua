loadstring(game:HttpGet("https://raw.githubusercontent.com/THATTONEFEDE/flex-yo-fps/main/source.lua"))()

local players = game:GetService("Players")
local localPlayer = players.localPlayer
local pingRemote = game:GetService("ReplicatedStorage").PingRem
local random = Random.new()
local localScript = localPlayer.PlayerScripts.System.Handler
local fpsDropdown 
local pingDropdown
local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/THATTONEFEDE/flex-yo-fps/main/library.lua')))()

local w = library:CreateWindow("Flexer")

game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = "Flexer loaded",
    Text = "Created by .void__",
    Icon = "rbxassetid://18911834990",
    Duration = 5
})

if not hookfunction then 
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "FPS UI was not loaded",
        Text = "Your exploit does not support hookfunction",
        Icon = "rbxassetid://18911855792",
        Duration = 5
    }) 
end

if not hookmetamethod then 
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Ping UI was not loaded",
        Text = "Your exploit does not support hookmetamethod",
        Icon = "rbxassetid://18911855792",
        Duration = 5
    })
end

local settings = {
    fps = {
        value = 60,
        maxToSubtract = 10,
        realistic = false,
        constant = false,
        copy = false,
        targetName = localPlayer.Name,
        min = 1,
        max = 2500,
        placeholder = false,
        chaos = {
            on = false,
            min = 0,
            max = 0,
            noDecimals = false
        }
    },
    ping = {
        value = 60,
        maxToSubtract = 10,
        realistic = false,
        constant = false,
        copy = false,
        targetName = localPlayer.Name,
        min = -math.huge,
        max = math.huge,
        placeholder = false,
        chaos = {
            on = false,
            min = -2^62,
            max = 2^62,
            noDecimals = false
        }
    }
}

local function getValue(valueType)
    local defaultValue
    if valueType == "fps" then
        defaultValue = tonumber(localPlayer.Character.Head.fpsGui.FPS.Text:sub(6, -1)) or 0
    elseif valueType == "ping" then
        defaultValue = tonumber(localPlayer.Character.Head.fpsGui.Ping.Text:sub(6, -1)) or 0
    end
    if settings[valueType].placeholder or settings[valueType].chaos and settings[valueType].chaos.on then 
        return defaultValue
    end
    if settings[valueType].copy then 
        if valueType == "fps" then
            return tonumber(workspace[settings[valueType].targetName].Head.fpsGui.FPS.Text:sub(6, -1))
        elseif valueType == "ping" then
            return defaultValue
        end
    elseif settings[valueType].constant then 
        return math.clamp(settings[valueType].value, settings[valueType].min, settings[valueType].max)
    elseif settings[valueType].realistic then 
        return math.clamp(settings[valueType].value, settings[valueType].min, settings[valueType].max) - math.random(0, math.min(settings[valueType].maxToSubtract, 2147483647))
    end
    return defaultValue
end

local function parseNumber(value, chaos)
    if table.find({"inf", "infinite", "infinity"}, value) then 
        return chaos and 2^32 or math.huge
    elseif table.find({"-inf", "-infinite", "-infinity"}, value) then
        return chaos and -2^32 or -math.huge
    else
        return tonumber(value) or 0/0
    end
end

local function loadFPSUI()
    local a = w:CreateFolder("FPS Modifier")
    local b = w:CreateFolder("FPS Copier")
    
    a:Toggle("Realistic FPS", function(bool)
        settings.fps.realistic = bool
    end)
    
    a:Toggle("Constant FPS", function(bool)
        settings.fps.constant = bool
    end)
    
    a:Toggle("0 FPS (will reset you)", function(bool)
        settings.fps.placeholder = bool
        if settings.fps.placeholder then 
            localPlayer.Character.Humanoid.Health = 0 
        end
    end)
    
    a:Box("FPS", "number", function(value)
        settings.fps.value = value
    end)
    
    a:Box("Realistic FPS Range", "number", function(value)
        settings.fps.maxToSubtract = value
    end)
    
    b:Toggle("Copy FPS", function(bool)
        settings.fps.copy = bool 
    end)
    
    fpsDropdown = b:Dropdown("Player List", players:GetPlayers(), true, function(plrName)
        settings.fps.targetName = plrName
    end)
end

local function loadPingUI()
    local c = w:CreateFolder("Ping Modifier")
    local d = w:CreateFolder("Ping Copier")
    local e = w:CreateFolder("Ping Chaos")
    
    c:Toggle("Realistic Ping", function(bool)
        settings.ping.realistic = bool
    end)
    
    c:Toggle("Constant Ping", function(bool)
        settings.ping.constant = bool
    end)
    
    c:Box("Ping", "string", function(value)
        settings.ping.value = parseNumber(value, false)
    end)
    
    c:Box("Realistic Ping Range", "string", function(value)
        settings.ping.maxToSubtract = parseNumber(value, false)
    end)
    
    d:Toggle("Copy Ping", function(bool)
        settings.ping.copy = bool 
    end)
    
    pingDropdown = d:Dropdown("Player List", players:GetPlayers(), true, function(plrName)
        settings.ping.targetName = plrName
    end)

    e:Toggle("Chaos Ping", function(bool)
        settings.ping.chaos.on = bool
    end)
    
    e:Toggle("No Decimals", function(bool)
        settings.ping.chaos.noDecimals = bool
    end)
    
    e:Box("Minimum Ping", "string", function(value)
        settings.ping.chaos.min = parseNumber(value, true)
    end)

    e:Box("Maximum Ping", "string", function(value)
        settings.ping.chaos.max = parseNumber(value, true)
    end)
end

if hookfunction then 
    loadFPSUI()
    for i,v in pairs(getgc()) do
        if type(v) == "function" and getfenv(v).script == localScript then
            if debug.getinfo(v).numparams == 3 then
                hookfunction(v, function() 
                    return getValue("fps")
                end)
            end
        end
    end
end

if hookmetamethod then
    loadPingUI()
    local namecall
    namecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and self == pingRemote and not checkcaller() then
            local args = {...}
            args[1] = getValue("ping")
            return namecall(self, unpack(args))
        end
        return namecall(self, ...)
    end)
end

players.PlayerAdded:Connect(function()
    if hookfunction then
        fpsDropdown:Refresh(players:GetPlayers())
    end
    if hookmetamethod then
        pingDropdown:Refresh(players:GetPlayers())
    end
end)

players.PlayerRemoving:Connect(function()
    if hookfunction then
        fpsDropdown:Refresh(players:GetPlayers())
    end
    if hookmetamethod then
        pingDropdown:Refresh(players:GetPlayers())
    end
end)

coroutine.wrap(function()
    local chaosMin
    local chaosMax
    while task.wait() do 
        if settings.ping.chaos.on then 
            chaosMin = settings.ping.chaos.min
            chaosMax = settings.ping.chaos.max
            if settings.ping.chaos.noDecimals then
                pingRemote:FireServer(random:NextInteger(chaosMin, chaosMax))
            else 
                pingRemote:FireServer(random:NextNumber(chaosMin, chaosMax))
            end
        elseif settings.ping.copy then
            if workspace:FindFirstChild(settings.ping.targetName) and workspace[settings.ping.targetName]:FindFirstChild("Head") then
                pingRemote:FireServer(tonumber(workspace[settings.ping.targetName].Head.fpsGui.Ping.Text:sub(6, -1)))
            end
        end 
    end 
end)()

end
