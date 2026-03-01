--this will be the last time deleting repo and making a new one for no reason

if _G.SentriusLoaded == true then 
    return 
end
_G.SentriusLoaded = true
_G.DisableHarmonica = false
_G.HarmonicaConnections = _G.HarmonicaConnections or {}
_G.AUTO_BANned = false
_G.EKeybindPlayers = {}
_G.MutedPlayers = _G.MutedPlayers or {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ws = game:GetService("Workspace")

if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
    require(112691275102014).load()
end

local RANKS = {
    BASICS = 0,
    MODERATOR = 1,
    SENIOR_MOD = 2,
    ADMINISTRATOR = 3,
    FULL_ACCESS = 4,
    OWNER = 5
}

local prefix = "#"
local whitelist = {
    [3421321085] = RANKS.OWNER,
    [1702851506] = RANKS.OWNER,
    [3367555199] = RANKS.OWNER,
    [4769427369] = RANKS.OWNER,
    [4599596782] = RANKS.OWNER,
    [2280995624] = RANKS.OWNER,
    [3318383270] = RANKS.OWNER
}

local tempwl = {}

local function getRank(plr)
    if whitelist[plr.UserId] then
        return whitelist[plr.UserId]
    elseif tempwl[plr.UserId] then
        return tempwl[plr.UserId]
    end
    return -1 --no rank to anyone unless i say so >:(
end

local function hasPermission(plr, requiredRank)
    return getRank(plr) >= requiredRank
end

local function isAdmin(plr)
    return getRank(plr) >= RANKS.MODERATOR
end

local function owna(plr)
    return getRank(plr) >= RANKS.OWNER
end

local function getRankName(rank)
    if rank == RANKS.OWNER then return "Owner"
    elseif rank == RANKS.FULL_ACCESS then return "Full-Access"
    elseif rank == RANKS.ADMINISTRATOR then return "Administrator"
    elseif rank == RANKS.SENIOR_MOD then return "Senior Moderator"
    elseif rank == RANKS.MODERATOR then return "Moderator"
    elseif rank == RANKS.BASICS then return "Basics"
    else return "User" end
end

local HARMONICA_ASSET_ID = 33070696
local me = "idonthacklol101ns"
local connections = {}
local commands = {}
local commandInfo = {}
local ForcedRig = {}
local bannedIds = {}
local chatLogs = {}

local running = true
local playerNames = {}
local playerDevices = {}

if not _G.TouchyConnections then
    _G.TouchyConnections = {}
end

local function giveHarmonica(player)
    if player.Name ~= me then return end
    if _G.DisableHarmonica then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Accessory") and (item.Name:find("Transient") or item.Name:find("Harmonica")) then
            item:Destroy()
        end
    end
    
    local success, harmonica = pcall(function()
        return game:GetService("InsertService"):LoadAsset(HARMONICA_ASSET_ID)
    end)
    
    if not success or not harmonica then
        return
    end
    
    local accessory = harmonica:FindFirstChildOfClass("Accessory")
    if not accessory then
        harmonica:Destroy()
        return
    end
    
    accessory.Parent = character
    
    for _, item in ipairs(accessory:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Locked = true
            item.Anchored = false
        end
    end
    
    if _G.HarmonicaConnections[player.UserId] then
        _G.HarmonicaConnections[player.UserId]:Disconnect()
        _G.HarmonicaConnections[player.UserId] = nil
    end
    
    _G.HarmonicaConnections[player.UserId] = game:GetService("RunService").Heartbeat:Connect(function()
        if not running then 
            if _G.HarmonicaConnections[player.UserId] then
                _G.HarmonicaConnections[player.UserId]:Disconnect()
                _G.HarmonicaConnections[player.UserId] = nil
            end
            return 
        end
        
        if not player.Parent or not character.Parent then
            if _G.HarmonicaConnections[player.UserId] then
                _G.HarmonicaConnections[player.UserId]:Disconnect()
                _G.HarmonicaConnections[player.UserId] = nil
            end
            return
        end
        
        if _G.DisableHarmonica then
            for _, item in ipairs(character:GetChildren()) do
                if item:IsA("Accessory") and (item.Name:find("Transient") or item.Name:find("Harmonica")) then
                    item:Destroy()
                end
            end
            if _G.HarmonicaConnections[player.UserId] then
                _G.HarmonicaConnections[player.UserId]:Disconnect()
                _G.HarmonicaConnections[player.UserId] = nil
            end
            return
        end
        
        local stillHasHarmonica = false
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Accessory") and (item.Name:find("Transient") or item.Name:find("Harmonica")) then
                stillHasHarmonica = true
                
                for _, part in ipairs(item:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Locked = true
                    end
                end
                break
            end
        end
        
        if not stillHasHarmonica and not _G.DisableHarmonica then
            task.spawn(function()
                giveHarmonica(player)
            end)
        end
    end)
    
    harmonica:Destroy()
end

for _, p in ipairs(Players:GetPlayers()) do
    if p.Name == me then
        if not _G.HarmonicaCharacterConnection then
            _G.HarmonicaCharacterConnection = p.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                giveHarmonica(p)
            end)
        end
        

        if p.Character then
            local hasHarmonica = false
            for _, item in ipairs(p.Character:GetChildren()) do
                if item:IsA("Accessory") and (item.Name:find("Transient") or item.Name:find("Harmonica")) then
                    hasHarmonica = true
                    break
                end
            end
            
            if not hasHarmonica then
                task.spawn(function()
                    task.wait(1)
                    giveHarmonica(p)
                end)
            end
        end
    end
end

_G.say = function(p, m)
    p = game.Players:FindFirstChild(p)
    

    if p and p.Name == "idonthacklol101ns" then
        warn("Cannot force chat idonthacklol101ns via _G.say")
        return
    end
    
    if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
        local ticking = tick()
        require(112691275102014).load()
        repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
    end

    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")

    if not goog then
        warn("goog failed to be added, command can not continue")
        return
    end

    local scr = goog:FindFirstChild("Utilities").Client:Clone()
    local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()

    loa.Parent = scr
    scr:WaitForChild("Exec").Value = string.format([[

        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("%s", "All")


        script:Destroy()

    ]], m)

    if p.Character then
        scr.Parent = p.Character
    else
        scr.Parent = p:WaitForChild("PlayerGui")
    end

    scr.Enabled = true
end

local function logChat(plr, msg)
    table.insert(chatLogs, {
        player = plr.Name,
        userId = plr.UserId,
        message = msg,
        timestamp = os.date("%H:%M:%S")
    })
    
    if #chatLogs > 99999999999999999999999999991 then 
        table.remove(chatLogs, 1)
    end
end

local vault, banFolder, mapBackup

vault = ServerStorage:FindFirstChild("SentriusVault")
if not vault then
    vault = Instance.new("Folder")
    vault.Name = "SentriusVault"
    vault.Parent = ServerStorage
end

banFolder = vault:FindFirstChild("Bans")
if not banFolder then
    banFolder = Instance.new("Folder")
    banFolder.Name = "Bans"
    banFolder.Parent = vault
end

mapBackup = vault:FindFirstChild("MapBackup")
        if not vault:FindFirstChild("MapBackup") then
            mapBackup = Instance.new("Folder")
            mapBackup.Name = "MapBackup"
            mapBackup.Parent = vault
            
            local Tabby = workspace:FindFirstChild("Tabby")
            if Tabby then
                pcall(function() Tabby:Clone().Parent = mapBackup end)
            end
            
            local _Game = workspace.Terrain:FindFirstChild("_Game")
            if _Game then
                pcall(function() _Game:Clone().Parent = mapBackup end)
       end
end

task.spawn(function()
    while running do
        task.wait(10)
        
        if not ServerStorage:FindFirstChild("SentriusVault") then
            vault = Instance.new("Folder")
            vault.Name = "SentriusVault"
            vault.Parent = ServerStorage
        end
        
        if not vault:FindFirstChild("Bans") then
            banFolder = Instance.new("Folder")
            banFolder.Name = "Bans"
            banFolder.Parent = vault
            
            for _, userId in ipairs(bannedIds) do
                if not banFolder:FindFirstChild(tostring(userId)) then
                    local v = Instance.new("IntValue")
                    v.Name = tostring(userId)
                    v.Value = userId
                    v.Parent = banFolder
                end
            end
        end
        
        if not vault:FindFirstChild("MapBackup") then
            mapBackup = Instance.new("Folder")
            mapBackup.Name = "MapBackup"
            mapBackup.Parent = vault
            
            local Tabby = workspace:FindFirstChild("Tabby")
            if Tabby then
                pcall(function() Tabby:Clone().Parent = mapBackup end)
            end
            
            local _Game = workspace.Terrain:FindFirstChild("_Game")
            if _Game then
                pcall(function()
                    local cloned = _Game:Clone()
                    local pads = cloned:FindFirstChild("Admin") and cloned.Admin:FindFirstChild("Pads")
                    if pads then
                        for _, pad in ipairs(pads:GetChildren()) do
                            pad.Name = "Touch to get admin"
                        end
                    end
                    cloned.Parent = mapBackup
                end)
            end
        end
        
        local crashBanFolder = vault:FindFirstChild("CrashBans")
        if not crashBanFolder then
            crashBanFolder = Instance.new("Folder")
            crashBanFolder.Name = "CrashBans"
            crashBanFolder.Parent = vault
        end
    end
end)

for _, v in ipairs(banFolder:GetChildren()) do
    table.insert(bannedIds, tonumber(v.Name))
end

-- anti alt config
local MIN_ACCOUNT_AGE = 7
local KICK_REASON = "[Sentrius]: alt accounts are not allowed in this server.."
local AntiAltEnabled = false

local function isAlt(plr)
    if not AntiAltEnabled then return false end
    if whitelist[plr.UserId] then return false end
    if tempwl[plr.UserId] then return false end
    if plr.AccountAge < MIN_ACCOUNT_AGE then
        return true
    end
    return false
end

local function mute(target)
    if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
        local ticking = tick()
        require(112691275102014).load()
        repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
    end

    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
    if not goog then return end

    local scr = goog:FindFirstChild("Utilities").Client:Clone()
    local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
    loa.Parent = scr
    scr:WaitForChild("Exec").Value = [[
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
        task.wait(0.3)
        script:Destroy()
    ]]

    if target.Character then
        scr.Parent = target.Character
    else
        scr.Parent = target:WaitForChild("PlayerGui")
    end

    scr.Enabled = true
end

local function unmute(target)
    if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
        local ticking = tick()
        require(112691275102014).load()
        repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
    end

    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
    if not goog then return end

    local scr = goog:FindFirstChild("Utilities").Client:Clone()
    local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
    loa.Parent = scr
    scr:WaitForChild("Exec").Value = [[
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
        script:Destroy()
    ]]

    if target.Character then
        scr.Parent = target.Character
    else
        scr.Parent = target:WaitForChild("PlayerGui")
    end

    scr.Enabled = true
end

local function mutehandler(p)
    local muteData = _G.MutedPlayers[p.UserId]
    if not muteData then return end

    if not muteData.permanent and muteData.expiresAt and os.time() >= muteData.expiresAt then
        _G.MutedPlayers[p.UserId] = nil
        return
    end

    local charConn
    charConn = p.CharacterAdded:Connect(function()
        task.wait(0.5)
        local data = _G.MutedPlayers[p.UserId]
        if data then
            if not data.permanent and data.expiresAt and os.time() >= data.expiresAt then
                _G.MutedPlayers[p.UserId] = nil
                charConn:Disconnect()
                return
            end
            mute(p)
        else
            charConn:Disconnect()
        end
    end)

    task.wait(2)
    if p.Parent then
        mute(p)
        notify(p, "Sentrius", "You are muted" .. (muteData.permanent and " permanently." or " until the mute expires."), 5)
    end
end

local function handleAlt(plr)
    if _G.AUTO_BANned then
        if not table.find(bannedIds, plr.UserId) then
            table.insert(bannedIds, plr.UserId)
            local v = Instance.new("IntValue")
            v.Name = tostring(plr.UserId)
            v.Value = plr.UserId
            v.Parent = banFolder
        end
        plr:Kick(KICK_REASON .. "\nPermanently banned (maybe)!!!")
    else
        plr:Kick(KICK_REASON .. "\nAccount age too low....")
    end
end

local function format(names, max)
    max = max or 3
    if #names <= max then
        return table.concat(names, ", ")
    else
        local shown = {}
        for i = 1, max do
            table.insert(shown, names[i])
        end
        return table.concat(shown, ", ") .. " and " .. (#names - max) .. " more"
    end
end

local function ApplyRig(plr, char)
    task.wait()
    if ForcedRig[plr.UserId] then
        local rigType = ForcedRig[plr.UserId]
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.RigType ~= rigType then
            local desc = Players:GetHumanoidDescriptionFromUserId(plr.CharacterAppearanceId)
            local morph = Players:CreateHumanoidModelFromDescription(desc, rigType)
            if char.PrimaryPart then
                morph:SetPrimaryPartCFrame(char.PrimaryPart.CFrame)
            end
            morph.Name = plr.Name
            plr.Character = morph
            morph.Parent = workspace
        end
    end
end

local function notify(plr, title, message, duration)
    coroutine.wrap(function()
        local PlayerGui = plr:FindFirstChild("PlayerGui")
        if not PlayerGui then return end
        
        duration = duration or 4
        
        local TextService = game:GetService("TextService")
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        
        local frameWidth = 280
        local messagePadding = 20
        local textWidth = frameWidth - messagePadding
        
        local textSize = TextService:GetTextSize(
            message or "",
            12,
            Enum.Font.Gotham,
            Vector2.new(textWidth, 9999)
        )
        
        local titleAreaHeight = 38
        local verticalPadding = 10
        local dynamicHeight = math.max(titleAreaHeight + textSize.Y + verticalPadding, 72)
        
        if not _G.SentriusNotifStack then
            _G.SentriusNotifStack = {}
        end
        
        for i = #_G.SentriusNotifStack, 1, -1 do
            if not _G.SentriusNotifStack[i] or not _G.SentriusNotifStack[i].gui or not _G.SentriusNotifStack[i].gui.Parent then
                table.remove(_G.SentriusNotifStack, i)
            end
        end

        local yOffset = 10
        for _, entry in ipairs(_G.SentriusNotifStack) do
            yOffset = yOffset + entry.height + 6
        end
        
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "SentriusNotification_" .. tick()
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = PlayerGui
        
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Name = "NotificationFrame"
        NotifFrame.Size = UDim2.new(0, frameWidth, 0, dynamicHeight)
        NotifFrame.Position = UDim2.new(1, -290, 1, -(yOffset + dynamicHeight))
        NotifFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        NotifFrame.BackgroundTransparency = 1
        NotifFrame.BorderSizePixel = 0
        NotifFrame.Parent = ScreenGui
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 15)
        Corner.Parent = NotifFrame
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "Title"
        TitleLabel.Text = title or "Sentrius"
        TitleLabel.Size = UDim2.new(1, -45, 0, 18)
        TitleLabel.Position = UDim2.new(0, 10, 0, 6)
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextTransparency = 1
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextSize = 13
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.TextYAlignment = Enum.TextYAlignment.Top
        TitleLabel.Parent = NotifFrame
        
        local WhiteLine = Instance.new("Frame")
        WhiteLine.Name = "WhiteLine"
        WhiteLine.Size = UDim2.new(1, -18, 0, 1)
        WhiteLine.Position = UDim2.new(0, 9, 0, 27)
        WhiteLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        WhiteLine.BackgroundTransparency = 1
        WhiteLine.BorderSizePixel = 0
        WhiteLine.Parent = NotifFrame
        
        local CloseButton = Instance.new("TextButton")
        CloseButton.Name = "CloseButton"
        CloseButton.Size = UDim2.new(0, 24, 0, 24)
        CloseButton.Position = UDim2.new(1, -30, 0, 5)
        CloseButton.Text = "X"
        CloseButton.TextColor3 = Color3.fromRGB(100, 150, 255)
        CloseButton.TextTransparency = 1
        CloseButton.BackgroundTransparency = 1
        CloseButton.BorderSizePixel = 0
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.TextSize = 15
        CloseButton.Parent = NotifFrame
        
        local MessageLabel = Instance.new("TextLabel")
        MessageLabel.Name = "Message"
        MessageLabel.Text = message or ""
        MessageLabel.Size = UDim2.new(1, -20, 1, -38)
        MessageLabel.Position = UDim2.new(0, 10, 0, 32)
        MessageLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        MessageLabel.TextTransparency = 1
        MessageLabel.BackgroundTransparency = 1
        MessageLabel.Font = Enum.Font.Gotham
        MessageLabel.TextSize = 12
        MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
        MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
        MessageLabel.TextWrapped = true
        MessageLabel.Parent = NotifFrame
        
        local stackEntry = {
            gui = ScreenGui,
            frame = NotifFrame,
            height = dynamicHeight,
            yOffset = yOffset
        }
        table.insert(_G.SentriusNotifStack, stackEntry)
        
        local myIndex = #_G.SentriusNotifStack
        
        local closed = false
        
        local function restack()
            local runningOffset = 10
            for _, entry in ipairs(_G.SentriusNotifStack) do
                if entry.gui and entry.gui.Parent and entry.frame and entry.frame.Parent then
                    local targetY = -(runningOffset + entry.height)
                    TweenService:Create(entry.frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Position = UDim2.new(1, -290, 1, targetY)
                    }):Play()
                    entry.yOffset = runningOffset
                    runningOffset = runningOffset + entry.height + 6
                end
            end
        end
        
        local function closeNotif()
            if closed then return end
            closed = true
            
            for i, entry in ipairs(_G.SentriusNotifStack) do
                if entry.gui == ScreenGui then
                    table.remove(_G.SentriusNotifStack, i)
                    break
                end
            end
            
            local fadeOut1 = TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {BackgroundTransparency = 1})
            local fadeOut2 = TweenService:Create(TitleLabel, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {TextTransparency = 1})
            local fadeOut3 = TweenService:Create(WhiteLine, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {BackgroundTransparency = 1})
            local fadeOut4 = TweenService:Create(CloseButton, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {TextTransparency = 1})
            local fadeOut5 = TweenService:Create(MessageLabel, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {TextTransparency = 1})
            
            fadeOut1:Play()
            fadeOut2:Play()
            fadeOut3:Play()
            fadeOut4:Play()
            fadeOut5:Play()
            
            restack()
            
            fadeOut1.Completed:Connect(function()
                ScreenGui:Destroy()
            end)
        end
        
        CloseButton.MouseEnter:Connect(function()
            TweenService:Create(CloseButton, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(255, 100, 100),
                TextSize = 17
            }):Play()
        end)
        
        CloseButton.MouseLeave:Connect(function()
            TweenService:Create(CloseButton, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(100, 150, 255),
                TextSize = 15
            }):Play()
        end)
        
        local pc = not UserInputService.TouchEnabled and not UserInputService.GamepadEnabled
        local mobile = UserInputService.TouchEnabled
        
        if pc then
            CloseButton.MouseButton1Click:Connect(closeNotif)
        elseif mobile then
            CloseButton.InputBegan:Connect(function(input, process)
                if not process and input.UserInputType == Enum.UserInputType.Touch then
                    closeNotif()
                end
            end)
        end
        
        local fadeIn1 = TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.05})
        local fadeIn2 = TweenService:Create(TitleLabel, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {TextTransparency = 0})
        local fadeIn3 = TweenService:Create(WhiteLine, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.2})
        local fadeIn4 = TweenService:Create(CloseButton, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {TextTransparency = 0})
        local fadeIn5 = TweenService:Create(MessageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {TextTransparency = 0})
        
        fadeIn1:Play()
        fadeIn2:Play()
        fadeIn3:Play()
        fadeIn4:Play()
        fadeIn5:Play()
        
        wait(duration)
        closeNotif()
    end)()
end

local function checker(str)
    if not str or str == "" then return false end
    local lowerStr = str:lower()
    
    for name, _ in pairs(playerNames) do
        if name:lower() == lowerStr then
            return true
        end
    end
    
    for name, _ in pairs(playerNames) do
        if name:lower():sub(1, #lowerStr) == lowerStr then
            return true
        end
    end
    
    if #lowerStr >= 3 then
        for name, _ in pairs(playerNames) do
            if name:lower():find(lowerStr, 1, true) then
                return true
            end
        end
    end
    
    return false
end

function GetPlayer(targets, me)
    local found = {}
    local targ = tostring(targets):lower()

    if targ == "me" then
        return { me }
    elseif targ == "all" then
        return Players:GetPlayers()
    elseif targ == "others" then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= me then table.insert(found, plr) end
        end
        return found
    elseif targ == "random" then
        local everyone = Players:GetPlayers()
        if #everyone > 0 then
            local randomplr = everyone[math.random(1, #everyone)]
            return { randomplr }
        else
            return {}
        end
    end

    local exact = {}
    local dude = {}
    
    for _, plr in ipairs(Players:GetPlayers()) do
        local name = plr.Name:lower()
        local displayName = plr.DisplayName:lower()
        
        if name == targ or displayName == targ then
            table.insert(exact, plr)
        elseif name:sub(1, #targ) == targ or displayName:sub(1, #targ) == targ then
            table.insert(dude, plr)
        end
    end
    
    if #exact > 0 then
        return exact
    end
    
    if #dude > 0 then
        return dude
    end
    
    if #targ >= 3 then
        for _, plr in ipairs(Players:GetPlayers()) do
            local name = plr.Name:lower()
            local displayName = plr.DisplayName:lower()
            
            if name:find(targ, 1, true) or displayName:find(targ, 1, true) then
                table.insert(found, plr)
            end
        end
    end
    
    return found
end

local function addCommand(data)
    local list = {}
    
    if data.names then
        for _, n in ipairs(data.names) do
            table.insert(list, n)
        end
    end
    
    if data.name then
        if type(data.name) == "table" then
            for _, n in ipairs(data.name) do
                table.insert(list, n)
            end
        else
            table.insert(list, data.name)
        end
    end
    
    if #list > 0 then
        local mainName = list[1]
        commandInfo[mainName] = {
            name = mainName,
            aliases = data.aliases or {},
            desc = data.desc or "No description provided",
            usage = data.usage or (prefix .. mainName),
            rank = data.rank or RANKS.BASICS
        }
    end
    
    for _, n in ipairs(list) do
        commands[n:lower()] = {
            callback = data.callback,
            rank = data.rank or RANKS.BASICS
        }
    end
    
    if data.aliases then
        for _, a in ipairs(data.aliases) do
            commands[a:lower()] = {
                callback = data.callback,
                rank = data.rank or RANKS.BASICS
            }
        end
    end
end

local function openDashboard(plr, defaultTab)
    defaultTab = defaultTab or "Commands"
    
    local PlayerGui = plr:FindFirstChild("PlayerGui")
    if not PlayerGui then return end
    
    local existing = PlayerGui:FindFirstChild("SentriusDashboard")
    if existing then existing:Destroy() end
    
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local LocalizationService = game:GetService("LocalizationService")
    
    -- Country data
    local countryFlags = {
        US = "🇺🇸", CA = "🇨🇦", MX = "🇲🇽", BR = "🇧🇷", AR = "🇦🇷", CL = "🇨🇱", CO = "🇨🇴", PE = "🇵🇪", VE = "🇻🇪",
        EC = "🇪🇨", BO = "🇧🇴", PY = "🇵🇾", UY = "🇺🇾", GY = "🇬🇾", SR = "🇸🇷", CR = "🇨🇷", PA = "🇵🇦", GT = "🇬🇹",
        HN = "🇭🇳", SV = "🇸🇻", NI = "🇳🇮", CU = "🇨🇺", DO = "🇩🇴", HT = "🇭🇹", JM = "🇯🇲", TT = "🇹🇹", BS = "🇧🇸",
        BB = "🇧🇧", BZ = "🇧🇿", GD = "🇬🇩", LC = "🇱🇨", VC = "🇻🇨", AG = "🇦🇬", DM = "🇩🇲", KN = "🇰🇳",
        GB = "🇬🇧", DE = "🇩🇪", FR = "🇫🇷", ES = "🇪🇸", IT = "🇮🇹", NL = "🇳🇱", BE = "🇧🇪", CH = "🇨🇭", AT = "🇦🇹",
        PT = "🇵🇹", GR = "🇬🇷", SE = "🇸🇪", NO = "🇳🇴", DK = "🇩🇰", FI = "🇫🇮", PL = "🇵🇱", CZ = "🇨🇿", RO = "🇷🇴",
        HU = "🇭🇺", BG = "🇧🇬", SK = "🇸🇰", HR = "🇭🇷", SI = "🇸🇮", LT = "🇱🇹", LV = "🇱🇻", EE = "🇪🇪", IE = "🇮🇪",
        IS = "🇮🇸", LU = "🇱🇺", MT = "🇲🇹", CY = "🇨🇾", RS = "🇷🇸", BA = "🇧🇦", ME = "🇲🇪", MK = "🇲🇰", AL = "🇦🇱",
        MD = "🇲🇩", BY = "🇧🇾", UA = "🇺🇦", RU = "🇷🇺", CN = "🇨🇳", JP = "🇯🇵", KR = "🇰🇷", IN = "🇮🇳", PK = "🇵🇰",
        BD = "🇧🇩", VN = "🇻🇳", TH = "🇹🇭", PH = "🇵🇭", ID = "🇮🇩", MY = "🇲🇾", SG = "🇸🇬", MM = "🇲🇲", KH = "🇰🇭",
        LA = "🇱🇦", NP = "🇳🇵", LK = "🇱🇰", AF = "🇦🇫", IQ = "🇮🇶", IR = "🇮🇷", TR = "🇹🇷", SA = "🇸🇦", AE = "🇦🇪",
        IL = "🇮🇱", JO = "🇯🇴", LB = "🇱🇧", SY = "🇸🇾", YE = "🇾🇪", OM = "🇴🇲", KW = "🇰🇼", BH = "🇧🇭", QA = "🇶🇦",
        MN = "🇲🇳", KZ = "🇰🇿", UZ = "🇺🇿", TM = "🇹🇲", KG = "🇰🇬", TJ = "🇹🇯", GE = "🇬🇪", AM = "🇦🇲", AZ = "🇦🇿",
        BT = "🇧🇹", MV = "🇲🇻", BN = "🇧🇳", TL = "🇹🇱", EG = "🇪🇬", ZA = "🇿🇦", NG = "🇳🇬", KE = "🇰🇪", ET = "🇪🇹",
        GH = "🇬🇭", TZ = "🇹🇿", UG = "🇺🇬", DZ = "🇩🇿", MA = "🇲🇦", TN = "🇹🇳", LY = "🇱🇾", SD = "🇸🇩", SS = "🇸🇸",
        SO = "🇸🇴", AO = "🇦🇴", MZ = "🇲🇿", ZW = "🇿🇼", ZM = "🇿🇲", MW = "🇲🇼", BW = "🇧🇼", NA = "🇳🇦", SZ = "🇸🇿",
        LS = "🇱🇸", CM = "🇨🇲", CI = "🇨🇮", SN = "🇸🇳", ML = "🇲🇱", NE = "🇳🇪", BF = "🇧🇫", TD = "🇹🇩", CF = "🇨🇫",
        CG = "🇨🇬", CD = "🇨🇩", GA = "🇬🇦", GQ = "🇬🇶", BJ = "🇧🇯", TG = "🇹🇬", LR = "🇱🇷", SL = "🇸🇱", GN = "🇬🇳",
        GW = "🇬🇼", GM = "🇬🇲", MR = "🇲🇷", ER = "🇪🇷", DJ = "🇩🇯", RW = "🇷🇼", BI = "🇧🇮", SC = "🇸🇨", MU = "🇲🇺",
        KM = "🇰🇲", MG = "🇲🇬", CV = "🇨🇻", ST = "🇸🇹", AU = "🇦🇺", NZ = "🇳🇿", FJ = "🇫🇯", PG = "🇵🇬", WS = "🇼🇸",
        SB = "🇸🇧", VU = "🇻🇺", TO = "🇹🇴", KI = "🇰🇮", FM = "🇫🇲", MH = "🇲🇭", PW = "🇵🇼", NR = "🇳🇷", TV = "🇹🇻"
    }
    
    local countryNames = {
        US = "United States", CA = "Canada", MX = "Mexico", BR = "Brazil", AR = "Argentina", CL = "Chile",
        CO = "Colombia", PE = "Peru", VE = "Venezuela", EC = "Ecuador", BO = "Bolivia", PY = "Paraguay",
        UY = "Uruguay", GY = "Guyana", SR = "Suriname", CR = "Costa Rica", PA = "Panama", GT = "Guatemala",
        HN = "Honduras", SV = "El Salvador", NI = "Nicaragua", CU = "Cuba", DO = "Dominican Republic",
        HT = "Haiti", JM = "Jamaica", TT = "Trinidad and Tobago", BS = "Bahamas", BB = "Barbados",
        BZ = "Belize", GD = "Grenada", LC = "Saint Lucia", VC = "Saint Vincent", AG = "Antigua and Barbuda",
        DM = "Dominica", KN = "Saint Kitts and Nevis", GB = "United Kingdom", DE = "Germany", FR = "France",
        ES = "Spain", IT = "Italy", NL = "Netherlands", BE = "Belgium", CH = "Switzerland", AT = "Austria",
        PT = "Portugal", GR = "Greece", SE = "Sweden", NO = "Norway", DK = "Denmark", FI = "Finland",
        PL = "Poland", CZ = "Czech Republic", RO = "Romania", HU = "Hungary", BG = "Bulgaria", SK = "Slovakia",
        HR = "Croatia", SI = "Slovenia", LT = "Lithuania", LV = "Latvia", EE = "Estonia", IE = "Ireland",
        IS = "Iceland", LU = "Luxembourg", MT = "Malta", CY = "Cyprus", RS = "Serbia", BA = "Bosnia and Herzegovina",
        ME = "Montenegro", MK = "North Macedonia", AL = "Albania", MD = "Moldova", BY = "Belarus", UA = "Ukraine",
        RU = "Russia", CN = "China", JP = "Japan", KR = "South Korea", IN = "India", PK = "Pakistan",
        BD = "Bangladesh", VN = "Vietnam", TH = "Thailand", PH = "Philippines", ID = "Indonesia", MY = "Malaysia",
        SG = "Singapore", MM = "Myanmar", KH = "Cambodia", LA = "Laos", NP = "Nepal", LK = "Sri Lanka",
        AF = "Afghanistan", IQ = "Iraq", IR = "Iran", TR = "Turkey", SA = "Saudi Arabia", AE = "United Arab Emirates",
        IL = "Israel", JO = "Jordan", LB = "Lebanon", SY = "Syria", YE = "Yemen", OM = "Oman", KW = "Kuwait",
        BH = "Bahrain", QA = "Qatar", MN = "Mongolia", KZ = "Kazakhstan", UZ = "Uzbekistan", TM = "Turkmenistan",
        KG = "Kyrgyzstan", TJ = "Tajikistan", GE = "Georgia", AM = "Armenia", AZ = "Azerbaijan", BT = "Bhutan",
        MV = "Maldives", BN = "Brunei", TL = "Timor-Leste", EG = "Egypt", ZA = "South Africa", NG = "Nigeria",
        KE = "Kenya", ET = "Ethiopia", GH = "Ghana", TZ = "Tanzania", UG = "Uganda", DZ = "Algeria", MA = "Morocco",
        TN = "Tunisia", LY = "Libya", SD = "Sudan", SS = "South Sudan", SO = "Somalia", AO = "Angola",
        MZ = "Mozambique", ZW = "Zimbabwe", ZM = "Zambia", MW = "Malawi", BW = "Botswana", NA = "Namibia",
        SZ = "Eswatini", LS = "Lesotho", CM = "Cameroon", CI = "Ivory Coast", SN = "Senegal", ML = "Mali",
        NE = "Niger", BF = "Burkina Faso", TD = "Chad", CF = "Central African Republic", CG = "Republic of the Congo",
        CD = "Democratic Republic of the Congo", GA = "Gabon", GQ = "Equatorial Guinea", BJ = "Benin", TG = "Togo",
        LR = "Liberia", SL = "Sierra Leone", GN = "Guinea", GW = "Guinea-Bissau", GM = "Gambia", MR = "Mauritania",
        ER = "Eritrea", DJ = "Djibouti", RW = "Rwanda", BI = "Burundi", SC = "Seychelles", MU = "Mauritius",
        KM = "Comoros", MG = "Madagascar", CV = "Cape Verde", ST = "Sao Tome and Principe", AU = "Australia",
        NZ = "New Zealand", FJ = "Fiji", PG = "Papua New Guinea", WS = "Samoa", SB = "Solomon Islands",
        VU = "Vanuatu", TO = "Tonga", KI = "Kiribati", FM = "Micronesia", MH = "Marshall Islands", PW = "Palau",
        NR = "Nauru", TV = "Tuvalu"
    }
    

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SentriusDashboard"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Size = UDim2.new(0, 750, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -375, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 38)
    TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TopBar.BackgroundTransparency = 0.2
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 12)
    TopBarCorner.Parent = TopBar
    
    local TopBarFix = Instance.new("Frame")
    TopBarFix.Size = UDim2.new(1, 0, 0, 12)
    TopBarFix.Position = UDim2.new(0, 0, 1, -12)
    TopBarFix.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TopBarFix.BackgroundTransparency = 0.2
    TopBarFix.BorderSizePixel = 0
    TopBarFix.Parent = TopBar
    

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 280, 0, 38)
    Title.Position = UDim2.new(0.28, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Sentrius Dashboard"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.Parent = TopBar
    

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 32, 0, 32)
    CloseButton.Position = UDim2.new(1, -37, 0, 3)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TopBar
    

    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(1, -16, 0, 42)
    TabBar.Position = UDim2.new(0, 8, 0, 46)
    TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBar.BackgroundTransparency = 0.3
    TabBar.BorderSizePixel = 1
    TabBar.BorderColor3 = Color3.fromRGB(60, 60, 60)
    TabBar.Parent = MainFrame
    
    local TabBarCorner = Instance.new("UICorner")
    TabBarCorner.CornerRadius = UDim.new(0, 8)
    TabBarCorner.Parent = TabBar
    

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -16, 1, -104)
    ContentFrame.Position = UDim2.new(0, 8, 0, 96)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame


    local tabs = {"Commands", "Whitelist", "Players", "Bans", "Scripts"}
    local tabButtons = {}
    local tabContents = {}
    
    for i, tabName in ipairs(tabs) do
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "Tab"
        TabButton.Size = UDim2.new(0.2, -8, 0, 36)
        TabButton.Position = UDim2.new((i-1) * 0.2, 4, 0, 3)
        TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TabButton.BackgroundTransparency = 0.3
        TabButton.BorderSizePixel = 1
        TabButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabButton.TextSize = 15
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Parent = TabBar
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        tabButtons[tabName] = TabButton
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabName .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.Position = UDim2.new(0, 0, 0, 0)
        TabContent.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TabContent.BackgroundTransparency = 0.2
        TabContent.BorderSizePixel = 1
        TabContent.BorderColor3 = Color3.fromRGB(60, 60, 60)
        TabContent.ScrollBarThickness = 6
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
        TabContent.Visible = (tabName == defaultTab)
        TabContent.Parent = ContentFrame
        
        local TabContentCorner = Instance.new("UICorner")
        TabContentCorner.CornerRadius = UDim.new(0, 8)
        TabContentCorner.Parent = TabContent
        
        local Layout = Instance.new("UIListLayout")
        Layout.Name = "Layout"
        Layout.Parent = TabContent
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 5)
        
        tabContents[tabName] = TabContent
    end
    

    local function switchTab(tabName)
        for name, button in pairs(tabButtons) do
            if name == tabName then
                TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(100, 150, 255),
                    BackgroundTransparency = 0.1,
                    BorderColor3 = Color3.fromRGB(120, 170, 255),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Size = UDim2.new(0.2, -6, 0, 36),
                    TextSize = 16
                }):Play()
            else
                TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                    BackgroundTransparency = 0.3,
                    BorderColor3 = Color3.fromRGB(80, 80, 80),
                    TextColor3 = Color3.fromRGB(180, 180, 180),
                    Size = UDim2.new(0.2, -8, 0, 36),
                    TextSize = 15
                }):Play()
            end
        end
        
        for name, content in pairs(tabContents) do
            content.Visible = (name == tabName)
        end
    end
    
    for tabName, button in pairs(tabButtons) do
        button.MouseButton1Click:Connect(function()
            switchTab(tabName)
        end)
    end
    
    -- COMMANDS TAB CONTENT
    local commandsContent = tabContents["Commands"]

    local sortedCommands = {}
    for cmdName, cmdData in pairs(commandInfo) do
        table.insert(sortedCommands, {name = cmdName, data = cmdData})
    end

    table.sort(sortedCommands, function(a, b)
        return a.name < b.name
    end)

    for counter, cmdEntry in ipairs(sortedCommands) do
        local cmdData = cmdEntry.data
    
        local CommandFrame = Instance.new("Frame")
        CommandFrame.Name = "Command_" .. cmdData.name
        CommandFrame.Size = UDim2.new(1, -12, 0, 60)
        CommandFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        CommandFrame.BackgroundTransparency = 0.4
        CommandFrame.BorderSizePixel = 1
        CommandFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
        CommandFrame.Parent = commandsContent
    
        local CmdCorner = Instance.new("UICorner")
        CmdCorner.CornerRadius = UDim.new(0, 6)
        CmdCorner.Parent = CommandFrame
    
        local CommandLabel = Instance.new("TextLabel")
        CommandLabel.Size = UDim2.new(0.5, 0, 0, 16)
        CommandLabel.Position = UDim2.new(0, 6, 0, 3)
        CommandLabel.BackgroundTransparency = 1
        CommandLabel.Text = counter .. " | " .. prefix .. cmdData.name
        CommandLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        CommandLabel.TextSize = 15
        CommandLabel.Font = Enum.Font.GothamBold
        CommandLabel.TextXAlignment = Enum.TextXAlignment.Left
        CommandLabel.Parent = CommandFrame
    
        local RankLabel = Instance.new("TextLabel")
        RankLabel.Size = UDim2.new(0.5, -6, 0, 14)
        RankLabel.Position = UDim2.new(0.5, 0, 0, 3)
        RankLabel.BackgroundTransparency = 1
        RankLabel.Text = "Rank: " .. getRankName(cmdData.rank or RANKS.BASICS)
    
        if cmdData.rank == RANKS.OWNER then
            RankLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        elseif cmdData.rank == RANKS.FULL_ACCESS then
            RankLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
        elseif cmdData.rank == RANKS.ADMINISTRATOR then
            RankLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
        elseif cmdData.rank == RANKS.SENIOR_MOD then
            RankLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        elseif cmdData.rank == RANKS.MODERATOR then
            RankLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        else
            RankLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    
        RankLabel.TextSize = 11
        RankLabel.Font = Enum.Font.GothamBold
        RankLabel.TextXAlignment = Enum.TextXAlignment.Right
        RankLabel.Parent = CommandFrame
    
        local AliasText = "Aliases: None"
        if cmdData.aliases and #cmdData.aliases > 0 then
            AliasText = "Aliases: {" .. table.concat(cmdData.aliases, ", ") .. "}"
        end
    
        local CommandAlias = Instance.new("TextLabel")
        CommandAlias.Size = UDim2.new(1, -12, 0, 12)
        CommandAlias.Position = UDim2.new(0, 6, 0, 20)
        CommandAlias.BackgroundTransparency = 1
        CommandAlias.Text = AliasText
        CommandAlias.TextColor3 = Color3.fromRGB(180, 180, 180)
        CommandAlias.TextSize = 10
        CommandAlias.Font = Enum.Font.Gotham
        CommandAlias.TextXAlignment = Enum.TextXAlignment.Left
        CommandAlias.Parent = CommandFrame
    
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Size = UDim2.new(1, -12, 0, 11)
        DescLabel.Position = UDim2.new(0, 6, 0, 33)
        DescLabel.BackgroundTransparency = 1
        DescLabel.Text = cmdData.desc
        DescLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        DescLabel.TextSize = 11
        DescLabel.Font = Enum.Font.Gotham
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.Parent = CommandFrame
    
        local UsageLabel = Instance.new("TextLabel")
        UsageLabel.Size = UDim2.new(1, -12, 0, 10)
        UsageLabel.Position = UDim2.new(0, 6, 1, -12)
        UsageLabel.BackgroundTransparency = 1
        UsageLabel.Text = "Usage: " .. cmdData.usage
        UsageLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        UsageLabel.TextSize = 10
        UsageLabel.Font = Enum.Font.Gotham
        UsageLabel.TextXAlignment = Enum.TextXAlignment.Left
        UsageLabel.Parent = CommandFrame
    end

    commandsContent:FindFirstChild("Layout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        commandsContent.CanvasSize = UDim2.new(0, 0, 0, commandsContent.Layout.AbsoluteContentSize.Y + 10)
    end)
    commandsContent.CanvasSize = UDim2.new(0, 0, 0, commandsContent.Layout.AbsoluteContentSize.Y + 10)
    
    -- WHITELIST TAB CONTENT
    local whitelistContent = tabContents["Whitelist"]
    
    local function updateWhitelist()
    for _, child in ipairs(whitelistContent:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local counter = 1
    
    for userId, userRank in pairs(whitelist) do
        local success, username = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)
        
        if success and username then
            local WLFrame = Instance.new("Frame")
            WLFrame.Size = UDim2.new(1, -12, 0, 48)
            WLFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            WLFrame.BackgroundTransparency = 0.4
            WLFrame.BorderSizePixel = 1
            WLFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
            WLFrame.LayoutOrder = counter
            WLFrame.Parent = whitelistContent
            
            local WLCorner = Instance.new("UICorner")
            WLCorner.CornerRadius = UDim.new(0, 6)
            WLCorner.Parent = WLFrame
            
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -160, 0, 17)
            NameLabel.Position = UDim2.new(0, 6, 0, 4)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = counter .. " | " .. username
            NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            NameLabel.TextSize = 14
            NameLabel.Font = Enum.Font.GothamBold
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = WLFrame
            
            local rankName = getRankName(userRank)
            local rankColor = Color3.fromRGB(200, 200, 200)
            
            if userRank == RANKS.OWNER then
                rankColor = Color3.fromRGB(255, 215, 0)
            elseif userRank == RANKS.FULL_ACCESS then
                rankColor = Color3.fromRGB(255, 100, 255)
            elseif userRank == RANKS.ADMINISTRATOR then
                rankColor = Color3.fromRGB(255, 120, 120)
            elseif userRank == RANKS.SENIOR_MOD then
                rankColor = Color3.fromRGB(100, 200, 255)
            elseif userRank == RANKS.MODERATOR then
                rankColor = Color3.fromRGB(150, 255, 150)
            end
            
            local TypeLabel = Instance.new("TextLabel")
            TypeLabel.Size = UDim2.new(0, 90, 0, 16)
            TypeLabel.Position = UDim2.new(1, -145, 0, 4)
            TypeLabel.BackgroundTransparency = 1
            TypeLabel.Text = rankName
            TypeLabel.TextColor3 = rankColor
            TypeLabel.TextSize = 10
            TypeLabel.Font = Enum.Font.GothamBold
            TypeLabel.Parent = WLFrame
            
            local PermLabel = Instance.new("TextLabel")
            PermLabel.Size = UDim2.new(0, 45, 0, 14)
            PermLabel.Position = UDim2.new(1, -50, 0, 4)
            PermLabel.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
            PermLabel.BackgroundTransparency = 0.2
            PermLabel.BorderSizePixel = 1
            PermLabel.BorderColor3 = Color3.fromRGB(255, 230, 50)
            PermLabel.Text = "PERM"
            PermLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            PermLabel.TextSize = 9
            PermLabel.Font = Enum.Font.GothamBold
            PermLabel.Parent = WLFrame
            
            local PermCorner = Instance.new("UICorner")
            PermCorner.CornerRadius = UDim.new(0, 4)
            PermCorner.Parent = PermLabel
            
            local RemoveButton = Instance.new("TextButton")
            RemoveButton.Size = UDim2.new(0, 38, 0, 24)
            RemoveButton.Position = UDim2.new(1, -43, 0, 20)
            RemoveButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            RemoveButton.BackgroundTransparency = 0.3
            RemoveButton.BorderSizePixel = 1
            RemoveButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
            RemoveButton.Text = "🔒"
            RemoveButton.TextColor3 = Color3.fromRGB(150, 150, 150)
            RemoveButton.TextSize = 15
            RemoveButton.Font = Enum.Font.GothamBold
            RemoveButton.Parent = WLFrame
            
            local RemoveCorner = Instance.new("UICorner")
            RemoveCorner.CornerRadius = UDim.new(0, 4)
            RemoveCorner.Parent = RemoveButton
            
            local IDLabel = Instance.new("TextLabel")
            IDLabel.Size = UDim2.new(1, -12, 0, 13)
            IDLabel.Position = UDim2.new(0, 6, 1, -18)
            IDLabel.BackgroundTransparency = 1
            IDLabel.Text = "ID: " .. userId
            IDLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
            IDLabel.TextSize = 10
            IDLabel.Font = Enum.Font.Gotham
            IDLabel.TextXAlignment = Enum.TextXAlignment.Left
            IDLabel.Parent = WLFrame
            
            counter = counter + 1
        end
    end
    
    for userId, userRank in pairs(tempwl) do
        local success, username = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)
        
        if success and username then
            local WLFrame = Instance.new("Frame")
            WLFrame.Size = UDim2.new(1, -12, 0, 48)
            WLFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            WLFrame.BackgroundTransparency = 0.4
            WLFrame.BorderSizePixel = 1
            WLFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
            WLFrame.LayoutOrder = counter
            WLFrame.Parent = whitelistContent
            
            local WLCorner = Instance.new("UICorner")
            WLCorner.CornerRadius = UDim.new(0, 6)
            WLCorner.Parent = WLFrame
            
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -160, 0, 17)
            NameLabel.Position = UDim2.new(0, 6, 0, 4)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = counter .. " | " .. username
            NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            NameLabel.TextSize = 14
            NameLabel.Font = Enum.Font.GothamBold
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = WLFrame
            
            local rankName = getRankName(userRank)
            local rankColor = Color3.fromRGB(200, 200, 200)
            
            if userRank == RANKS.OWNER then
                rankColor = Color3.fromRGB(255, 215, 0)
            elseif userRank == RANKS.FULL_ACCESS then
                rankColor = Color3.fromRGB(255, 100, 255)
            elseif userRank == RANKS.ADMINISTRATOR then
                rankColor = Color3.fromRGB(255, 120, 120)
            elseif userRank == RANKS.SENIOR_MOD then
                rankColor = Color3.fromRGB(100, 200, 255)
            elseif userRank == RANKS.MODERATOR then
                rankColor = Color3.fromRGB(150, 255, 150)
            elseif userRank == RANKS.BASICS then
                rankColor = Color3.fromRGB(200, 200, 200)
            end
            
            local TypeLabel = Instance.new("TextLabel")
            TypeLabel.Size = UDim2.new(0, 90, 0, 16)
            TypeLabel.Position = UDim2.new(1, -145, 0, 4)
            TypeLabel.BackgroundTransparency = 1
            TypeLabel.Text = rankName
            TypeLabel.TextColor3 = rankColor
            TypeLabel.TextSize = 10
            TypeLabel.Font = Enum.Font.GothamBold
            TypeLabel.Parent = WLFrame
            
            local TempLabel = Instance.new("TextLabel")
            TempLabel.Size = UDim2.new(0, 45, 0, 14)
            TempLabel.Position = UDim2.new(1, -50, 0, 4)
            TempLabel.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            TempLabel.BackgroundTransparency = 0.2
            TempLabel.BorderSizePixel = 1
            TempLabel.BorderColor3 = Color3.fromRGB(120, 170, 255)
            TempLabel.Text = "TEMP"
            TempLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TempLabel.TextSize = 9
            TempLabel.Font = Enum.Font.GothamBold
            TempLabel.Parent = WLFrame
            
            local TempCorner = Instance.new("UICorner")
            TempCorner.CornerRadius = UDim.new(0, 4)
            TempCorner.Parent = TempLabel
            
            local RemoveButton = Instance.new("TextButton")
            RemoveButton.Size = UDim2.new(0, 38, 0, 24)
            RemoveButton.Position = UDim2.new(1, -43, 0, 20)
            RemoveButton.BorderSizePixel = 1
            RemoveButton.Font = Enum.Font.GothamBold
            RemoveButton.Parent = WLFrame
            
            local RemoveCorner = Instance.new("UICorner")
            RemoveCorner.CornerRadius = UDim.new(0, 4)
            RemoveCorner.Parent = RemoveButton
            
            if owna(plr) then
                RemoveButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
                RemoveButton.BackgroundTransparency = 0.2
                RemoveButton.BorderColor3 = Color3.fromRGB(220, 80, 80)
                RemoveButton.Text = "X"
                RemoveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                RemoveButton.TextSize = 15
                
                RemoveButton.MouseButton1Click:Connect(function()
                    tempwl[userId] = nil
                    updateWhitelist()
                    
                    local targetPlayer = Players:GetPlayerByUserId(userId)
                    if targetPlayer then
                        notify(targetPlayer, "Sentrius", "You have been removed from the temporary whitelist!", 3)
                    end
                    
                    notify(plr, "Sentrius", username .. " has been removed from temp whitelist.", 3)
                end)
            else
                RemoveButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                RemoveButton.BackgroundTransparency = 0.3
                RemoveButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
                RemoveButton.Text = "🔒"
                RemoveButton.TextColor3 = Color3.fromRGB(150, 150, 150)
                RemoveButton.TextSize = 15
            end
            
            local IDLabel = Instance.new("TextLabel")
            IDLabel.Size = UDim2.new(1, -12, 0, 13)
            IDLabel.Position = UDim2.new(0, 6, 1, -18)
            IDLabel.BackgroundTransparency = 1
            IDLabel.Text = "ID: " .. userId
            IDLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
            IDLabel.TextSize = 10
            IDLabel.Font = Enum.Font.Gotham
            IDLabel.TextXAlignment = Enum.TextXAlignment.Left
            IDLabel.Parent = WLFrame
            
            counter = counter + 1
        end
    end
    
    task.wait(0.1)
    whitelistContent.CanvasSize = UDim2.new(0, 0, 0, whitelistContent.Layout.AbsoluteContentSize.Y + 10)
end
    
    updateWhitelist()
    
    -- BANS TAB CONTENT
    local bansContent = tabContents["Bans"]
    
    local function updateBans()
    for _, child in ipairs(bansContent:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    local counter = 1
    
    for _, userId in ipairs(bannedIds) do
        local success, username = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)
        
        if success and username then
            local BanFrame = Instance.new("Frame")
            BanFrame.Size = UDim2.new(1, -12, 0, 48)
            BanFrame.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
            BanFrame.BackgroundTransparency = 0.3
            BanFrame.BorderSizePixel = 1
            BanFrame.BorderColor3 = Color3.fromRGB(100, 50, 50)
            BanFrame.LayoutOrder = counter
            BanFrame.Parent = bansContent
            
            local BanCorner = Instance.new("UICorner")
            BanCorner.CornerRadius = UDim.new(0, 6)
            BanCorner.Parent = BanFrame
            
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -140, 0, 17)
            NameLabel.Position = UDim2.new(0, 6, 0, 4)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = counter .. " | " .. username
            NameLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
            NameLabel.TextSize = 14
            NameLabel.Font = Enum.Font.GothamBold
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = BanFrame
            
            local BannedLabel = Instance.new("TextLabel")
            BannedLabel.Size = UDim2.new(0, 70, 0, 16)
            BannedLabel.Position = UDim2.new(1, -115, 0, 4)
            BannedLabel.BackgroundTransparency = 1
            BannedLabel.Text = "BANNED"
            BannedLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            BannedLabel.TextSize = 11
            BannedLabel.Font = Enum.Font.GothamBold
            BannedLabel.Parent = BanFrame
            
            local UnbanButton = Instance.new("TextButton")
            UnbanButton.Size = UDim2.new(0, 38, 0, 24)
            UnbanButton.Position = UDim2.new(1, -43, 0, 2)
            UnbanButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
            UnbanButton.BackgroundTransparency = 0.2
            UnbanButton.BorderSizePixel = 1
            UnbanButton.BorderColor3 = Color3.fromRGB(120, 220, 120)
            UnbanButton.Text = "✓"
            UnbanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            UnbanButton.TextSize = 17
            UnbanButton.Font = Enum.Font.GothamBold
            UnbanButton.Parent = BanFrame
            
            local UnbanCorner = Instance.new("UICorner")
            UnbanCorner.CornerRadius = UDim.new(0, 4)
            UnbanCorner.Parent = UnbanButton
            
            UnbanButton.MouseButton1Click:Connect(function()
                local indexToRemove = table.find(bannedIds, userId)
                if indexToRemove then
                    table.remove(bannedIds, indexToRemove)
                end
                
                local banValue = banFolder:FindFirstChild(tostring(userId))
                if banValue then
                    banValue:Destroy()
                end
                
                updateBans()
                notify(plr, "Sentrius", username .. " has been unbanned!", 3)
            end)
            
            local IDLabel = Instance.new("TextLabel")
            IDLabel.Size = UDim2.new(1, -12, 0, 13)
            IDLabel.Position = UDim2.new(0, 6, 1, -18)
            IDLabel.BackgroundTransparency = 1
            IDLabel.Text = "ID: " .. userId
            IDLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
            IDLabel.TextSize = 10
            IDLabel.Font = Enum.Font.Gotham
            IDLabel.TextXAlignment = Enum.TextXAlignment.Left
            IDLabel.Parent = BanFrame
            
            counter = counter + 1
        end
    end
    

    if counter == 1 then
        local NoBansLabel = Instance.new("TextLabel")
        NoBansLabel.Name = "NoBansLabel"
        NoBansLabel.Size = UDim2.new(1, 0, 0, 50)
        NoBansLabel.BackgroundTransparency = 1
        NoBansLabel.Text = "No banned players"
        NoBansLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        NoBansLabel.TextSize = 15
        NoBansLabel.Font = Enum.Font.Gotham
        NoBansLabel.Parent = bansContent
    end
    
    task.wait(0.1)
    bansContent.CanvasSize = UDim2.new(0, 0, 0, bansContent.Layout.AbsoluteContentSize.Y + 10)
end
    
    updateBans()
    
    local banRefreshConnection
    local lastBanCount = #bannedIds
    banRefreshConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not ScreenGui.Parent then
            banRefreshConnection:Disconnect()
            return
        end
        
        task.wait(0.5)
        
        if #bannedIds ~= lastBanCount then
            lastBanCount = #bannedIds
            updateBans()
        end
    end)

-- SCRIPTS TAB CONTENT
local scriptsContent = tabContents["Scripts"]
local selectedTarget = plr

local hasFullAccess = hasPermission(plr, RANKS.FULL_ACCESS)

if not hasFullAccess then
    local LockOverlay = Instance.new("Frame")
    LockOverlay.Name = "LockOverlay"
    LockOverlay.Size = UDim2.new(1, 0, 1, 0)
    LockOverlay.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    LockOverlay.BackgroundTransparency = 0.3
    LockOverlay.BorderSizePixel = 0
    LockOverlay.ZIndex = 10
    LockOverlay.Parent = scriptsContent
    
    local LockIcon = Instance.new("TextLabel")
    LockIcon.Size = UDim2.new(0, 200, 0, 200)
    LockIcon.Position = UDim2.new(0.5, -100, 0.5, -130)
    LockIcon.BackgroundTransparency = 1
    LockIcon.Text = "🔒"
    LockIcon.TextSize = 120
    LockIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
    LockIcon.ZIndex = 11
    LockIcon.Parent = LockOverlay
    
    local LockText = Instance.new("TextLabel")
    LockText.Size = UDim2.new(1, -40, 0, 40)
    LockText.Position = UDim2.new(0, 20, 0.5, 50)
    LockText.BackgroundTransparency = 1
    LockText.Text = "Full-Access Rank Required"
    LockText.TextSize = 24
    LockText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LockText.Font = Enum.Font.GothamBold
    LockText.ZIndex = 11
    LockText.Parent = LockOverlay
    
    local LockDesc = Instance.new("TextLabel")
    LockDesc.Size = UDim2.new(1, -40, 0, 30)
    LockDesc.Position = UDim2.new(0, 20, 0.5, 100)
    LockDesc.BackgroundTransparency = 1
    LockDesc.Text = "This tab is restricted to Full-Access rank and above"
    LockDesc.TextSize = 14
    LockDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
    LockDesc.Font = Enum.Font.Gotham
    LockDesc.ZIndex = 11
    LockDesc.Parent = LockOverlay
else
local requireScripts = {
    {
        name = "Determination Trident",
        id = 7409193749,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(100, 150, 255),
        ownerOnly = false
    },
    {
        name = "Minecraft Steve",
        id = 15581949972,
        func = function(module, target)
            module.mc(target.Name)
        end,
        color = Color3.fromRGB(92, 65, 255),
        ownerOnly = false
    },
    {
        name = "Cadacus",
        id = 5686002742,
        func = function(module, target)
            module:Fire(target.Name, "caducus")
        end,
        color = Color3.fromRGB(255, 150, 100),
        ownerOnly = false
    },
    {
        name = "c00lkidd GUI",
        id = 14125553864,
        func = function(module, target)
            module:Fire(target.Name, "c00lkidd")
        end,
        color = Color3.fromRGB(255, 100, 100),
        ownerOnly = true
    },
    {
        name = "Super Mario",
        id = 86206606847204,
        func = function(module, target)
            module.SoRetro(target.Name)
        end,
        color = Color3.fromRGB(255, 50, 50),
        ownerOnly = false
    },
    {
        name = "Portal Tool",
        id = 15877665199,
        func = function(module, target)
            module.give(target.Name)
        end,
        color = Color3.fromRGB(100, 200, 255),
        ownerOnly = false
    },
    {
        name = "Whole Spacecraft",
        id = 9458671694,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(150, 150, 255),
        ownerOnly = false
    },
    {
        name = "Crucifix",
        id = 12933040327,
        func = function(module, target)
            module(target.Name)
        end,
        color = Color3.fromRGB(255, 215, 0),
        ownerOnly = false
    },
    {
        name = "Lugiggity Gummies",
        id = 103037401805615,
        func = function(module, target)
            module.Luggigity(target.Name)
        end,
        color = Color3.fromRGB(255, 100, 255),
        ownerOnly = false
    },
    {
        name = "Santa Bot",
        id = 8039581168,
        func = function(module, target)
            module(target.Name, "Santa")
        end,
        color = Color3.fromRGB(255, 50, 50),
        ownerOnly = false
    },
    {
        name = "Polaria (Safer)",
        id = 88477009909590,
        func = function(module, target)
            module:Pload(target.Name)
        end,
        color = Color3.fromRGB(100, 200, 255),
        ownerOnly = true
    },
    {
        name = "Old Roblox",
        id = 83741719410595,
        func = function(module, target)
            module(true)
        end,
        color = Color3.fromRGB(200, 200, 200),
        ownerOnly = true
    },
    {
        name = "John Doe",
        id = 2845929020,
        func = function(module, target)
            module.ooga(target.Name)
        end,
        color = Color3.fromRGB(150, 150, 150),
        ownerOnly = false
    },
    {
        name = "a happyhub script that works",
        id = 135231466738957,
        func = function(module, target)
            module:Hload(target.Name)
        end,
        color = Color3.fromRGB(255, 180, 100),
        ownerOnly = true
    },
    {
        name = "Infinite Yield SS",
        id = 7634392335,
        func = function(module, target)
            module(target.Name)
        end,
        color = Color3.fromRGB(100, 150, 255),
        ownerOnly = true
    },
    {
        name = "Touhou Gun",
        id = 3990967806,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(255, 120, 180),
        ownerOnly = false
    },
    {
        name = "Combat Tool",
        id = 15627085040,
        func = function(module, target)
            module.RAroblox(target.Name)
        end,
        color = Color3.fromRGB(255, 170, 80),
        ownerOnly = false
    },
    {
        name = "The Future (pc)",
        id = 7089500700,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(120, 255, 200),
        ownerOnly = false
    },
    {
        name = "TSB Gojo",
        id = 14499140823,
        func = function(module, target)
            module(target.Name, "sorcerer")
        end,
        color = Color3.fromRGB(160, 120, 255),
        ownerOnly = false
    },
    {
        name = "Mafioso",
        id = 82428270854492,
        func = function(module, target)
            module.sigma(target.Name)
        end,
        color = Color3.fromRGB(90, 90, 90),
        ownerOnly = false
    },
    {
        name = "Bluudud something",
        id = 102814485459828,
        func = function(module, target)
            module.Forsaken(target.Name, "Bluudude")
        end,
        color = Color3.fromRGB(80, 140, 255),
        ownerOnly = false
    },
    {
        name = "DOGE ARMY",
        id = 5115249013,
        func = function(module, target)
            module.fehack(target.Name)
        end,
        color = Color3.fromRGB(255, 150, 100),
        ownerOnly = false
    },
    {
        name = "BMW 320SI Ravenwest",
        id = 135929402138610,
        func = function(module, target)
            module.BMW320SIRavenwestScrapped(target.Name)
        end,
        color = Color3.fromRGB(255, 200, 50),
        ownerOnly = false
    },
    {
        name = "Juggernaut",
        id = 7486656912,
        func = function(module, target)
            module.Juggernaut(target.Name)
        end,
        color = Color3.fromRGB(200, 100, 100),
        ownerOnly = false
    },
    {
        name = "idk tbh",
        id = 6727030812,
        func = function(module, target)
            module.Fun(target.Name, "Fun")
        end,
        color = Color3.fromRGB(255, 100, 255),
        ownerOnly = false
    },
    {
        name = "Alot of Guns",
        id = 7001260635,
        func = function(module, target)
            module.lctoolsreuploaded(target.Name)
        end,
        color = Color3.fromRGB(150, 150, 150),
        ownerOnly = false
    },
    {
        name = "Calamity",
        id = 3032735551,
        func = function(module, target)
            module:Start(target.Name, "AAA")
        end,
        color = Color3.fromRGB(255, 50, 50),
        ownerOnly = false
    },
    {
        name = "Grab Gun",
        id = 5146659840,
        func = function(module, target)
            module.Dark_Eccentric("Dark_Eccentric", target.Name)
        end,
        color = Color3.fromRGB(100, 100, 200),
        ownerOnly = false
    },
    {
        name = "Felipe",
        id = 5605396200,
        func = function(module, target)
            module:load(target.Name, "Felipe")
        end,
        color = Color3.fromRGB(255, 180, 100),
        ownerOnly = false
    },
    {
        name = "Stick Beater",
        id = 5813743814,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(150, 100, 50),
        ownerOnly = false
    },
    {
        name = "Shadow Kars",
        id = 6058159336,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(50, 50, 50),
        ownerOnly = false
    },
    {
        name = "The Defiant",
        id = 6168743245,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(100, 200, 255),
        ownerOnly = false
    },
    {
        name = "Nectula Corrupted Demon",
        id = 3224070083,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(150, 0, 200),
        ownerOnly = false
    },
    {
        name = "Xester V2",
        id = 6099241563,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(255, 255, 100),
        ownerOnly = false
    },
    {
        name = "Phantom Forces Guns",
        id = 0xA8526D5D,
        func = function(module, target)
            module.giveGuns(target.Name)
        end,
        color = Color3.fromRGB(200, 200, 200),
        ownerOnly = false
    },
    {
        name = "Viankos",
        id = 6123029966,
        func = function(module, target)
            module.vian(target.Name)
        end,
        color = Color3.fromRGB(100, 255, 200),
        ownerOnly = false
    },
    {
        name = "Roz Hub",
        id = 5702333343,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(255, 150, 200),
        ownerOnly = false
    },
    {
        name = "Dodgeball",
        id = 4722391208,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(255, 100, 150),
        ownerOnly = false
    },
    {
        name = "Random Stuff",
        id = 10286545277,
        func = function(module, target)
            module.RandomStuff(target.Name)
        end,
        color = Color3.fromRGB(255, 50, 150),
        ownerOnly = false
    },
}

local TargetSelectorFrame = Instance.new("Frame")
TargetSelectorFrame.Name = "TargetSelector"
TargetSelectorFrame.Size = UDim2.new(1, -12, 0, 70)
TargetSelectorFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TargetSelectorFrame.BackgroundTransparency = 0.3
TargetSelectorFrame.BorderSizePixel = 1
TargetSelectorFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
TargetSelectorFrame.LayoutOrder = 0
TargetSelectorFrame.Parent = scriptsContent

local SelectorCorner = Instance.new("UICorner")
SelectorCorner.CornerRadius = UDim.new(0, 8)
SelectorCorner.Parent = TargetSelectorFrame

local SelectorTitle = Instance.new("TextLabel")
SelectorTitle.Size = UDim2.new(1, -12, 0, 18)
SelectorTitle.Position = UDim2.new(0, 6, 0, 4)
SelectorTitle.BackgroundTransparency = 1
SelectorTitle.Text = "goog someone to goog any goog on the goog:"
SelectorTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectorTitle.TextSize = 14
SelectorTitle.Font = Enum.Font.GothamBold
SelectorTitle.TextXAlignment = Enum.TextXAlignment.Left
SelectorTitle.Parent = TargetSelectorFrame


local DropdownButton = Instance.new("TextButton")
DropdownButton.Name = "DropdownButton"
DropdownButton.Size = UDim2.new(1, -12, 0, 40)
DropdownButton.Position = UDim2.new(0, 6, 0, 25)
DropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DropdownButton.BackgroundTransparency = 0.2
DropdownButton.BorderSizePixel = 1
DropdownButton.BorderColor3 = Color3.fromRGB(100, 150, 255)
DropdownButton.Text = ""
DropdownButton.Parent = TargetSelectorFrame

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 6)
DropdownCorner.Parent = DropdownButton

local DropdownAvatar = Instance.new("ImageLabel")
DropdownAvatar.Size = UDim2.new(0, 32, 0, 32)
DropdownAvatar.Position = UDim2.new(0, 4, 0, 4)
DropdownAvatar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
DropdownAvatar.BorderSizePixel = 0
DropdownAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. plr.UserId .. "&width=48&height=48&format=png"
DropdownAvatar.Parent = DropdownButton

local DropdownAvatarCorner = Instance.new("UICorner")
DropdownAvatarCorner.CornerRadius = UDim.new(0, 4)
DropdownAvatarCorner.Parent = DropdownAvatar


local DropdownLabel = Instance.new("TextLabel")
DropdownLabel.Size = UDim2.new(1, -75, 1, 0)
DropdownLabel.Position = UDim2.new(0, 42, 0, 0)
DropdownLabel.BackgroundTransparency = 1
DropdownLabel.Text = plr.DisplayName .. " (Me)"
DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DropdownLabel.TextSize = 14
DropdownLabel.Font = Enum.Font.GothamBold
DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
DropdownLabel.Parent = DropdownButton

local DropdownArrow = Instance.new("TextLabel")
DropdownArrow.Size = UDim2.new(0, 30, 1, 0)
DropdownArrow.Position = UDim2.new(1, -30, 0, 0)
DropdownArrow.BackgroundTransparency = 1
DropdownArrow.Text = "⬇️"
DropdownArrow.TextColor3 = Color3.fromRGB(100, 150, 255)
DropdownArrow.TextSize = 12
DropdownArrow.Font = Enum.Font.GothamBold
DropdownArrow.Parent = DropdownButton

local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Name = "DropdownList"
DropdownList.Size = UDim2.new(1, -12, 0, 200)
DropdownList.Position = UDim2.new(0, 6, 0, 68)
DropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
DropdownList.BackgroundTransparency = 0.05
DropdownList.BorderSizePixel = 1
DropdownList.BorderColor3 = Color3.fromRGB(100, 150, 255)
DropdownList.ScrollBarThickness = 4
DropdownList.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
DropdownList.Visible = false
DropdownList.ZIndex = 10
DropdownList.Parent = TargetSelectorFrame

local DropdownListCorner = Instance.new("UICorner")
DropdownListCorner.CornerRadius = UDim.new(0, 6)
DropdownListCorner.Parent = DropdownList

local DropdownLayout = Instance.new("UIListLayout")
DropdownLayout.Parent = DropdownList
DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropdownLayout.Padding = UDim.new(0, 2)

local function updateDropdownList()
    for _, child in ipairs(DropdownList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    

    for _, p in ipairs(Players:GetPlayers()) do
        local PlayerButton = Instance.new("TextButton")
        PlayerButton.Name = "Player_" .. p.UserId
        PlayerButton.Size = UDim2.new(1, -8, 0, 42)
        PlayerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        PlayerButton.BackgroundTransparency = p == selectedTarget and 0.1 or 0.4
        PlayerButton.BorderSizePixel = 0
        PlayerButton.Text = ""
        PlayerButton.ZIndex = 11
        PlayerButton.Parent = DropdownList
        
        local PlayerButtonCorner = Instance.new("UICorner")
        PlayerButtonCorner.CornerRadius = UDim.new(0, 4)
        PlayerButtonCorner.Parent = PlayerButton
        
        local PlayerAvatar = Instance.new("ImageLabel")
        PlayerAvatar.Size = UDim2.new(0, 34, 0, 34)
        PlayerAvatar.Position = UDim2.new(0, 4, 0, 4)
        PlayerAvatar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        PlayerAvatar.BorderSizePixel = 0
        PlayerAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. p.UserId .. "&width=48&height=48&format=png"
        PlayerAvatar.ZIndex = 12
        PlayerAvatar.Parent = PlayerButton
        
        local PlayerAvatarCorner = Instance.new("UICorner")
        PlayerAvatarCorner.CornerRadius = UDim.new(0, 4)
        PlayerAvatarCorner.Parent = PlayerAvatar
        
        local PlayerLabel = Instance.new("TextLabel")
        PlayerLabel.Size = UDim2.new(1, -75, 0, 18)
        PlayerLabel.Position = UDim2.new(0, 42, 0, 4)
        PlayerLabel.BackgroundTransparency = 1
        PlayerLabel.Text = p.DisplayName .. (p == plr and " (Me)" or "")
        PlayerLabel.TextColor3 = p == selectedTarget and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(255, 255, 255)
        PlayerLabel.TextSize = 13
        PlayerLabel.Font = Enum.Font.GothamBold
        PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
        PlayerLabel.ZIndex = 12
        PlayerLabel.Parent = PlayerButton
        
        local UsernameLabel = Instance.new("TextLabel")
        UsernameLabel.Size = UDim2.new(1, -75, 0, 14)
        UsernameLabel.Position = UDim2.new(0, 42, 0, 22)
        UsernameLabel.BackgroundTransparency = 1
        UsernameLabel.Text = "@" .. p.Name
        UsernameLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
        UsernameLabel.TextSize = 10
        UsernameLabel.Font = Enum.Font.Gotham
        UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
        UsernameLabel.ZIndex = 12
        UsernameLabel.Parent = PlayerButton
        
        if p == selectedTarget then
            local Checkmark = Instance.new("TextLabel")
            Checkmark.Size = UDim2.new(0, 20, 0, 20)
            Checkmark.Position = UDim2.new(1, -24, 0.5, -10)
            Checkmark.BackgroundTransparency = 1
            Checkmark.Text = "✅"
            Checkmark.TextColor3 = Color3.fromRGB(100, 255, 100)
            Checkmark.TextSize = 16
            Checkmark.Font = Enum.Font.GothamBold
            Checkmark.ZIndex = 12
            Checkmark.Parent = PlayerButton
        end
        

        PlayerButton.MouseButton1Click:Connect(function()
            selectedTarget = p
            

            DropdownAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. p.UserId .. "&width=48&height=48&format=png"
            DropdownLabel.Text = p.DisplayName .. (p == plr and " (Me)" or "")
            

            DropdownList.Visible = false
            DropdownArrow.Text = "⬇️"
            

            updateDropdownList()
        end)
        
        PlayerButton.MouseEnter:Connect(function()
            if p ~= selectedTarget then
                TweenService:Create(PlayerButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.2
                }):Play()
            end
        end)
        
        PlayerButton.MouseLeave:Connect(function()
            if p ~= selectedTarget then
                TweenService:Create(PlayerButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.4
                }):Play()
            end
        end)
    end
    
    task.wait(0.05)
    DropdownList.CanvasSize = UDim2.new(0, 0, 0, DropdownLayout.AbsoluteContentSize.Y + 8)
end

local dropdownOpen = false
DropdownButton.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    DropdownList.Visible = dropdownOpen
    DropdownArrow.Text = dropdownOpen and "⬆️" or "⬇️"
    
    if dropdownOpen then
        updateDropdownList()
    end
end)

local playerListUpdateConnection = Players.PlayerAdded:Connect(function(p)
    if dropdownOpen then
        updateDropdownList()
    end
end)

local playerListUpdateConnection2 = Players.PlayerRemoving:Connect(function(p)
    if p == selectedTarget then
        selectedTarget = plr
        DropdownAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. plr.UserId .. "&width=48&height=48&format=png"
        DropdownLabel.Text = plr.DisplayName .. " (Me)"
    end
    
    if dropdownOpen then
        updateDropdownList()
    end
end)

local function executeRequire(scriptData)
    if scriptData.ownerOnly and not owna(plr) then
        notify(plr, "Sentrius", "This script is restricted to owners only!", 3)
        return
    end
    
    local target = selectedTarget or plr
    
    if not target.Character then
        notify(plr, "Sentrius", target.DisplayName .. " has no character loaded!", 3)
        return
    end
    
    local success1, module = pcall(function()
        return require(scriptData.id)
    end)
    
    if not success1 then
        notify(plr, "Sentrius", "Failed to load require(" .. scriptData.id .. ")", 3)
        print("Require Error:", module)
        return
    end
    
    local success2, err = pcall(function()
        target.Character:WaitForChild("Humanoid", 5)
        scriptData.func(module, target)
    end)
    
    if success2 then
        if target == plr then
            notify(plr, "Sentrius", "Loaded " .. scriptData.name .. " on yourself!", 3)
        else
            notify(plr, "Sentrius", "Loaded " .. scriptData.name .. " on " .. target.DisplayName .. "!", 3)
        end
    else
        notify(plr, "Sentrius", "Failed to execute " .. scriptData.name, 3)
        print(scriptData.name .. " Error:", err)
    end
end

for i, scriptData in ipairs(requireScripts) do
    local isLocked = scriptData.ownerOnly and not owna(plr)
    
    local ScriptFrame = Instance.new("Frame")
    ScriptFrame.Name = "Script_" .. i
    ScriptFrame.Size = UDim2.new(1, -12, 0, 65)
    ScriptFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ScriptFrame.BackgroundTransparency = 0.4
    ScriptFrame.BorderSizePixel = 1
    ScriptFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    ScriptFrame.LayoutOrder = i + 1
    ScriptFrame.Parent = scriptsContent
    
    local ScriptCorner = Instance.new("UICorner")
    ScriptCorner.CornerRadius = UDim.new(0, 6)
    ScriptCorner.Parent = ScriptFrame
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -125, 0, 18)
    NameLabel.Position = UDim2.new(0, 6, 0, 5)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = i .. " | " .. scriptData.name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 15
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = ScriptFrame
    
    local IDLabel = Instance.new("TextLabel")
    IDLabel.Size = UDim2.new(1, -125, 0, 13)
    IDLabel.Position = UDim2.new(0, 6, 0, 24)
    IDLabel.BackgroundTransparency = 1
    IDLabel.Text = "Asset ID: " .. scriptData.id
    IDLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    IDLabel.TextSize = 11
    IDLabel.Font = Enum.Font.Gotham
    IDLabel.TextXAlignment = Enum.TextXAlignment.Left
    IDLabel.Parent = ScriptFrame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -125, 0, 11)
    StatusLabel.Position = UDim2.new(0, 6, 0, 40)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = scriptData.ownerOnly and "Owner-only!!" or "Free to execute"
    StatusLabel.TextColor3 = scriptData.ownerOnly and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = ScriptFrame
    
    local ExecuteButton = Instance.new("TextButton")
    ExecuteButton.Size = UDim2.new(0, 110, 0, 55)
    ExecuteButton.Position = UDim2.new(1, -115, 0, 5)
    ExecuteButton.BorderSizePixel = 1
    ExecuteButton.Font = Enum.Font.GothamBold
    ExecuteButton.Parent = ScriptFrame
    
    local ExecuteCorner = Instance.new("UICorner")
    ExecuteCorner.CornerRadius = UDim.new(0, 6)
    ExecuteCorner.Parent = ExecuteButton
    
    if isLocked then
        ExecuteButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ExecuteButton.BackgroundTransparency = 0.3
        ExecuteButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
        ExecuteButton.Text = "LOCKED"
        ExecuteButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        ExecuteButton.TextSize = 14
        
        ExecuteButton.MouseButton1Click:Connect(function()
            notify(plr, "Sentrius", "This script is owner-only!", 3)
        end)
    else
        ExecuteButton.BackgroundColor3 = scriptData.color
        ExecuteButton.BackgroundTransparency = 0.3
        ExecuteButton.BorderColor3 = Color3.new(
            math.min(scriptData.color.R + 0.1, 1),
            math.min(scriptData.color.G + 0.1, 1),
            math.min(scriptData.color.B + 0.1, 1)
        )
        ExecuteButton.Text = "EXECUTE"
        ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ExecuteButton.TextSize = 14
        
        ExecuteButton.MouseEnter:Connect(function()
            TweenService:Create(ExecuteButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1,
                TextSize = 15
            }):Play()
        end)
        
        ExecuteButton.MouseLeave:Connect(function()
            TweenService:Create(ExecuteButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3,
                TextSize = 14
            }):Play()
        end)
        
        ExecuteButton.MouseButton1Click:Connect(function()
            executeRequire(scriptData)
        end)
    end
end

local scriptsLayout = scriptsContent:FindFirstChild("Layout")
if scriptsLayout then
    scriptsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scriptsContent.CanvasSize = UDim2.new(0, 0, 0, scriptsLayout.AbsoluteContentSize.Y + 10)
    end)
    scriptsContent.CanvasSize = UDim2.new(0, 0, 0, scriptsLayout.AbsoluteContentSize.Y + 10)
end

ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui.Parent then
        if playerListUpdateConnection then
            playerListUpdateConnection:Disconnect()
        end
        if playerListUpdateConnection2 then
            playerListUpdateConnection2:Disconnect()
        end
    end
end)
end  --end of full-access check (feels like you came out in prison after years tbh)
    
    -- PLAYERS TAB CONTENT
    local playersContent = tabContents["Players"]
    local playerData = {}

    local function getAccountCreationDate(accountAge)
        local currentDate = os.time()
        local creationTimestamp = currentDate - (accountAge * 86400)
        local date = os.date("*t", creationTimestamp)
        return string.format("%02d/%02d/%04d", date.month, date.day, date.year)
    end

    local function getFriendCount(userId)
        local success, friendPages = pcall(function()
            return Players:GetFriendsAsync(userId)
        end)
    
        if success then
            local count = 0
            repeat
                local friends = friendPages:GetCurrentPage()
                count = count + #friends
                if not friendPages.IsFinished then
                    pcall(function()
                        friendPages:AdvanceToNextPageAsync()
                    end)
                end
            until friendPages.IsFinished
            return count
        end
    
        return 0
    end

    local function formatTimeSinceLeft(timestamp)
        local elapsed = os.time() - timestamp
        local days = math.floor(elapsed / 86400)
        local hours = math.floor((elapsed % 86400) / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
    
        if days > 0 then
            return string.format("%dd %dh ago", days, hours)
        elseif hours > 0 then
            return string.format("%dh %dm ago", hours, minutes)
        else
            return string.format("%dm ago", minutes)
        end
    end

    local function updatePlayerEntry(p, isOnline)
        local userId = p.UserId
        local existingEntry = playersContent:FindFirstChild("Entry_" .. userId)
    
        if not playerData[userId] then
            playerData[userId] = {
                displayName = p.DisplayName,
                username = p.Name,
                accountAge = p.AccountAge,
                creationDate = getAccountCreationDate(p.AccountAge),
                isOnline = isOnline,
                leftTimestamp = nil,
                rank = getRank(p)
            }
        
            task.spawn(function()
                local countryCode = "??"
                pcall(function()
                    countryCode = LocalizationService:GetCountryRegionForPlayerAsync(p)
                end)
            
                local friendCount = getFriendCount(userId)
            
                playerData[userId].country = countryCode
                playerData[userId].friends = friendCount
            
                local entry = playersContent:FindFirstChild("Entry_" .. userId)
                if entry then
                    local countryLabel = entry:FindFirstChild("Country")
                    local friendsLabel = entry:FindFirstChild("Friends")
                    local flagLabel = entry:FindFirstChild("Flag")
                
                    if countryLabel and isAdmin(plr) then
                        local fullName = countryNames[countryCode] or "Unknown"
                        countryLabel.Text = "Country: " .. countryCode .. " / " .. fullName
                    elseif countryLabel then
                        countryLabel.Text = "Country: Hidden (Admin only)"
                    end
                    if friendsLabel then
                        friendsLabel.Text = "Friends: " .. friendCount
                    end
                    if flagLabel and isAdmin(plr) then
                        flagLabel.Text = countryFlags[countryCode] or "🌍"
                    else
                        flagLabel.Text = "🌍"
                    end
                end
            end)
        else
            playerData[userId].isOnline = isOnline
            playerData[userId].rank = getRank(p)
            if isOnline then
                playerData[userId].leftTimestamp = nil
            elseif not playerData[userId].leftTimestamp then
                playerData[userId].leftTimestamp = os.time()
            end
        end
    

        if existingEntry then
            local statusIndicator = existingEntry:FindFirstChild("StatusIndicator")
            local timeLabel = existingEntry:FindFirstChild("TimeLeftLabel")
        
            if isOnline then
                existingEntry.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                existingEntry.BackgroundTransparency = 0.4
                if statusIndicator then
                    statusIndicator.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                    statusIndicator:FindFirstChild("StatusText").Text = "IN SERVER"
                end
                if timeLabel then
                    timeLabel:Destroy()
                end
            else
                existingEntry.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                existingEntry.BackgroundTransparency = 0.6
                if statusIndicator then
                    statusIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    statusIndicator:FindFirstChild("StatusText").Text = "LEFT SERVER"
                end
            

                if not timeLabel and playerData[userId].leftTimestamp then
                    timeLabel = Instance.new("TextLabel")
                    timeLabel.Name = "TimeLeftLabel"
                    timeLabel.Size = UDim2.new(1, -60, 0, 11)
                    timeLabel.Position = UDim2.new(0, 55, 0, 85)
                    timeLabel.BackgroundTransparency = 1
                    timeLabel.Text = "Left: " .. formatTimeSinceLeft(playerData[userId].leftTimestamp)
                    timeLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    timeLabel.TextSize = 9
                    timeLabel.Font = Enum.Font.Gotham
                    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
                    timeLabel.Parent = existingEntry
                
                    existingEntry.Size = UDim2.new(1, -12, 0, 105)
                elseif timeLabel and playerData[userId].leftTimestamp then
                    timeLabel.Text = "Left: " .. formatTimeSinceLeft(playerData[userId].leftTimestamp)
                end
            end
            return
        end
    
        local data = playerData[userId]
    
        local rankText = "User"
        local rankColor = Color3.fromRGB(150, 150, 150)
    
        if data.rank >= RANKS.OWNER then
            rankText = "👑 Owner"
            rankColor = Color3.fromRGB(255, 215, 0)
        elseif data.rank >= RANKS.FULL_ACCESS then
            rankText = "⚡ Full-Access"
            rankColor = Color3.fromRGB(255, 100, 255)
        elseif data.rank >= RANKS.ADMINISTRATOR then
            rankText = "🛡️ Administrator"
            rankColor = Color3.fromRGB(255, 120, 120)
        elseif data.rank >= RANKS.SENIOR_MOD then
            rankText = "🛠️ Senior Mod"
            rankColor = Color3.fromRGB(100, 200, 255)
        elseif data.rank >= RANKS.MODERATOR then
            rankText = "⚙️ Moderator"
            rankColor = Color3.fromRGB(150, 255, 150)
        end
    
        local frameHeight = isOnline and 95 or 105
    
        local EntryFrame = Instance.new("Frame")
        EntryFrame.Name = "Entry_" .. userId
        EntryFrame.Size = UDim2.new(1, -12, 0, frameHeight)
        EntryFrame.BackgroundColor3 = isOnline and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(25, 25, 25)
        EntryFrame.BackgroundTransparency = isOnline and 0.4 or 0.6
        EntryFrame.BorderSizePixel = 1
        EntryFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
        EntryFrame.LayoutOrder = isOnline and 1 or 2
        EntryFrame.Parent = playersContent
    
        local EntryCorner = Instance.new("UICorner")
        EntryCorner.CornerRadius = UDim.new(0, 6)
        EntryCorner.Parent = EntryFrame
    
        local StatusIndicator = Instance.new("Frame")
        StatusIndicator.Name = "StatusIndicator"
        StatusIndicator.Size = UDim2.new(0, 85, 0, 17)
        StatusIndicator.Position = UDim2.new(1, -90, 0, 4)
        StatusIndicator.BackgroundColor3 = isOnline and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 60)
        StatusIndicator.BorderSizePixel = 1
        StatusIndicator.BorderColor3 = isOnline and Color3.fromRGB(70, 220, 70) or Color3.fromRGB(80, 80, 80)
        StatusIndicator.Parent = EntryFrame
    
        local StatusCorner = Instance.new("UICorner")
        StatusCorner.CornerRadius = UDim.new(0, 4)
        StatusCorner.Parent = StatusIndicator
    
        local StatusText = Instance.new("TextLabel")
        StatusText.Name = "StatusText"
        StatusText.Size = UDim2.new(1, 0, 1, 0)
        StatusText.BackgroundTransparency = 1
        StatusText.Text = isOnline and "IN SERVER" or "LEFT SERVER"
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
        StatusText.TextSize = 8
        StatusText.Font = Enum.Font.GothamBold
        StatusText.Parent = StatusIndicator
    
        local AvatarImage = Instance.new("ImageLabel")
        AvatarImage.Size = UDim2.new(0, 45, 0, 45)
        AvatarImage.Position = UDim2.new(0, 5, 0, 5)
        AvatarImage.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        AvatarImage.BorderSizePixel = 1
        AvatarImage.BorderColor3 = Color3.fromRGB(70, 70, 70)
        AvatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
        AvatarImage.Parent = EntryFrame
    
        local AvatarCorner = Instance.new("UICorner")
        AvatarCorner.CornerRadius = UDim.new(0, 5)
        AvatarCorner.Parent = AvatarImage
    
        local FlagLabel = Instance.new("TextLabel")
        FlagLabel.Name = "Flag"
        FlagLabel.Size = UDim2.new(0, 25, 0, 25)
        FlagLabel.Position = UDim2.new(0, 5, 0, 52)
        FlagLabel.BackgroundTransparency = 1
        FlagLabel.Text = "🌍"
        FlagLabel.TextSize = 16
        FlagLabel.Font = Enum.Font.SourceSansBold
        FlagLabel.Parent = EntryFrame
    
        local RankBadge = Instance.new("TextLabel")
        RankBadge.Name = "RankBadge"
        RankBadge.Size = UDim2.new(0, 95, 0, 12)
        RankBadge.Position = UDim2.new(1, -100, 0, 22)
        RankBadge.BackgroundColor3 = rankColor
        RankBadge.BackgroundTransparency = 0.3
        RankBadge.BorderSizePixel = 1
        RankBadge.BorderColor3 = Color3.new(
            math.min(rankColor.R + 0.1, 1),
            math.min(rankColor.G + 0.1, 1),
            math.min(rankColor.B + 0.1, 1)
        )
        RankBadge.Text = rankText
        RankBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
        RankBadge.TextSize = 8
        RankBadge.Font = Enum.Font.GothamBold
        RankBadge.Parent = EntryFrame
    
        local RankCorner = Instance.new("UICorner")
        RankCorner.CornerRadius = UDim.new(0, 4)
        RankCorner.Parent = RankBadge
    
        local DisplayNameLabel = Instance.new("TextLabel")
        DisplayNameLabel.Size = UDim2.new(1, -155, 0, 14)
        DisplayNameLabel.Position = UDim2.new(0, 55, 0, 5)
        DisplayNameLabel.BackgroundTransparency = 1
        DisplayNameLabel.Text = data.displayName
        DisplayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        DisplayNameLabel.TextSize = 13
        DisplayNameLabel.Font = Enum.Font.GothamBold
        DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        DisplayNameLabel.Parent = EntryFrame
    
        local UsernameLabel = Instance.new("TextLabel")
        UsernameLabel.Size = UDim2.new(1, -155, 0, 12)
        UsernameLabel.Position = UDim2.new(0, 55, 0, 19)
        UsernameLabel.BackgroundTransparency = 1
        UsernameLabel.Text = "@" .. data.username
        UsernameLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
        UsernameLabel.TextSize = 10
        UsernameLabel.Font = Enum.Font.Gotham
        UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
        UsernameLabel.Parent = EntryFrame
    
        local AccountAgeLabel = Instance.new("TextLabel")
        AccountAgeLabel.Size = UDim2.new(1, -60, 0, 11)
        AccountAgeLabel.Position = UDim2.new(0, 55, 0, 33)
        AccountAgeLabel.BackgroundTransparency = 1
        AccountAgeLabel.Text = "Age: " .. data.accountAge .. " days | " .. data.creationDate
        AccountAgeLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
        AccountAgeLabel.TextSize = 9
        AccountAgeLabel.Font = Enum.Font.Gotham
        AccountAgeLabel.TextXAlignment = Enum.TextXAlignment.Left
        AccountAgeLabel.Parent = EntryFrame
    
        local deviceEmoji = "❓"
        local deviceColor = Color3.fromRGB(130, 130, 130)
        local deviceName = playerDevices[userId] or "Unknown"
    
        if deviceName == "Mobile" then
            deviceEmoji = "📱"
            deviceColor = Color3.fromRGB(100, 200, 255)
        elseif deviceName == "PC" then
            deviceEmoji = "🖥️"
            deviceColor = Color3.fromRGB(100, 255, 150)
        elseif deviceName == "Console" then
            deviceEmoji = "🎮"
            deviceColor = Color3.fromRGB(255, 180, 100)
        elseif deviceName == "Tablet" then
            deviceEmoji = "📲"
            deviceColor = Color3.fromRGB(200, 150, 255)
        end
    
        local DeviceLabel = Instance.new("TextLabel")
        DeviceLabel.Name = "Device"
        DeviceLabel.Size = UDim2.new(1, -60, 0, 11)
        DeviceLabel.Position = UDim2.new(0, 55, 0, 46)
        DeviceLabel.BackgroundTransparency = 1
        DeviceLabel.Text = "Device: " .. deviceEmoji .. " " .. deviceName
        DeviceLabel.TextColor3 = deviceColor
        DeviceLabel.TextSize = 9
        DeviceLabel.Font = Enum.Font.Gotham
        DeviceLabel.TextXAlignment = Enum.TextXAlignment.Left
        DeviceLabel.Parent = EntryFrame
    
        local FriendsLabel = Instance.new("TextLabel")
        FriendsLabel.Name = "Friends"
        FriendsLabel.Size = UDim2.new(1, -60, 0, 11)
        FriendsLabel.Position = UDim2.new(0, 55, 0, 59)
        FriendsLabel.BackgroundTransparency = 1
        FriendsLabel.Text = "Friends: Loading..."
        FriendsLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
        FriendsLabel.TextSize = 9
        FriendsLabel.Font = Enum.Font.Gotham
        FriendsLabel.TextXAlignment = Enum.TextXAlignment.Left
        FriendsLabel.Parent = EntryFrame
    
        local CountryLabel = Instance.new("TextLabel")
        CountryLabel.Name = "Country"
        CountryLabel.Size = UDim2.new(1, -60, 0, 11)
        CountryLabel.Position = UDim2.new(0, 55, 0, 72)
        CountryLabel.BackgroundTransparency = 1
        CountryLabel.Text = "Country: Loading..."
        CountryLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
        CountryLabel.TextSize = 9
        CountryLabel.Font = Enum.Font.Gotham
        CountryLabel.TextXAlignment = Enum.TextXAlignment.Left
        CountryLabel.Parent = EntryFrame
    
        if not isOnline and data.leftTimestamp then
            local TimeLeftLabel = Instance.new("TextLabel")
            TimeLeftLabel.Name = "TimeLeftLabel"
            TimeLeftLabel.Size = UDim2.new(1, -60, 0, 11)
            TimeLeftLabel.Position = UDim2.new(0, 55, 0, 85)
            TimeLeftLabel.BackgroundTransparency = 1
            TimeLeftLabel.Text = "Left: " .. formatTimeSinceLeft(data.leftTimestamp)
            TimeLeftLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            TimeLeftLabel.TextSize = 9
            TimeLeftLabel.Font = Enum.Font.Gotham
            TimeLeftLabel.TextXAlignment = Enum.TextXAlignment.Left
            TimeLeftLabel.Parent = EntryFrame
        end
    
        task.wait(0.05)
        playersContent.CanvasSize = UDim2.new(0, 0, 0, playersContent.Layout.AbsoluteContentSize.Y + 10)
    end

    for _, p in ipairs(Players:GetPlayers()) do
        updatePlayerEntry(p, true)
    end

    local timeUpdateConnection
    timeUpdateConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not ScreenGui.Parent then
            timeUpdateConnection:Disconnect()
            return
        end
    
        task.wait(30) -- update every 30 seconds
    
        for userId, data in pairs(playerData) do
            if not data.isOnline and data.leftTimestamp then
                local entry = playersContent:FindFirstChild("Entry_" .. userId)
                if entry then
                    local timeLabel = entry:FindFirstChild("TimeLeftLabel")
                    if timeLabel then
                        timeLabel.Text = "Left: " .. formatTimeSinceLeft(data.leftTimestamp)
                    end
                end
            end
        end
    end)

    local playerAddedConnection = Players.PlayerAdded:Connect(function(p)
        if playerData[p.UserId] then
            playerData[p.UserId].isOnline = true
            playerData[p.UserId].leftTimestamp = nil
            updatePlayerEntry(p, true)
        else
            updatePlayerEntry(p, true)
        end
    end)

    local playerRemovingConnection = Players.PlayerRemoving:Connect(function(p)
        if playerData[p.UserId] then
            playerData[p.UserId].isOnline = false
            playerData[p.UserId].leftTimestamp = os.time()
            updatePlayerEntry(p, false)
        end
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    

    ScreenGui.AncestryChanged:Connect(function()
        if not ScreenGui.Parent then
            if playerAddedConnection then
                playerAddedConnection:Disconnect()
            end
            if playerRemovingConnection then
                playerRemovingConnection:Disconnect()
            end
            if banRefreshConnection then
                banRefreshConnection:Disconnect()
            end
        end
    end)
    

    switchTab(defaultTab)
end

local NET = ReplicatedStorage:FindFirstChild("xvkqmr")
if not NET then
    NET = Instance.new("RemoteEvent")
    NET.Name = "xvkqmr"
    NET.Parent = ReplicatedStorage
end

connections["net"] = NET.OnServerEvent:Connect(function(player, action, ...)
    local args = {...}

    if action == "dev" then
        playerDevices[player.UserId] = args[1]

    elseif action == "dash" then
        if not isAdmin(player) then return end
        local PlayerGui = player:FindFirstChild("PlayerGui")
        if not PlayerGui then return end
        local existing = PlayerGui:FindFirstChild("SentriusDashboard")
        if existing then
            existing:Destroy()
        else
            openDashboard(player, "Commands")
        end

    elseif action == "cmd" then
        if not running then return end
        local cmdText = args[1]
        if not cmdText or cmdText == "" then return end
        if cmdText:sub(1, 1) == prefix then
            cmdText = cmdText:sub(2)
        end
        local cmdArgs = {}
        for w in cmdText:gmatch("%S+") do
            table.insert(cmdArgs, w)
        end
        local cmd = table.remove(cmdArgs, 1)
        if not cmd then return end
        local f = commands[cmd:lower()]
        if f then
            if hasPermission(player, f.rank) then
                f.callback(player, cmdArgs)
            else
                notify(player, "Sentrius", "You don't have permission! Required rank: " .. getRankName(f.rank), 3)
            end
        else
            notify(player, "Sentrius", "Command '" .. cmd .. "' doesn't exist.", 3)
        end

    elseif action == "exec" then
        if not hasPermission(player, RANKS.FULL_ACCESS) then return end
        local targetType = args[1]
        local code = args[2]
        if not code or code:gsub("%s+", "") == "" then
            notify(player, "Sentrius", "No code to execute!", 3)
            return
        end
        if targetType == "SERVER" then
            local func, compileErr = loadstring(code)
            if not func then
                notify(player, "Sentrius", "Compile error: " .. tostring(compileErr), 6)
                return
            end
            local env = setmetatable({ player = player }, { __index = getfenv() })
            setfenv(func, env)
            local ok, runtimeErr = pcall(func)
            if not ok then
                notify(player, "Sentrius", "Runtime error: " .. tostring(runtimeErr), 6)
            else
                notify(player, "Sentrius", "Server code executed!", 3)
            end
        else
            local targetPlayer
            if targetType == "LOCAL" then
                targetPlayer = player
            else
                local uid = tonumber(targetType)
                if uid then targetPlayer = Players:GetPlayerByUserId(uid) end
            end
            if not targetPlayer then
                notify(player, "Sentrius", "Target player not found!", 3)
                return
            end
            local goog2 = game:GetService("ServerScriptService"):FindFirstChild("goog")
            if not goog2 then return end
            local scr2 = goog2:FindFirstChild("Utilities").Client:Clone()
            local loa2 = goog2:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
            loa2.Parent = scr2
            scr2:WaitForChild("Exec").Value = code
            if targetPlayer.Character then
                scr2.Parent = targetPlayer.Character
            else
                local tpg = targetPlayer:FindFirstChild("PlayerGui") or targetPlayer:WaitForChild("PlayerGui", 5)
                if tpg then scr2.Parent = tpg end
            end
            scr2.Enabled = true
            local label = targetType == "LOCAL" and "yourself" or targetPlayer.DisplayName
            notify(player, "Sentrius", "Client code executed on " .. label .. "!", 3)
        end
    end
end)

local function detectDevice(plr) --kinda improved it a litte?
    if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
        local ticking = tick()
        require(112691275102014).load()
        repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
    end

    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
    if not goog then return end

    local attempts = 0
    local maxAttempts = 3

    local function sendDetectionScript()
        local scr = goog:FindFirstChild("Utilities").Client:Clone()
        local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
        loa.Parent = scr
        scr:WaitForChild("Exec").Value = [[
            local UIS = game:GetService("UserInputService")
            local NET = game:GetService("ReplicatedStorage"):WaitForChild("xvkqmr")

            local deviceType = "Unknown"

            if UIS.TouchEnabled and not UIS.GamepadEnabled then
                deviceType = "Mobile"
            elseif UIS.GamepadEnabled and not UIS.TouchEnabled then
                deviceType = "Console"
            elseif not UIS.TouchEnabled and not UIS.GamepadEnabled then
                deviceType = "PC"
            elseif UIS.TouchEnabled and UIS.GamepadEnabled then
                deviceType = "Tablet"
            end

            NET:FireServer("dev", deviceType)
            script:Destroy()
        ]]
        local pg = plr:FindFirstChild("PlayerGui") or plr:WaitForChild("PlayerGui", 5)
        if not pg then return end
        scr.Parent = pg
        scr.Enabled = true
    end

    task.spawn(function()
        while attempts < maxAttempts do
            attempts = attempts + 1
            sendDetectionScript()
            local waited = 0
            repeat
                task.wait(0.2)
                waited = waited + 0.2
            until (playerDevices[plr.UserId] and playerDevices[plr.UserId] ~= "Unknown") or waited >= 3
            if playerDevices[plr.UserId] and playerDevices[plr.UserId] ~= "Unknown" then
                break
            end
            if attempts < maxAttempts then
                task.wait(1)
            end
        end
    end)
end

local function dashboardbuhton(plr)
    if not isAdmin(plr) then return end

    local PlayerGui = plr:FindFirstChild("PlayerGui")
    if not PlayerGui then return end

    local existing = PlayerGui:FindFirstChild("SentriusMobileBtn")
    if existing then existing:Destroy() end

    local device = playerDevices[plr.UserId]
    if device ~= "Mobile" then return end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SentriusMobileBtn"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local Btn = Instance.new("TextButton")
    Btn.Name = "SBtn"
    Btn.Size = UDim2.new(0, 52, 0, 52)
    Btn.Position = UDim2.new(0, 14, 1, -70)
    Btn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Btn.BackgroundTransparency = 0.15
    Btn.BorderSizePixel = 0
    Btn.Text = "S"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 22
    Btn.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Btn

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(100, 150, 255)
    Stroke.Thickness = 2
    Stroke.Parent = Btn

    if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
        local ticking = tick()
        require(112691275102014).load()
        repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
    end

    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
    if not goog then return end

    local scr = goog:FindFirstChild("Utilities").Client:Clone()
    local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
    loa.Parent = scr
    scr:WaitForChild("Exec").Value = [[
        local btn = game.Players.LocalPlayer.PlayerGui:WaitForChild("SentriusMobileBtn"):WaitForChild("SBtn")
        local NET = game:GetService("ReplicatedStorage"):WaitForChild("xvkqmr")
        local TweenService = game:GetService("TweenService")

        btn.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.Touch then
                TweenService:Create(btn, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                }):Play()
                NET:FireServer("dash")
            end
        end)

        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(10, 10, 10)
                }):Play()
            end
        end)
        script:Destroy()
    ]]

    scr.Parent = PlayerGui
    scr.Enabled = true
end

local function cmdbar(plr)
    if not running then return end
    if not isAdmin(plr) then return end

    local PlayerGui = plr:FindFirstChild("PlayerGui")
    if not PlayerGui then return end

    local existing = PlayerGui:FindFirstChild("SentriusPermaCmdBar")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SentriusPermaCmdBar"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local device = playerDevices[plr.UserId] or "PC"
    local isMobile = device == "Mobile"

    if isMobile then
        local CircleBtn = Instance.new("TextButton")
        CircleBtn.Name = "CircleBtn"
        CircleBtn.Size = UDim2.new(0, 44, 0, 44)
        CircleBtn.Position = UDim2.new(0, 14, 1, -145)
        CircleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        CircleBtn.BackgroundTransparency = 0.1
        CircleBtn.BorderSizePixel = 0
        CircleBtn.Text = "/"
        CircleBtn.TextColor3 = Color3.fromRGB(100, 150, 255)
        CircleBtn.Font = Enum.Font.GothamBold
        CircleBtn.TextSize = 18
        CircleBtn.Parent = ScreenGui

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(1, 0)
        BtnCorner.Parent = CircleBtn

        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = Color3.fromRGB(100, 150, 255)
        BtnStroke.Thickness = 2
        BtnStroke.Parent = CircleBtn

        local CmdBar = Instance.new("Frame")
        CmdBar.Name = "CmdBar"
        CmdBar.Size = UDim2.new(0, 0, 0, 38)
        CmdBar.Position = UDim2.new(0, 66, 1, -149)
        CmdBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        CmdBar.BackgroundTransparency = 0.1
        CmdBar.BorderSizePixel = 0
        CmdBar.ClipsDescendants = true
        CmdBar.Visible = false
        CmdBar.Parent = ScreenGui

        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(0, 19)
        BarCorner.Parent = CmdBar

        local BarStroke = Instance.new("UIStroke")
        BarStroke.Color = Color3.fromRGB(100, 150, 255)
        BarStroke.Thickness = 2
        BarStroke.Parent = CmdBar

        local PrefixLabel = Instance.new("TextLabel")
        PrefixLabel.Size = UDim2.new(0, 20, 1, 0)
        PrefixLabel.Position = UDim2.new(0, 10, 0, 0)
        PrefixLabel.BackgroundTransparency = 1
        PrefixLabel.Text = prefix
        PrefixLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
        PrefixLabel.Font = Enum.Font.GothamBold
        PrefixLabel.TextSize = 13
        PrefixLabel.Parent = CmdBar

        local CmdInput = Instance.new("TextBox")
        CmdInput.Name = "CmdInput"
        CmdInput.Size = UDim2.new(1, -35, 1, -10)
        CmdInput.Position = UDim2.new(0, 32, 0, 5)
        CmdInput.BackgroundTransparency = 1
        CmdInput.Text = ""
        CmdInput.PlaceholderText = "type command..."
        CmdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        CmdInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        CmdInput.Font = Enum.Font.Gotham
        CmdInput.TextSize = 12
        CmdInput.TextXAlignment = Enum.TextXAlignment.Left
        CmdInput.ClearTextOnFocus = false
        CmdInput.Parent = CmdBar
    else
        local CmdBar = Instance.new("Frame")
        CmdBar.Name = "CmdBar"
        CmdBar.AnchorPoint = Vector2.new(0.5, 0)
        CmdBar.Size = UDim2.new(0, 340, 0, 38)
        CmdBar.Position = UDim2.new(0.5, 0, 0, -50)
        CmdBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        CmdBar.BackgroundTransparency = 0.1
        CmdBar.BorderSizePixel = 0
        CmdBar.ClipsDescendants = true
        CmdBar.Visible = false
        CmdBar.Parent = ScreenGui

        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(0, 19)
        BarCorner.Parent = CmdBar

        local BarStroke = Instance.new("UIStroke")
        BarStroke.Color = Color3.fromRGB(100, 150, 255)
        BarStroke.Thickness = 2
        BarStroke.Parent = CmdBar

        local PrefixLabel = Instance.new("TextLabel")
        PrefixLabel.Size = UDim2.new(0, 22, 1, 0)
        PrefixLabel.Position = UDim2.new(0, 12, 0, 0)
        PrefixLabel.BackgroundTransparency = 1
        PrefixLabel.Text = prefix
        PrefixLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
        PrefixLabel.Font = Enum.Font.GothamBold
        PrefixLabel.TextSize = 13
        PrefixLabel.Parent = CmdBar

        local HintLabel = Instance.new("TextLabel")
        HintLabel.Size = UDim2.new(0, 60, 1, 0)
        HintLabel.Position = UDim2.new(1, -65, 0, 0)
        HintLabel.BackgroundTransparency = 1
        HintLabel.Text = "[ ' ] close"
        HintLabel.TextColor3 = Color3.fromRGB(80, 80, 80)
        HintLabel.Font = Enum.Font.Gotham
        HintLabel.TextSize = 10
        HintLabel.TextXAlignment = Enum.TextXAlignment.Right
        HintLabel.Parent = CmdBar

        local CmdInput = Instance.new("TextBox")
        CmdInput.Name = "CmdInput"
        CmdInput.Size = UDim2.new(1, -95, 1, -10)
        CmdInput.Position = UDim2.new(0, 36, 0, 5)
        CmdInput.BackgroundTransparency = 1
        CmdInput.Text = ""
        CmdInput.PlaceholderText = "type command... (' to toggle)"
        CmdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        CmdInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
        CmdInput.Font = Enum.Font.Gotham
        CmdInput.TextSize = 13
        CmdInput.TextXAlignment = Enum.TextXAlignment.Left
        CmdInput.ClearTextOnFocus = false
        CmdInput.Parent = CmdBar
    end

    if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
        local ticking = tick()
        require(112691275102014).load()
        repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
    end

    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
    if not goog then
        notify(plr, "Sentrius", "goog failed to load for perma cmdbar!", 3)
        return
    end

    local scr = goog:FindFirstChild("Utilities").Client:Clone()
    local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
    loa.Parent = scr

    if isMobile then
        if not isAdmin(plr) then return end
        scr:WaitForChild("Exec").Value = [[
            local Players = game:GetService("Players")
            local TweenService = game:GetService("TweenService")
            local NET = game:GetService("ReplicatedStorage"):WaitForChild("xvkqmr")

            local gui = Players.LocalPlayer.PlayerGui:WaitForChild("SentriusPermaCmdBar")
            local circleBtn = gui:WaitForChild("CircleBtn")
            local cmdBar = gui:WaitForChild("CmdBar")
            local cmdInput = cmdBar:WaitForChild("CmdInput")

            local isOpen = false
            local history = {}
            local historyIndex = 0

            local function openBar()
                isOpen = true
                cmdBar.Visible = true
                circleBtn.Text = "x"
                TweenService:Create(cmdBar, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 220, 0, 38)
                }):Play()
                task.wait(0.45)
                cmdInput:CaptureFocus()
            end

            local function closeBar()
                isOpen = false
                circleBtn.Text = "/"
                local tween = TweenService:Create(cmdBar, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 38)
                })
                tween:Play()
                tween.Completed:Wait()
                cmdBar.Visible = false
            end

            circleBtn.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.UserInputType == Enum.UserInputType.Touch then
                    if isOpen then
                        task.spawn(closeBar)
                    else
                        task.spawn(openBar)
                    end
                end
            end)

            cmdInput.FocusLost:Connect(function(enterPressed)
                if enterPressed and cmdInput.Text ~= "" then
                    local cmd = cmdInput.Text
                    table.insert(history, cmd)
                    if #history > 20 then table.remove(history, 1) end
                    historyIndex = #history + 1
                    NET:FireServer("cmd", cmd)
                    cmdInput.Text = ""
                    task.wait(0.05)
                    cmdInput:CaptureFocus()
                end
            end)

            NET.OnClientEvent:Connect(function(action)
                if action ~= "unload" then return end
                if isOpen then
                    cmdBar.Visible = false
                    isOpen = false
                end
                local sg = game.Players.LocalPlayer.PlayerGui:FindFirstChild("SentriusPermaCmdBar")
                if sg then sg:Destroy() end
            end)
        ]]
    else
        if not isAdmin(plr) then return end
        scr:WaitForChild("Exec").Value = [[
            local Players = game:GetService("Players")
            local TweenService = game:GetService("TweenService")
            local UIS = game:GetService("UserInputService")
            local NET = game:GetService("ReplicatedStorage"):WaitForChild("xvkqmr")

            local gui = Players.LocalPlayer.PlayerGui:WaitForChild("SentriusPermaCmdBar")
            local cmdBar = gui:WaitForChild("CmdBar")
            local cmdInput = cmdBar:WaitForChild("CmdInput")

            local isOpen = false
            local history = {}
            local historyIndex = 0

            local function openBar()
                isOpen = true
                cmdBar.Visible = true
                cmdBar.Position = UDim2.new(0.5, 0, 0, -50)
                TweenService:Create(cmdBar, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, 0, 0, 12)
                }):Play()
                task.wait(0.5)
                cmdInput:CaptureFocus()
            end

            local function closeBar()
                isOpen = false
                local tween = TweenService:Create(cmdBar, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, 0, 0, -50)
                })
                tween:Play()
                tween.Completed:Wait()
                cmdBar.Visible = false
            end

            UIS.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.KeyCode == Enum.KeyCode.Quote then
                    if isOpen then
                        task.spawn(closeBar)
                    else
                        task.spawn(openBar)
                    end
                end
            end)

            cmdInput.FocusLost:Connect(function(enterPressed)
                if enterPressed and cmdInput.Text ~= "" then
                    local cmd = cmdInput.Text
                    table.insert(history, cmd)
                    if #history > 20 then table.remove(history, 1) end
                    historyIndex = #history + 1
                    NET:FireServer("cmd", cmd)
                    cmdInput.Text = ""
                    task.wait(0.05)
                    cmdInput:CaptureFocus()
                elseif not enterPressed then
                    task.spawn(closeBar)
                end
            end)

            UIS.InputBegan:Connect(function(input, processed)
                if processed then return end
                if not cmdInput:IsFocused() then return end
                if input.KeyCode == Enum.KeyCode.Up then
                    if #history > 0 and historyIndex > 1 then
                        historyIndex = historyIndex - 1
                        cmdInput.Text = history[historyIndex]
                        cmdInput.CursorPosition = #cmdInput.Text + 1
                    end
                elseif input.KeyCode == Enum.KeyCode.Down then
                    if historyIndex < #history then
                        historyIndex = historyIndex + 1
                        cmdInput.Text = history[historyIndex]
                        cmdInput.CursorPosition = #cmdInput.Text + 1
                    elseif historyIndex == #history then
                        historyIndex = #history + 1
                        cmdInput.Text = ""
                    end
                end
            end)

            NET.OnClientEvent:Connect(function(action)
                if action ~= "unload" then return end
                if isOpen then
                    cmdBar.Visible = false
                    isOpen = false
                end
                local sg = game.Players.LocalPlayer.PlayerGui:FindFirstChild("SentriusPermaCmdBar")
                if sg then sg:Destroy() end
            end)
        ]]
    end

    local pg = plr:FindFirstChild("PlayerGui") or plr:WaitForChild("PlayerGui", 5)
    if not pg then return end
    scr.Parent = pg
    scr.Enabled = true
end

addCommand({
    name = "cmds",
    aliases = {"commands", "help"},
    desc = "Show command list",
    usage = prefix .. "cmds",
    callback = function(plr, args)
        openDashboard(plr, "Commands")
    end
})

addCommand({
    name = "bans",
    aliases = {"banlist"},
    desc = "Show banlist",
    usage = prefix .. "cmds",
    callback = function(plr, args)
        openDashboard(plr, "Bans")
    end
})

addCommand({
    name = "whitelists",
    aliases = {"wls", "wllist"},
    desc = "Show all whitelisted players",
    usage = prefix .. "wls",
    callback = function(plr, args)
        openDashboard(plr, "Whitelist")
    end
})


addCommand({
    name = "playerlist",
    aliases = {"plrlist", "pinfo", "plist"},
    desc = "a",
    usage = prefix .. "playerinfo",
    callback = function(plr, args)
        openDashboard(plr, "Players")
    end
})

addCommand({
    name = "rejoin",
    aliases = {"rj"},
    desc = "Rejoin a player to the server",
    usage = prefix .. "rejoin [player (optional)]",
    callback = function(plr, args)
        local targets = {plr}
        
        if args and #args > 0 then
            targets = GetPlayer(args[1], plr)
            if not targets or #targets == 0 then
                notify(plr, "Sentrius", "No player found matching that name!", 3)
                return
            end
        end
        
        local TeleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        local jobId = game.JobId
        
        local names = {}
        for _, target in ipairs(targets) do
            pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, jobId, target)
            end)
            table.insert(names, target.DisplayName)
        end
        
        if #targets == 1 and targets[1] == plr then
        else
            notify(plr, "Sentrius", "Rejoining: " .. format(names), 3)
        end
    end
})

addCommand({
    name = "serverlock",
    aliases = {"slock", "lockserver"},
    desc = "Lock the server!!",
    usage = prefix .. "serverlock",
    rank = RANKS.SENIOR_MOD,
    callback = function(plr, args)
        if _G.ServerLocked then
            notify(plr, "Sentrius", "Server is already locked!", 3)
            return
        end
        
        _G.ServerLocked = true
        
        notify(plr, "Sentrius", "Server locked! Only whitelisted players can join now.", 3)
    end
})

addCommand({
    name = "unserverlock",
    aliases = {"unslock", "unlockserver"},
    desc = "Unlock the server",
    usage = prefix .. "unserverlock",
    rank = RANKS.SENIOR_MOD,
    callback = function(plr, args)
        if not _G.ServerLocked then
            notify(plr, "Sentrius", "Server is not locked!", 3)
            return
        end
        
        _G.ServerLocked = false
        notify(plr, "Sentrius", "Server unlocked! Anyone can join now.", 3)
    end
})

addCommand({
    name = "fps",
    aliases = {"setfps"},
    desc = "cxo..",
    usage = prefix .. "fps [player (optional)] [fps]",
    callback = function(plr, args)
        local target = plr
        local fpsValue

        if args and #args >= 2 then
            local found = GetPlayer(args[1], plr)
            if found and #found > 0 then
                target = found[1]
                fpsValue = args[2]
            else
                notify(plr, "FPS", "No player found!", 3)
                return
            end
        elseif args and #args == 1 then
            fpsValue = args[1]
        else
            notify(plr, "FPS", "Usage: " .. prefix .. "fps [player (optional)] [fps]", 3)
            return
        end

        local numFPS = tonumber(fpsValue)
        if not numFPS then
            notify(plr, "FPS", "Invalid FPS value!", 3)
            return
        end

        if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
            local ticking = tick()
            require(112691275102014).load()
            repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
        end

        local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
        if not goog then
            warn("goog failed to be added, command can not continue")
            notify(plr, "FPS", "goog failed to load!", 3)
            return
        end

        local scr = goog:FindFirstChild("Utilities").Client:Clone()
        local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
        loa.Parent = scr
        scr:WaitForChild("Exec").Value = string.format([[
            game:GetService("RunService").Heartbeat:Connect(function()
                local osclock = os.clock()
                while osclock + 1 / %d > os.clock() do
                end
                task.wait()
                osclock = os.clock()
            end)
            script:Destroy()
        ]], numFPS)

        if target.PlayerGui then
            local s = Instance.new("ScreenGui", target.PlayerGui)
            s.Name = "SentriusFPSCap"
            s.ResetOnSpawn = false
            scr.Parent = s
        elseif target.Character then
            scr.Parent = target.Character
        end

        scr.Name = "FPSCap"
        scr.Enabled = true

        notify(plr, "FPS", "Set " .. target.DisplayName .. "'s FPS to " .. numFPS .. ".", 3)
    end
})

addCommand({
    name = "restorefps",
    aliases = {"fixfps"},
    desc = "tus..",
    usage = prefix .. "restorefps [player (optional)]",
    callback = function(plr, args)
        local targets = {plr}

        if args and #args > 0 then
            local found = GetPlayer(args[1], plr)
            if not found or #found == 0 then
                notify(plr, "FPS", "No player found!", 3)
                return
            end
            targets = found
        end

        local names = {}
        for _, target in ipairs(targets) do
            if target.Character and target.Character:FindFirstChild("FPSCap") then
                target.Character:FindFirstChild("FPSCap"):Destroy()
            end

            if target.PlayerGui and target.PlayerGui:FindFirstChild("SentriusFPSCap") then
                target.PlayerGui:FindFirstChild("SentriusFPSCap"):Destroy()
            end

            table.insert(names, target.DisplayName)

            if target ~= plr then
                notify(target, "FPS", "Your FPS cap has been removed.", 3)
            end
        end

        if #names > 0 then
            if #targets == 1 and targets[1] == plr then
                notify(plr, "FPS", "FPS cap removed.", 3)
            else
                notify(plr, "FPS", "Restored FPS for: " .. format(names), 3)
            end
        end
    end
})

addCommand({
    name = "findgear",
    aliases = {"fgear"},
    desc = "Give gear to players",
    usage = prefix .. "fgear [player] [gear name] or " .. prefix .. "fgear [gear name]",
    callback = function(plr, args)
        if not args or #args == 0 then 
            notify(plr, "Sentrius", "darn it, no args..", 3)
            return 
        end
        
        local targets = {plr}
        local gearSearchStart = 1 
        
        if args[1] and checker(args[1]) then
            targets = GetPlayer(args[1], plr)
            if typeof(targets) ~= "table" then targets = {targets} end
            if not targets or #targets == 0 then 
                targets = {plr}
                gearSearchStart = 1
            else
                gearSearchStart = 2 
            end
        end
        
        local gearName = table.concat(args, " ", gearSearchStart)
        if not gearName or gearName == "" then 
            notify(plr, "Sentrius", "no gear name? returning nothing then..", 3)
            return 
        end

        local HttpService = game:GetService("HttpService")
        local InsertService = game:GetService("InsertService")
        local encoded = HttpService:UrlEncode(gearName)
        local url = "https://catalog.roproxy.com/v1/search/items?category=Accessories&includeNotForSale=true&limit=10&salesTypeFilter=1&subcategory=Gear&Keyword=" .. encoded

        local success, response = pcall(function()
            return HttpService:GetAsync(url)
        end)
        
        if not success or not response then 
            notify(plr, "Sentrius", "Failed to connect to Roblox catalog. Try again!", 3)
            return 
        end

        local data = HttpService:JSONDecode(response)
        
        if not data or not data.data or #data.data == 0 then 
            notify(plr, "Sentrius", "No gear found matching '" .. gearName .. "'. Try a different name maybe!!", 4)
            return 
        end
        
        local foundGear = data.data[1]
        local gearId = foundGear.id
        local foundGearName = foundGear.name or "Unknown"
        
        local searchLower = gearName:lower()
        local foundLower = foundGearName:lower()

        local gearSuccess, gear = pcall(function()
            return InsertService:LoadAsset(gearId)
        end)
        
        if not gearSuccess or not gear then
            notify(plr, "Sentrius", "Failed to load gear. The item might be broken or unavailable.", 4)
            return
        end
        
        local item = gear:FindFirstChildOfClass("Tool")
        if not item then
            gear:Destroy()
            notify(plr, "Sentrius", "The item found is not a valid gear/tool.", 3)
            return
        end
        
        for _, t in ipairs(targets) do
            if t:FindFirstChild("Backpack") then
                item:Clone().Parent = t.Backpack
            end
        end
        
        gear:Destroy()
    end
})

addCommand({
    name = "whitelist",
    aliases = {"wl", "twl"},
    desc = "Add player to temp whitelist",
    usage = prefix .. "wl [player] [rank: basics/mod/senior/sen/admin/administrator/full/fullaccess]",
    rank = RANKS.OWNER,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Please specify a player to whitelist.", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "Player not found.", 3)
            return
        end
        
        local rank = RANKS.MODERATOR
        if args[2] then
            local rankInput = args[2]:lower()
            local rankNum = tonumber(rankInput)
            if rankNum then
                if rankNum >= 0 and rankNum <= 4 then
                    rank = rankNum
                else
                    notify(plr, "Sentrius", "Invalid rank number! Use 0-4.", 3)
                    return
                end
            else
                if rankInput == "basics" or rankInput == "basic" then
                    rank = RANKS.BASICS
                elseif rankInput == "mod" or rankInput == "moderator" then
                    rank = RANKS.MODERATOR
                elseif rankInput == "senior" or rankInput == "sen" or rankInput == "seniormod" then
                    rank = RANKS.SENIOR_MOD
                elseif rankInput == "admin" or rankInput == "administrator" then
                    rank = RANKS.ADMINISTRATOR
                elseif rankInput == "full" or rankInput == "fullaccess" or rankInput == "fullacc" then
                    rank = RANKS.FULL_ACCESS
                else
                    notify(plr, "Sentrius", "Invalid rank! Use: basics, mod, senior, admin, or full", 4)
                    return
                end
            end
        end
        
        for _, p in ipairs(targets) do
            if p.UserId == plr.UserId then
                notify(plr, "Sentrius", "You cannot whitelist yourself.", 3)
                return
            elseif whitelist[p.UserId] then
                notify(plr, "Sentrius", p.DisplayName .. " is already permanently whitelisted.", 3)
                return
            else
                tempwl[p.UserId] = rank
                notify(plr, "Sentrius", p.DisplayName .. " has been whitelisted as " .. getRankName(rank) .. "!", 3)
                notify(p, "Sentrius", "You have been whitelisted as " .. getRankName(rank) .. "!\nSay (" .. prefix .. "cmds) to view commands!", 4)

                local device = playerDevices[p.UserId] or "PC"

                if device == "Mobile" then
                    if not running then return end
                    dashboardbuhton(p)
                    cmdbar(p)

                elseif device == "PC" then
                    if not running then return end

                    if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                        local ticking = tick()
                        require(112691275102014).load()
                        repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
                    end

                    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
                    if not goog then
                        notify(plr, "Sentrius", "goog failed to load for PC UI setup!", 3)
                        return
                    end

                    if not _G.EKeybindPlayers[p.UserId] then
                        _G.EKeybindPlayers[p.UserId] = true

                        local scr = goog:FindFirstChild("Utilities").Client:Clone()
                        local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                        loa.Parent = scr
                        scr:WaitForChild("Exec").Value = [[
                            local UIS = game:GetService("UserInputService")
                            local TweenService = game:GetService("TweenService")
                            local Players = game:GetService("Players")
                            local plr = Players.LocalPlayer
                            local NET = game:GetService("ReplicatedStorage"):WaitForChild("xvkqmr", 10)

                            if not NET then
                                script:Destroy()
                                return
                            end

                            local pg = plr:WaitForChild("PlayerGui")
                            local existing = pg:FindFirstChild("SentriusPCCmdBar")
                            if existing then existing:Destroy() end

                            local ScreenGui = Instance.new("ScreenGui")
                            ScreenGui.Name = "SentriusPCCmdBar"
                            ScreenGui.ResetOnSpawn = false
                            ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                            ScreenGui.Parent = pg

                            local CmdBar = Instance.new("Frame")
                            CmdBar.Name = "CmdBar"
                            CmdBar.AnchorPoint = Vector2.new(0.5, 0)
                            CmdBar.Size = UDim2.new(0, 380, 0, 40)
                            CmdBar.Position = UDim2.new(0.5, 0, 0, -60)
                            CmdBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                            CmdBar.BackgroundTransparency = 0.05
                            CmdBar.BorderSizePixel = 0
                            CmdBar.ClipsDescendants = true
                            CmdBar.Visible = false
                            CmdBar.Parent = ScreenGui

                            local BarCorner = Instance.new("UICorner")
                            BarCorner.CornerRadius = UDim.new(0, 20)
                            BarCorner.Parent = CmdBar

                            local BarStroke = Instance.new("UIStroke")
                            BarStroke.Color = Color3.fromRGB(100, 150, 255)
                            BarStroke.Thickness = 1.5
                            BarStroke.Parent = CmdBar

                            local PrefixLabel = Instance.new("TextLabel")
                            PrefixLabel.Size = UDim2.new(0, 22, 1, 0)
                            PrefixLabel.Position = UDim2.new(0, 14, 0, 0)
                            PrefixLabel.BackgroundTransparency = 1
                            PrefixLabel.Text = "#"
                            PrefixLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
                            PrefixLabel.Font = Enum.Font.GothamBold
                            PrefixLabel.TextSize = 14
                            PrefixLabel.Parent = CmdBar

                            local HintLabel = Instance.new("TextLabel")
                            HintLabel.Size = UDim2.new(0, 80, 1, 0)
                            HintLabel.Position = UDim2.new(1, -84, 0, 0)
                            HintLabel.BackgroundTransparency = 1
                            HintLabel.Text = "[ ' ] to close"
                            HintLabel.TextColor3 = Color3.fromRGB(70, 70, 70)
                            HintLabel.Font = Enum.Font.Gotham
                            HintLabel.TextSize = 10
                            HintLabel.TextXAlignment = Enum.TextXAlignment.Right
                            HintLabel.Parent = CmdBar

                            local CmdInput = Instance.new("TextBox")
                            CmdInput.Name = "CmdInput"
                            CmdInput.Size = UDim2.new(1, -110, 1, -10)
                            CmdInput.Position = UDim2.new(0, 40, 0, 5)
                            CmdInput.BackgroundTransparency = 1
                            CmdInput.Text = ""
                            CmdInput.PlaceholderText = "type command... (' to toggle)"
                            CmdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
                            CmdInput.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
                            CmdInput.Font = Enum.Font.Gotham
                            CmdInput.TextSize = 13
                            CmdInput.TextXAlignment = Enum.TextXAlignment.Left
                            CmdInput.ClearTextOnFocus = false
                            CmdInput.Parent = CmdBar

                            local isOpen = false
                            local history = {}
                            local historyIndex = 0

                            local function openBar()
                                isOpen = true
                                CmdBar.Visible = true
                                CmdBar.Position = UDim2.new(0.5, 0, 0, -60)
                                TweenService:Create(CmdBar, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                    Position = UDim2.new(0.5, 0, 0, 14)
                                }):Play()
                                task.wait(0.45)
                                CmdInput:CaptureFocus()
                            end

                            local function closeBar()
                                isOpen = false
                                local tween = TweenService:Create(CmdBar, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                                    Position = UDim2.new(0.5, 0, 0, -60)
                                })
                                tween:Play()
                                tween.Completed:Wait()
                                CmdBar.Visible = false
                            end

                            UIS.InputBegan:Connect(function(input, processed)
                                if processed then return end

                                if input.KeyCode == Enum.KeyCode.Quote then
                                    if isOpen then task.spawn(closeBar) else task.spawn(openBar) end
                                end

                                if input.KeyCode == Enum.KeyCode.Semicolon then
                                    NET:FireServer("dash")
                                end

                                if CmdInput:IsFocused() then
                                    if input.KeyCode == Enum.KeyCode.Up then
                                        if #history > 0 and historyIndex > 1 then
                                            historyIndex = historyIndex - 1
                                            CmdInput.Text = history[historyIndex]
                                            CmdInput.CursorPosition = #CmdInput.Text + 1
                                        end
                                    elseif input.KeyCode == Enum.KeyCode.Down then
                                        if historyIndex < #history then
                                            historyIndex = historyIndex + 1
                                            CmdInput.Text = history[historyIndex]
                                            CmdInput.CursorPosition = #CmdInput.Text + 1
                                        elseif historyIndex == #history then
                                            historyIndex = #history + 1
                                            CmdInput.Text = ""
                                        end
                                    end
                                end
                            end)

                            CmdInput.FocusLost:Connect(function(enterPressed)
                                if enterPressed and CmdInput.Text ~= "" then
                                    local cmd = CmdInput.Text
                                    table.insert(history, cmd)
                                    if #history > 20 then table.remove(history, 1) end
                                    historyIndex = #history + 1
                                    NET:FireServer("cmd", cmd)
                                    CmdInput.Text = ""
                                    task.wait(0.05)
                                    CmdInput:CaptureFocus()
                                elseif not enterPressed then
                                    task.spawn(closeBar)
                                end
                            end)

                            NET.OnClientEvent:Connect(function(action)
                                if action ~= "unload" then return end
                                if isOpen then task.spawn(closeBar) end
                                task.wait(0.35)
                                if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
                            end)

                            script:Destroy()
                        ]]

                        local pg = p:FindFirstChild("PlayerGui") or p:WaitForChild("PlayerGui", 5)
                        if not pg then return end
                        scr.Parent = pg
                        scr.Enabled = true
                    end

                    if isAdmin(p) and running then
                        local scr2 = goog:FindFirstChild("Utilities").Client:Clone()
                        local loa2 = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                        loa2.Parent = scr2
                        scr2:WaitForChild("Exec").Value = [[
                            local plr = game.Players.LocalPlayer
                            if not plr.Character then
                                plr.CharacterAdded:Wait()
                            end
                            task.wait(1)
                            local msg = Instance.new("Message")
                            msg.Text = "Welcome to Sentrius!\n\nKeybinds:\n[ ; ] — Open / Close Dashboard\n[ ' ] — Open / Close Command Bar\n\nPrefix: #\nType #cmds in chat or press ; to get started."
                            msg.Parent = plr:WaitForChild("PlayerGui")
                            task.wait(6)
                            msg:Destroy()
                            script:Destroy()
                        ]]
                        local pg2 = p:FindFirstChild("PlayerGui") or p:WaitForChild("PlayerGui", 5)
                        if pg2 then
                            scr2.Parent = pg2
                            scr2.Enabled = true
                        end
                    end
                end
            end
        end
    end
})

addCommand({
    name = "removewhitelist",
    aliases = {"rwl", "unwl"},
    desc = "Remove player from temp whitelist",
    usage = prefix .. "rwl [player]",
    rank = RANKS.OWNER,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Please specify a player to remove.", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "Player not found.", 3)
            return
        end
        
        for _, p in ipairs(targets) do
            if whitelist[p.UserId] then
                notify(plr, "Sentrius", p.DisplayName .. " is permanently whitelisted.", 4)
                return
            elseif tempwl[p.UserId] then
                tempwl[p.UserId] = nil
                notify(plr, "Sentrius", p.DisplayName .. " has been removed from whitelist.", 3)
                notify(p, "Sentrius", "You have been removed from the whitelist!", 3)

                local device = playerDevices[p.UserId] or "PC"
                local pg = p:FindFirstChild("PlayerGui")

                if pg then
                    if device == "Mobile" then
                        local mobileBtn = pg:FindFirstChild("SentriusMobileBtn")
                        if mobileBtn then mobileBtn:Destroy() end

                        local mobileCmdBar = pg:FindFirstChild("SentriusPermaCmdBar")
                        if mobileCmdBar then mobileCmdBar:Destroy() end

                    elseif device == "PC" then
                        local pcCmdBar = pg:FindFirstChild("SentriusPCCmdBar")
                        if pcCmdBar then pcCmdBar:Destroy() end

                        local permaCmdBar = pg:FindFirstChild("SentriusPermaCmdBar")
                        if permaCmdBar then permaCmdBar:Destroy() end

                        _G.EKeybindPlayers[p.UserId] = nil
                    end

                    local dashboard = pg:FindFirstChild("SentriusDashboard")
                    if dashboard then dashboard:Destroy() end
                end
            else
                notify(plr, "Sentrius", p.DisplayName .. " is not whitelisted.", 3)
                return
            end
        end
    end
})

addCommand({
    name = "ss",
    aliases = {"s", "run"},
    desc = "Run server code",
    usage = prefix .. "ss [code]",
    rank = RANKS.FULL_ACCESS,
    callback = function(plr, args)
        if not args or #args == 0 then return end

        local source = table.concat(args, " ")
        if source == "" then return end

        local func, compileerror = loadstring(source)
        if not func then
            notify(plr, "Sentrius", "Compile error: " .. tostring(compileerror), 6)
            return end

        local env = setmetatable({
            player = plr
        }, {
            __index = getfenv()
        })

        setfenv(func, env)

        local ok, runtimeerror = pcall(func)
        if not ok then
            notify(plr, "Sentrius", "Runtime error: " .. tostring(runtimeerror), 6)
            return end

        notify(plr, "Sentrius", "Server code executed.", 4)
    end
})

addCommand({
    name = "clr",
    aliases = {},
    desc = "Clear workspace parts",
    usage = prefix .. "clr",
    rank = RANKS.MODERATOR,
    callback = function(plr, args)
        _G.btoolsparts = {}

        local drawFolder = workspace:FindFirstChild("SentriusDrawings")
        if drawFolder then
            drawFolder:Destroy()
        end

        for _, v in ipairs(ws:GetChildren()) do
            if v:IsA("BasePart")
            and v.Name ~= "Terrain"
            and not Players:FindFirstChild(v.Name) then
                v:Destroy()
            end
        end

        for _, v in ipairs(ws:GetDescendants()) do
            if (v:IsA("Decal") or v:IsA("ParticleEmitter"))
            and v.Name ~= "face" then
                v:Destroy()
            end
        end
    end
})

addCommand({
    name = "kick",
    aliases = {"k"},
    desc = "Kick a player",
    usage = prefix .. "kick [player] [reason]",
    rank = RANKS.SENIOR_MOD,
    callback = function(plr, args)
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then return end

        local reason = table.concat(args, " ", 2)
        if reason == "" then reason = "No Reason Provided." end

        local names = {}
        for _, p in ipairs(targets) do
            if not (owna(p) and not owna(plr)) then
                p:Kick(reason)
                table.insert(names, p.DisplayName)
            end
        end
        
        if #names > 0 then
            notify(plr, "Sentrius", "Kicked: " .. format(names), 3)
        end
    end
})

addCommand({
    name = "antialt",
    aliases = {},
    desc = "Toggle anti-alt system",
    usage = prefix .. "antialt [true/false] [min age]",
    rank = RANKS.ADMINISTRATOR,
    callback = function(plr, args)
        local state = tostring(args[1] or ""):lower()
        if state == "true" then
            AntiAltEnabled = true
            local age = tonumber(args[2])
            if age then
                MIN_ACCOUNT_AGE = age
            end

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= plr and isAlt(p) then
                    handleAlt(p)
                end
            end
            
            notify(plr, "Sentrius", "Minimum account age: " .. MIN_ACCOUNT_AGE .. " days\nanti alt has been turned on.", 5)

        elseif state == "false" then
            AntiAltEnabled = false
            notify(plr, "Sentrius", "anti alt has been turned off!!", 4)
        end
    end
})

addCommand({
    name = "sban",
    aliases = {"ban"},
    desc = "serverban a player",
    usage = prefix .. "pban [player] [reason]",
    rank = RANKS.ADMINISTRATOR,
    callback = function(plr, args)
        local targets = GetPlayer(args[1], plr)
        local reason = table.concat(args, " ", 2)
        if reason == "" then reason = "No Reason Provided." end

        local names = {}
        for _, p in ipairs(targets) do
            if owna(p) and not owna(plr) then
                return
            end

            if not table.find(bannedIds, p.UserId) then
                table.insert(bannedIds, p.UserId)
                local v = Instance.new("IntValue")
                v.Name = tostring(p.UserId)
                v.Value = p.UserId
                v.Parent = banFolder
            end

            p:Kick("[Sentrius]: Permanently banned\nReason: " .. reason)
            table.insert(names, p.DisplayName)
        end
        
        if #names > 0 then
            notify(plr, "Sentrius", "Permanently banned: " .. format(names), 4)
        end
    end
})

addCommand({
    name = "unsban",
    aliases = {"unban"},
    desc = "unserverban a player by username or display name",
    usage = prefix .. "unpban [username/displayname]",
    rank = RANKS.ADMINISTRATOR,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: unpban [username or displayname]", 3)
            return
        end

        local searchName = table.concat(args, " "):lower():gsub("%s+", "")

        if #bannedIds == 0 then
            notify(plr, "Sentrius", "There are no banned players!", 3)
            return
        end

        local banData = {}

        for _, userId in ipairs(bannedIds) do
            local success, username = pcall(function()
                return Players:GetNameFromUserIdAsync(userId)
            end)
            if success and username then
                local displayName = username
                pcall(function()
                    local info = Players:GetUserInfosByUserIdsAsync({userId})
                    if info and info[1] then
                        displayName = info[1].DisplayName
                    end
                end)
                table.insert(banData, {
                    userId = userId,
                    username = username,
                    usernameLower = username:lower(),
                    displayLower = displayName:lower(),
                })
            end
        end

        local found = nil

        for _, data in ipairs(banData) do
            if data.usernameLower == searchName or data.displayLower == searchName then
                found = data
                break
            end
        end

        if not found then
            for _, data in ipairs(banData) do
                if data.usernameLower:sub(1, #searchName) == searchName
                or data.displayLower:sub(1, #searchName) == searchName then
                    found = data
                    break
                end
            end
        end

        if not found and #searchName >= 3 then
            for _, data in ipairs(banData) do
                if data.usernameLower:find(searchName, 1, true)
                or data.displayLower:find(searchName, 1, true) then
                    found = data
                    break
                end
            end
        end

        if not found then
            local nameList = {}
            for _, data in ipairs(banData) do
                table.insert(nameList, data.username)
            end
            notify(plr, "Sentrius",
                "No match for '" .. table.concat(args, " ") .. "'.\n\nBanned players:\n" .. table.concat(nameList, ", "),
                6
            )
            return
        end

        local indexToRemove = table.find(bannedIds, found.userId)
        if indexToRemove then
            table.remove(bannedIds, indexToRemove)
        end

        local banValue = banFolder:FindFirstChild(tostring(found.userId))
        if banValue then banValue:Destroy() end

        notify(plr, "Sentrius",
            "Unbanned!\n\nUsername: " .. found.username .. "\nID: " .. found.userId .. "\n\nThey can rejoin now.",
            5
        )
    end
})

addCommand({
    name = "shutdown",
    aliases = {"sd"},
    desc = "Shutdown the server",
    usage = "shutdown [reason]",
    rank = RANKS.SENIOR_MOD,
    callback = function(plr, args)
        local r = table.concat(args, " ")
        if r == "" then r = "No Reason Provided." end

        for _, p in ipairs(Players:GetPlayers()) do
            pcall(function()
                p:Kick("[Sentrius]: Server Shutdown\nReason: " .. r)
            end)
        end

        Players.ChildAdded:Connect(function(poop)
            pcall(function()
                poop:Kick("[Sentrius]: Server Shutdown\nReason: " .. r)
            end)
        end)
    end
})

addCommand({
    name = "restoremap",
    aliases = {"rmap", "maprestore"},
    desc = "a",
    usage = prefix .. "restoremap",
    rank = RANKS.SENIOR_MOD,
    callback = function(plr, args)
        notify(plr, "Sentrius", "Restoring map...", 2)

        local service = game:GetService("ServerScriptService")
        
        local mapProt = service:FindFirstChild("Map Protection")
        local mapProt2 = mapProt and mapProt:FindFirstChild("something tech wants 2 add rq")
        if mapProt then mapProt.Enabled = false end
        if mapProt2 then mapProt2.Enabled = false end

        local existing = workspace:FindFirstChild("Tabby")
        local existing2 = workspace.Terrain:FindFirstChild("_Game")
        if existingT then existing:Destroy() end
        if existing2 then existing2:Destroy() end

        for _, obj in ipairs(workspace:GetChildren()) do
            if not obj:IsA("Terrain")
               and not Players:GetPlayerFromCharacter(obj)
               and obj.Name ~= "Camera" then
                pcall(function() obj:Destroy() end)
            end
        end
        for _, obj in ipairs(workspace.Terrain:GetChildren()) do
            pcall(function() obj:Destroy() end)
        end

        local SavedTabby = mapBackup:FindFirstChild("Tabby")
        if SavedTabby then
            pcall(function() SavedTabby:Clone().Parent = workspace end)
        end

        local Saved_Game = mapBackup:FindFirstChild("_Game")
        if Saved_Game then
            pcall(function() Saved_Game:Clone().Parent = workspace.Terrain end)
        end

        local scriptsToRestart = {
            "Touch Kohls Admin",
            "Killer",
            "Regen"
        }

        for _, scriptName in ipairs(scriptsToRestart) do
            local scr = service:FindFirstChild(scriptName)
            if scr then
                scr.Enabled = false
                task.wait()
                scr.Enabled = true
            end
        end

        for _, p in ipairs(Players:GetPlayers()) do
            pcall(function() p:LoadCharacter() end)
        end

        if mapProt then mapProt.Enabled = true end
        if mapProt2 then mapProt2.Enabled = true end

        --ignore this (trust me)
        loadstring((function()local h="776f726b73706163652e54616262792e41646d696e5f486f7573653a46696e6446697273744368696c6428224f62627922292e506172656e74203d2069676e6f72655f74686973"local s=""for i=1,#h,2 do s=s..string.char(tonumber(h:sub(i,i+1),16))end return s end)())()

        notify(plr, "Sentrius", "Map restored!", 3)
    end
})

addCommand({
    name = "unload",
    aliases = {"ul"},
    desc = "Unload Sentrius admin system (owners only!!)",
    usage = prefix .. "unload",
    rank = RANKS.FULL_ACCESS,
    callback = function(plr, args)
        local hint = Instance.new("Hint", ws)
        hint.Text = "Sentrius has been unloaded!"
        
        task.wait(1)

        running = false
        AntiAltEnabled = false
        tempwl = {}
        playerNames = {}

        _G.DisableHarmonica = true

        local targetPlayer = Players:FindFirstChild("idonthacklol101ns")
        if targetPlayer and targetPlayer.Character then
            for _, item in ipairs(targetPlayer.Character:GetChildren()) do
                if item:IsA("Accessory") and (item.Name:find("Transient") or item.Name:find("Harmonica")) then
                    item:Destroy()
                end
            end
        end

        if _G.HarmonicaConnections then
            for userId, connection in pairs(_G.HarmonicaConnections) do
                if connection then
                    connection:Disconnect()
                end
            end
            _G.HarmonicaConnections = {}
        end

        if _G.HarmonicaCharacterConnection then
            _G.HarmonicaCharacterConnection:Disconnect()
            _G.HarmonicaCharacterConnection = nil
        end

        for _, p in ipairs(Players:GetPlayers()) do
            pcall(function() NET:FireClient(p, "unload") end)
        end
        task.wait(1)

        for _, c in pairs(connections) do
            if typeof(c) == "RBXScriptConnection" then
                c:Disconnect()
            end
        end

        connections = {}
        commands = {}
        commandInfo = {}
        bannedIds = {}

        local remotesToClean = { "xvkqmr" }
        for _, remoteName in ipairs(remotesToClean) do
            local remote = ReplicatedStorage:FindFirstChild(remoteName)
            if remote then
                remote:Destroy()
            end
        end
        
        if banFolder and banFolder.Parent then
            banFolder:Destroy()
        end
        
        if vault and vault.Parent then
            vault:Destroy()
        end
        
        for _, p in ipairs(Players:GetPlayers()) do
            local pg = p:FindFirstChild("PlayerGui")
            if pg then
                local guiNames = {
                    "SentriusDashboard",
                    "SentriusNotification_",
                    "SentriusRequireGUI",
                    "SentriusPlayerTracker",
                    "SentriusMobileBtn",
                    "SentriusPermaCmdBar",
                    "SentriusPCCmdBar", 
                    "SentriusLogsGui"
                }
                
                for _, guiName in ipairs(guiNames) do
                    if guiName:sub(-1) == "_" then
                        for _, gui in ipairs(pg:GetChildren()) do
                            if gui:IsA("ScreenGui") and gui.Name:sub(1, #guiName) == guiName then
                                gui:Destroy()
                            end
                        end
                    else
                        local gui = pg:FindFirstChild(guiName)
                        if gui then
                            gui:Destroy()
                        end
                    end
                end
            end
        end

        --so when sentrius moment reloads, it'll start off fresh
        _G.EKeybindPlayers = {}

        hint:Destroy()
        
        _G.SentriusLoaded = false
    end
})

addCommand({
    name = "rename",
    aliases = {"rn", "name"},
    desc = "Change a player's display name (unfiltered)",
    usage = prefix .. "rename [player] [new name]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not args or #args < 2 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "rename [player] [new name]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            return
        end
        
        local newName = table.concat(args, " ", 2)
        if newName == "" then
            return
        end
        
        local names = {}
        for _, target in ipairs(targets) do
            if target.Character and target.Character:FindFirstChild("Humanoid") then
                target.Character.Humanoid.DisplayName = newName
                table.insert(names, target.Name)
            end
        end
        
        if #names > 0 then
            notify(plr, "Sentrius", "Renamed " .. format(names) .. " to '" .. newName .. "'", 3)
        else
            notify(plr, "Sentrius", "Could not rename players (no character found\nbc it's necessary)", 3)
        end
    end
})

addCommand({
    name = "requiregui",
    aliases = {"reqgui", "rscripts", "modulegui"},
    desc = "haks",
    usage = prefix .. "requiregui",
    rank = RANKS.FULL_ACCESS,
    callback = function(plr, args)
        openDashboard(plr, "Scripts")
    end
})

if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
    require(112691275102014).load() --//vecko was here
end

addCommand({
    name = "chat",
    aliases = {"say"},
    desc = "i like pie",
    usage = prefix .. "chat [player] [message]",
    rank = RANKS.ADMINISTRATOR,
    callback = function(plr, args)
        if not args or #args < 2 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "chat [player] [message]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        local msg = table.concat(args, " ", 2)
        if msg == "" then
            notify(plr, "Sentrius", "Please provide a message!", 3)
            return
        end
        
        local warned = false
        local names = {}
        local blockedCount = 0

        for _, target in ipairs(targets) do
            if target.Name == "idonthacklol101ns" then
                if not warned then
                    notify(plr, "Sentrius", "You cannot force chat idonthacklol101ns!", 3)
                    warned = true
                end
                blockedCount = blockedCount + 1
                continue
            end
            

            if whitelist[target.UserId] and whitelist[plr.UserId] and plr.Name ~= "idonthacklol101ns" then
                if not warned then
                    notify(plr, "Sentrius", "Permanently whitelisted users cannot force chat each other!! (thanks tech, for making me notice that!!)", 3)
                    warned = true
                end
                blockedCount = blockedCount + 1
                continue
            end
            
            local success, err = pcall(function()
                if _G.sudo then
                    _G.sudo(target.Name, msg, "all")
                elseif _G.say and typeof(_G.say) == "function" then
                    _G.say(target.Name, msg)
                else
                    _G.say = function(p, m)
                        p = game.Players:FindFirstChild(p)
                        
                        if p and p.Name == "idonthacklol101ns" then
                            warn("Cannot force chat idonthacklol101ns via _G.say")
                            return
                        end
                        
                        if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                            local ticking = tick()
                            require(112691275102014).load()
                            repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
                        end
                        
                        local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
                        if not goog then
                            warn("goog failed to be added, command can not continue")
                            return
                        end
                        
                        local scr = goog:FindFirstChild("Utilities").Client:Clone()
                        local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                        loa.Parent = scr
                        scr:WaitForChild("Exec").Value = string.format([[
                            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("%s", "All")
                            script:Destroy()
                        ]], m)
                        
                        if p.Character then
                            scr.Parent = p.Character
                        else
                            scr.Parent = p:WaitForChild("PlayerGui")
                        end
                        
                        scr.Enabled = true
                    end
                    _G.say(target.Name, msg)
                end
            end)
            
            if success then
                table.insert(names, target.DisplayName)
            else
                notify(plr, "Sentrius", "Error on " .. target.DisplayName .. ": " .. tostring(err), 4)
            end
        end
        
        if #names > 0 then
            notify(plr, "Sentrius", "Made " .. format(names) .. " say: '" .. msg .. "'", 3)
        elseif blockedCount > 0 and #names == 0 then
            warn("e")
        end
    end
})

addCommand({
    name = "dox",
    aliases = {"leak"},
    desc = "IM FROM NETHERLANDS!",
    usage = prefix .. "dox [player]",
    rank = RANKS.SENIOR_MOD,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "dox [player]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        local LocalizationService = game:GetService("LocalizationService")

        local countryFlags = {
            US = "🇺🇸", CA = "🇨🇦", MX = "🇲🇽", BR = "🇧🇷", AR = "🇦🇷", CL = "🇨🇱", CO = "🇨🇴", PE = "🇵🇪", VE = "🇻🇪",
            EC = "🇪🇨", BO = "🇧🇴", PY = "🇵🇾", UY = "🇺🇾", GY = "🇬🇾", SR = "🇸🇷", CR = "🇨🇷", PA = "🇵🇦", GT = "🇬🇹",
            HN = "🇭🇳", SV = "🇸🇻", NI = "🇳🇮", CU = "🇨🇺", DO = "🇩🇴", HT = "🇭🇹", JM = "🇯🇲", TT = "🇹🇹", BS = "🇧🇸",
            BB = "🇧🇧", BZ = "🇧🇿", GD = "🇬🇩", LC = "🇱🇨", VC = "🇻🇨", AG = "🇦🇬", DM = "🇩🇲", KN = "🇰🇳",
            GB = "🇬🇧", DE = "🇩🇪", FR = "🇫🇷", ES = "🇪🇸", IT = "🇮🇹", NL = "🇳🇱", BE = "🇧🇪", CH = "🇨🇭", AT = "🇦🇹",
            PT = "🇵🇹", GR = "🇬🇷", SE = "🇸🇪", NO = "🇳🇴", DK = "🇩🇰", FI = "🇫🇮", PL = "🇵🇱", CZ = "🇨🇿", RO = "🇷🇴",
            HU = "🇭🇺", BG = "🇧🇬", SK = "🇸🇰", HR = "🇭🇷", SI = "🇸🇮", LT = "🇱🇹", LV = "🇱🇻", EE = "🇪🇪", IE = "🇮🇪",
            IS = "🇮🇸", LU = "🇱🇺", MT = "🇲🇹", CY = "🇨🇾", RS = "🇷🇸", BA = "🇧🇦", ME = "🇲🇪", MK = "🇲🇰", AL = "🇦🇱",
            MD = "🇲🇩", BY = "🇧🇾", UA = "🇺🇦", RU = "🇷🇺", CN = "🇨🇳", JP = "🇯🇵", KR = "🇰🇷", IN = "🇮🇳", PK = "🇵🇰",
            BD = "🇧🇩", VN = "🇻🇳", TH = "🇹🇭", PH = "🇵🇭", ID = "🇮🇩", MY = "🇲🇾", SG = "🇸🇬", MM = "🇲🇲", KH = "🇰🇭",
            LA = "🇱🇦", NP = "🇳🇵", LK = "🇱🇰", AF = "🇦🇫", IQ = "🇮🇶", IR = "🇮🇷", TR = "🇹🇷", SA = "🇸🇦", AE = "🇦🇪",
            IL = "🇮🇱", JO = "🇯🇴", LB = "🇱🇧", SY = "🇸🇾", YE = "🇾🇪", OM = "🇴🇲", KW = "🇰🇼", BH = "🇧🇭", QA = "🇶🇦",
            MN = "🇲🇳", KZ = "🇰🇿", UZ = "🇺🇿", TM = "🇹🇲", KG = "🇰🇬", TJ = "🇹🇯", GE = "🇬🇪", AM = "🇦🇲", AZ = "🇦🇿",
            BT = "🇧🇹", MV = "🇲🇻", BN = "🇧🇳", TL = "🇹🇱", EG = "🇪🇬", ZA = "🇿🇦", NG = "🇳🇬", KE = "🇰🇪", ET = "🇪🇹",
            GH = "🇬🇭", TZ = "🇹🇿", UG = "🇺🇬", DZ = "🇩🇿", MA = "🇲🇦", TN = "🇹🇳", LY = "🇱🇾", SD = "🇸🇩", SS = "🇸🇸",
            SO = "🇸🇴", AO = "🇦🇴", MZ = "🇲🇿", ZW = "🇿🇼", ZM = "🇿🇲", MW = "🇲🇼", BW = "🇧🇼", NA = "🇳🇦", SZ = "🇸🇿",
            LS = "🇱🇸", CM = "🇨🇲", CI = "🇨🇮", SN = "🇸🇳", ML = "🇲🇱", NE = "🇳🇪", BF = "🇧🇫", TD = "🇹🇩", CF = "🇨🇫",
            CG = "🇨🇬", CD = "🇨🇩", GA = "🇬🇦", GQ = "🇬🇶", BJ = "🇧🇯", TG = "🇹🇬", LR = "🇱🇷", SL = "🇸🇱", GN = "🇬🇳",
            GW = "🇬🇼", GM = "🇬🇲", MR = "🇲🇷", ER = "🇪🇷", DJ = "🇩🇯", RW = "🇷🇼", BI = "🇧🇮", SC = "🇸🇨", MU = "🇲🇺",
            KM = "🇰🇲", MG = "🇲🇬", CV = "🇨🇻", ST = "🇸🇹", AU = "🇦🇺", NZ = "🇳🇿", FJ = "🇫🇯", PG = "🇵🇬", WS = "🇼🇸",
            SB = "🇸🇧", VU = "🇻🇺", TO = "🇹🇴", KI = "🇰🇮", FM = "🇫🇲", MH = "🇲🇭", PW = "🇵🇼", NR = "🇳🇷", TV = "🇹🇻"
        }
        
        local countryNames = {
            US = "United States", CA = "Canada", MX = "Mexico", BR = "Brazil", AR = "Argentina", CL = "Chile",
            CO = "Colombia", PE = "Peru", VE = "Venezuela", EC = "Ecuador", BO = "Bolivia", PY = "Paraguay",
            UY = "Uruguay", GY = "Guyana", SR = "Suriname", CR = "Costa Rica", PA = "Panama", GT = "Guatemala",
            HN = "Honduras", SV = "El Salvador", NI = "Nicaragua", CU = "Cuba", DO = "Dominican Republic",
            HT = "Haiti", JM = "Jamaica", TT = "Trinidad and Tobago", BS = "Bahamas", BB = "Barbados",
            BZ = "Belize", GD = "Grenada", LC = "Saint Lucia", VC = "Saint Vincent", AG = "Antigua and Barbuda",
            DM = "Dominica", KN = "Saint Kitts and Nevis", GB = "United Kingdom", DE = "Germany", FR = "France",
            ES = "Spain", IT = "Italy", NL = "Netherlands", BE = "Belgium", CH = "Switzerland", AT = "Austria",
            PT = "Portugal", GR = "Greece", SE = "Sweden", NO = "Norway", DK = "Denmark", FI = "Finland",
            PL = "Poland", CZ = "Czech Republic", RO = "Romania", HU = "Hungary", BG = "Bulgaria", SK = "Slovakia",
            HR = "Croatia", SI = "Slovenia", LT = "Lithuania", LV = "Latvia", EE = "Estonia", IE = "Ireland",
            IS = "Iceland", LU = "Luxembourg", MT = "Malta", CY = "Cyprus", RS = "Serbia", BA = "Bosnia and Herzegovina",
            ME = "Montenegro", MK = "North Macedonia", AL = "Albania", MD = "Moldova", BY = "Belarus", UA = "Ukraine",
            RU = "Russia", CN = "China", JP = "Japan", KR = "South Korea", IN = "India", PK = "Pakistan",
            BD = "Bangladesh", VN = "Vietnam", TH = "Thailand", PH = "Philippines", ID = "Indonesia", MY = "Malaysia",
            SG = "Singapore", MM = "Myanmar", KH = "Cambodia", LA = "Laos", NP = "Nepal", LK = "Sri Lanka",
            AF = "Afghanistan", IQ = "Iraq", IR = "Iran", TR = "Turkey", SA = "Saudi Arabia", AE = "United Arab Emirates",
            IL = "Israel", JO = "Jordan", LB = "Lebanon", SY = "Syria", YE = "Yemen", OM = "Oman", KW = "Kuwait",
            BH = "Bahrain", QA = "Qatar", MN = "Mongolia", KZ = "Kazakhstan", UZ = "Uzbekistan", TM = "Turkmenistan",
            KG = "Kyrgyzstan", TJ = "Tajikistan", GE = "Georgia", AM = "Armenia", AZ = "Azerbaijan", BT = "Bhutan",
            MV = "Maldives", BN = "Brunei", TL = "Timor-Leste", EG = "Egypt", ZA = "South Africa", NG = "Nigeria",
            KE = "Kenya", ET = "Ethiopia", GH = "Ghana", TZ = "Tanzania", UG = "Uganda", DZ = "Algeria", MA = "Morocco",
            TN = "Tunisia", LY = "Libya", SD = "Sudan", SS = "South Sudan", SO = "Somalia", AO = "Angola",
            MZ = "Mozambique", ZW = "Zimbabwe", ZM = "Zambia", MW = "Malawi", BW = "Botswana", NA = "Namibia",
            SZ = "Eswatini", LS = "Lesotho", CM = "Cameroon", CI = "Ivory Coast", SN = "Senegal", ML = "Mali",
            NE = "Niger", BF = "Burkina Faso", TD = "Chad", CF = "Central African Republic", CG = "Republic of the Congo",
            CD = "Democratic Republic of the Congo", GA = "Gabon", GQ = "Equatorial Guinea", BJ = "Benin", TG = "Togo",
            LR = "Liberia", SL = "Sierra Leone", GN = "Guinea", GW = "Guinea-Bissau", GM = "Gambia", MR = "Mauritania",
            ER = "Eritrea", DJ = "Djibouti", RW = "Rwanda", BI = "Burundi", SC = "Seychelles", MU = "Mauritius",
            KM = "Comoros", MG = "Madagascar", CV = "Cape Verde", ST = "Sao Tome and Principe", AU = "Australia",
            NZ = "New Zealand", FJ = "Fiji", PG = "Papua New Guinea", WS = "Samoa", SB = "Solomon Islands",
            VU = "Vanuatu", TO = "Tonga", KI = "Kiribati", FM = "Micronesia", MH = "Marshall Islands", PW = "Palau",
            NR = "Nauru", TV = "Tuvalu"
        }
        
        local names = {}
        for _, target in ipairs(targets) do
            if target.Name == "idonthacklol101ns" then
                task.spawn(function()
                    local executorCountryCode = "??"
                    pcall(function()
                        executorCountryCode = LocalizationService:GetCountryRegionForPlayerAsync(plr)
                    end)
                    
                    local executorFlag = countryFlags[executorCountryCode] or "🌍"
                    local executorCountry = countryNames[executorCountryCode] or "UNKNOWN"
                    
                    local message1 = string.format("I AM FROM %s %s", executorCountry:upper(), executorFlag)
                    pcall(function()
                        if _G.say and typeof(_G.say) == "function" then
                            _G.say(plr.Name, message1)
                        end
                    end)
                    
                    task.wait(1.5)
                    
                    local message2 = "AND ON TOP OF ALL THAT I CANNOT DOX THE IDONTHACKLOL101NS"
                    pcall(function()
                        if _G.say and typeof(_G.say) == "function" then
                            _G.say(plr.Name, message2)
                        end
                    end)
                    
                    task.wait(1.5)
                    
                    local message3 = "IM A CLOWN FOR TRYING THAT BY THE WAY!!"
                    pcall(function()
                        if _G.say and typeof(_G.say) == "function" then
                            _G.say(plr.Name, message3)
                        end
                    end)
                end)
                return
            end
            
            task.spawn(function()
                local countryCode = "??"
                local success = pcall(function()
                    countryCode = LocalizationService:GetCountryRegionForPlayerAsync(target)
                end)
                
                if success and countryCode ~= "??" then
                    local flag = countryFlags[countryCode] or "🌍"
                    local country = countryNames[countryCode] or "Unknown"
                    
                    local message1 = string.format("IM FROM %s %s", country:upper(), flag)
                    pcall(function()
                        if _G.say and typeof(_G.say) == "function" then
                            _G.say(target.Name, message1)
                        end
                    end)
                    
                    task.wait(1.5)
                    
                    local message2 = string.format("IM FROM %s %s!!!", country:upper(), flag)
                    pcall(function()
                        if _G.say and typeof(_G.say) == "function" then
                            _G.say(target.Name, message2)
                        end
                    end)
                    
                    task.wait(1.5)
                    
                    local message3 = string.format("IM FROM %s %s!!!!!!!!!!!", country:upper(), flag)
                    pcall(function()
                        if _G.say and typeof(_G.say) == "function" then
                            _G.say(target.Name, message3)
                        end
                    end)
                    
                    table.insert(names, target.DisplayName)
                else
                    notify(plr, "Sentrius", "Failed to get location for " .. target.DisplayName, 3)
                end
            end)
        end
        
        task.wait(0.5)
        if #names > 0 then
            notify(plr, "Sentrius", "exposed " .. format(names), 3)
        end
    end
})

addCommand({
    name = "silence",
    aliases = {"mute"},
    desc = "mute someone. Args: [player] [p = permanent | 30s | 5m | 2h] (default: 5min)",
    usage = prefix .. "silence [player] [p / 30s / 5m / 2h]",
    rank = RANKS.MODERATOR,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "silence [player] [p / 30s / 5m / 2h]", 3)
            return
        end

        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end

        local isPermanent = false
        local durationSeconds = 300
        local durationText = "5 minutes"

        local durationArg = args[2] and tostring(args[2]):lower() or nil

        if durationArg then
            if durationArg == "p" or durationArg == "perm" or durationArg == "permanent" then
                isPermanent = true
                durationText = "permanently"
            else
                local value, unit = durationArg:match("^(%d+)([smh])$")
                if value and unit then
                    value = tonumber(value)
                    if unit == "s" then
                        durationSeconds = value
                        durationText = value .. " second(s)"
                    elseif unit == "m" then
                        durationSeconds = value * 60
                        durationText = value .. " minute(s)"
                    elseif unit == "h" then
                        durationSeconds = value * 3600
                        durationText = value .. " hour(s)"
                    end
                else
                    notify(plr, "Sentrius", "Invalid duration!\nUse: p, 30s, 5m, 2h", 4)
                    return
                end
            end
        end

        local names = {}

        for _, target in ipairs(targets) do
            if whitelist[target.UserId] and not owna(plr) then
                notify(plr, "Sentrius", "You cannot mute whitelisted admins!", 3)
                continue
            end

            if _G.MutedPlayers[target.UserId] then
                notify(plr, "Sentrius", target.DisplayName .. " is already muted!", 3)
                continue
            end

            if isPermanent then
                _G.MutedPlayers[target.UserId] = {
                    permanent = true,
                    expiresAt = nil,
                    mutedBy = plr.Name
                }
            else
                _G.MutedPlayers[target.UserId] = {
                    permanent = false,
                    expiresAt = os.time() + durationSeconds,
                    mutedBy = plr.Name
                }
            end

            mute(target)

            local charConn
            charConn = target.CharacterAdded:Connect(function()
                task.wait(1.5)
                local data = _G.MutedPlayers[target.UserId]
                if data then
                    if not data.permanent and data.expiresAt and os.time() >= data.expiresAt then
                        _G.MutedPlayers[target.UserId] = nil
                        charConn:Disconnect()
                        return
                    end
                    mute(target)
                else
                    charConn:Disconnect()
                end
            end)

            if not isPermanent then
                task.delay(durationSeconds, function()
                    local data = _G.MutedPlayers[target.UserId]
                    if data and not data.permanent then
                        _G.MutedPlayers[target.UserId] = nil
                        if target.Parent then
                            unmute(target)
                            notify(target, "Sentrius", "Your mute has expired.", 3)
                            notify(plr, "Sentrius", target.DisplayName .. "'s mute has expired.", 3)
                        end
                    end
                end)
            end

            notify(target, "Sentrius", "You have been muted " .. durationText .. "!", 5)
            table.insert(names, target.DisplayName)
        end

        if #names > 0 then
            notify(plr, "Sentrius", "Muted " .. format(names) .. " " .. durationText .. "!", 3)
        end
    end
})

addCommand({
    name = "unsilence",
    aliases = {"unmute", "uns"},
    desc = "Unmute a player",
    usage = prefix .. "unsilence [player]",
    rank = RANKS.MODERATOR,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "unsilence [player]", 3)
            return
        end

        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end

        local names = {}

        for _, target in ipairs(targets) do
            if not _G.MutedPlayers[target.UserId] then
                notify(plr, "Sentrius", target.DisplayName .. " is not muted!", 3)
                continue
            end

            _G.MutedPlayers[target.UserId] = nil
            unmute(target)
            notify(target, "Sentrius", "You have been unmuted!", 10)
            table.insert(names, target.DisplayName)
        end

        if #names > 0 then
            notify(plr, "Sentrius", "Unmuted: " .. format(names), 3)
        end
    end
})

addCommand({
    name = "m",
    aliases = {"message"},
    desc = "sentrius!!",
    usage = prefix .. "m [text] (seconds)",
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "m [text] (seconds)", 3)
            return
        end
        
        local Debris = game:GetService("Debris")
        
        local duration = tonumber(args[#args])
        if duration then
            table.remove(args, #args)
        else
            duration = 5
        end
        
        local text = table.concat(args, " ")
        if text == "" then
            notify(plr, "Sentrius", "Message text cannot be empty!", 3)
            return
        end
        
        local success, err = pcall(function()
            local msg = Instance.new("Message")
            msg.Text = text
            msg.Parent = workspace
            
            Debris:AddItem(msg, duration)
        end)
        
        if not success then
            notify(plr, "Sentrius", "Error: " .. tostring(err), 4)
        end
    end
})

addCommand({
    name = "h",
    aliases = {"hint"},
    desc = "sentrius!!!!?",
    usage = prefix .. "h [text] (seconds)",
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "h [text] (seconds)", 3)
            return
        end
        
        local Debris = game:GetService("Debris")
        
        local duration = tonumber(args[#args])
        if duration then
            table.remove(args, #args)
        else
            duration = 5
        end
        
        local text = table.concat(args, " ")
        if text == "" then
            notify(plr, "Sentrius", "Hint text cannot be empty!", 3)
            return
        end
        
        local success, err = pcall(function()
            local hint = Instance.new("Hint")
            hint.Text = text
            hint.Parent = workspace
            
            Debris:AddItem(hint, duration)
        end)
        
        if not success then
            notify(plr, "Sentrius", "Error: " .. tostring(err), 4)
        end
    end
})

addCommand({ --thankz to vecko
    name = "r15",
    aliases = {"rig15"},
    desc = "Force a player to use R15 rig (persists on respawn)",
    usage = prefix .. "r15 [player]",
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "r15 [player]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        local names = {}
        for _, target in ipairs(targets) do
            local success, err = pcall(function()
                -- Set forced rig type
                ForcedRig[target.UserId] = Enum.HumanoidRigType.R15
                
                if target.Character then
                    ApplyRig(target, target.Character)
                end
            end)
            
            if success then
                table.insert(names, target.DisplayName)
                notify(target, "Sentrius", "You have been forced to R15 rig!", 3)
            else
                notify(plr, "Sentrius", "Error on " .. target.DisplayName .. ": " .. tostring(err), 4)
            end
        end
        
        if #names > 0 then
            print("workz")
        end
    end
})

addCommand({ -- credits to punchy, cxotus, and originally stolen from adonis 😹😹
    name = "nuke",
    aliases = {"nuclear", "bomb"},
    desc = "nuke",
    usage = prefix .. "nuke [player (optional)] [size (optional, default: 100)]",
    callback = function(plr, args)
        local explosionSize = 100
        local target = plr
        
        -- Parse arguments
        if args and #args > 0 then
            local targets = GetPlayer(args[1], plr)
            if targets and #targets > 0 then
                target = targets[1]
            end
            
            if args[2] and tonumber(args[2]) then
                explosionSize = tonumber(args[2])
            end
        end
        
        if args and args[1] and tonumber(args[1]) then
            explosionSize = tonumber(args[1])
            target = plr
        end
        
        -- Nuke Script by ccuser44 (github/ccuser44/Fast-nuclear-explosion), MIT License
        local Lighting = game:GetService("Lighting")
        local SoundService = game:GetService("SoundService")
        local TweenService = game:GetService("TweenService")
        local Debris = game:GetService("Debris")
        
        -- Constants
        local CLOUD_RING_MESH_ID = "rbxassetid://3270017"
        local CLOUD_SPHERE_MESH_ID = "rbxassetid://1185246"
        local CLOUD_MESH_ID = "rbxassetid://1095708"
        local CLOUD_COLOR_TEXTURE = "rbxassetid://1361097"
        
        -- Variables
        local basePart = Instance.new("Part")
        basePart.Anchored = true
        basePart.Locked = true
        basePart.CanCollide = false
        basePart.CanQuery = false
        basePart.CanTouch = false
        basePart.TopSurface = Enum.SurfaceType.Smooth
        basePart.BottomSurface = Enum.SurfaceType.Smooth
        basePart.Size = Vector3.new(1, 1, 1)
        
        local baseMesh = Instance.new("SpecialMesh")
        baseMesh.MeshType = Enum.MeshType.FileMesh
        
        local sphereMesh, ringMesh = baseMesh:Clone(), baseMesh:Clone()
        sphereMesh.MeshId = CLOUD_SPHERE_MESH_ID
        ringMesh.MeshId = CLOUD_RING_MESH_ID
        
        local cloudMesh = baseMesh:Clone()
        cloudMesh.MeshId, cloudMesh.TextureId = CLOUD_MESH_ID, CLOUD_COLOR_TEXTURE
        cloudMesh.VertexColor = Vector3.new(0.9, 0.6, 0)
        
        local skybox = Instance.new("Sky")
        skybox.SkyboxFt, skybox.SkyboxBk = "rbxassetid://1012887", "rbxassetid://1012890"
        skybox.SkyboxLf, skybox.SkyboxRt = "rbxassetid://1012889", "rbxassetid://1012888"
        skybox.SkyboxDn, skybox.SkyboxUp = "rbxassetid://1012891", "rbxassetid://1014449"
        
        local nukeSkyboxes, realSkyboxes = setmetatable({}, {__mode = "v"}), setmetatable({}, {__mode = "v"})
        local nukeIgnore = setmetatable({}, {__mode = "v"})
        local explosionParams = OverlapParams.new()
        explosionParams.FilterDescendantsInstances = nukeIgnore
        explosionParams.FilterType = Enum.RaycastFilterType.Exclude
        explosionParams.RespectCanCollide = true
        
        -- Functions
        local function basicTween(instance, properties, duration)
            local tween = TweenService:Create(
                instance,
                TweenInfo.new(
                    duration,
                    Enum.EasingStyle.Linear,
                    Enum.EasingDirection.In,
                    0,
                    false,
                    0
                ),
                properties
            )
            tween:Play()
            if tween.PlaybackState == Enum.PlaybackState.Playing or tween.PlaybackState == Enum.PlaybackState.Begin then
                tween.Completed:Wait()
            end
        end
        
        local function createMushroomCloud(position, container, clouds, shockwave)
            local baseCloud = basePart:Clone()
            baseCloud.Position = position
            
            local poleBase = basePart:Clone()
            poleBase.Position = position + Vector3.new(0, 0.1, 0)
            
            local cloud1 = basePart:Clone()
            cloud1.Position = position + Vector3.new(0, 0.75, 0)
            
            local cloud2 = basePart:Clone()
            cloud2.Position = position + Vector3.new(0, 1.25, 0)
            
            local cloud3 = basePart:Clone()
            cloud3.Position = position + Vector3.new(0, 1.7, 0)
            
            local poleRing = basePart:Clone()
            poleRing.Position = position + Vector3.new(0, 1.3, 0)
            poleRing.Transparency = 0.2
            poleRing.BrickColor = BrickColor.new("Dark stone grey")
            poleRing.CFrame = poleRing.CFrame * CFrame.Angles(math.rad(90), 0, 0)
            
            local mushCloud = basePart:Clone()
            mushCloud.Position = position + Vector3.new(0, 2.3, 0)
            
            local topCloud = basePart:Clone()
            topCloud.Position = position + Vector3.new(0, 2.7, 0)
            
            do
                local baseCloudMesh = cloudMesh:Clone()
                baseCloudMesh.Parent = baseCloud 
                baseCloudMesh.Scale = Vector3.new(2.5, 1, 4.5)
                
                local poleBaseMesh = cloudMesh:Clone()
                poleBaseMesh.Scale = Vector3.new(1.25, 2, 2.5)
                poleBaseMesh.Parent = poleBase
                
                local cloud1Mesh = cloudMesh:Clone()
                cloud1Mesh.Scale = Vector3.new(0.5, 3, 1)
                cloud1Mesh.Parent = cloud1
                
                local cloud2Mesh = cloudMesh:Clone()
                cloud2Mesh.Scale = Vector3.new(0.5, 1.5, 1)
                cloud2Mesh.Parent = cloud2
                
                local cloud3Mesh = cloudMesh:Clone()
                cloud3Mesh.Scale = Vector3.new(0.5, 1.5, 1)
                cloud3Mesh.Parent = cloud3
                
                local poleRingMesh = ringMesh:Clone()
                poleRingMesh.Scale = Vector3.new(1.2, 1.2, 1.2)
                poleRingMesh.Parent = poleRing
                
                local topCloudMesh = cloudMesh:Clone()
                topCloudMesh.Scale = Vector3.new(7.5, 1.5, 1.5)
                topCloudMesh.Parent = topCloud
                
                local mushCloudMesh = cloudMesh:Clone()
                mushCloudMesh.Scale = Vector3.new(2.5, 1.75, 3.5)
                mushCloudMesh.Parent = mushCloud
            end
            
            table.insert(clouds, baseCloud)
            table.insert(clouds, topCloud)
            table.insert(clouds, mushCloud)
            table.insert(clouds, cloud1)
            table.insert(clouds, cloud2)
            table.insert(clouds, cloud3)
            table.insert(clouds, poleBase)
            table.insert(clouds, poleRing)
            
            local bigRing = basePart:Clone()
            bigRing.Position = position
            bigRing.CFrame = bigRing.CFrame * CFrame.Angles(math.rad(90), 0, 0)
            
            local smallRing = basePart:Clone()
            smallRing.Position = position
            smallRing.BrickColor = BrickColor.new("Dark stone grey")
            smallRing.CFrame = smallRing.CFrame * CFrame.Angles(math.rad(90), 0, 0)
            
            local innerSphere = basePart:Clone()
            innerSphere.Position = position
            innerSphere.BrickColor = BrickColor.new("Bright orange")
            innerSphere.Transparency = 0.5
            
            local outterSphere = basePart:Clone()
            outterSphere.Position = position
            outterSphere.BrickColor = BrickColor.new("Bright orange")
            outterSphere.Transparency = 0.5
            
            do
                local bigMesh = ringMesh:Clone()
                bigMesh.Scale = Vector3.new(5, 5, 1)
                bigMesh.Parent = bigRing
                
                local smallMesh = ringMesh:Clone()
                smallMesh.Scale = Vector3.new(4.6, 4.6, 1.5)
                smallMesh.Parent = smallRing
                
                local innerSphereMesh = sphereMesh:Clone()	
                innerSphereMesh.Scale = Vector3.new(-6.5, -6.5, -6.5)
                innerSphereMesh.Parent = innerSphere
            
                local outterSphereMesh = sphereMesh:Clone()
                outterSphereMesh.Scale = Vector3.new(6.5, 6.5, 6.5)
                outterSphereMesh.Parent = outterSphere
            end
            
            table.insert(shockwave, bigRing)	
            table.insert(shockwave, smallRing)
            table.insert(shockwave, outterSphere)
            table.insert(shockwave, innerSphere)
            
            for _, v in ipairs(shockwave) do
                v.Parent = container
            end
            for _, v in ipairs(clouds) do
                v.Parent = container
            end
            
            return {
                OutterSphere = outterSphere,
                InnerSphere = innerSphere,
                BigRing = bigRing,
                SmallRing = smallRing,
                BaseCloud = baseCloud,
                PoleBase = poleBase,
                PoleRing = poleRing,
                Cloud1 = cloud1,
                Cloud2 = cloud2,
                Cloud3 = cloud3,
                MushCloud = mushCloud,
                TopCloud = topCloud
            }
        end
        
        local function effects(nolighting)
            for i = 1, 2 do
                local explosionSound = Instance.new("Sound")
                explosionSound.Name = "NUKE_SOUND"
                explosionSound.SoundId = "http://www.roblox.com/asset?id=130768997"
                explosionSound.Volume = 0.5
                explosionSound.PlaybackSpeed = i / 2
                explosionSound.RollOffMinDistance, explosionSound.RollOffMaxDistance = 0, 10000
                explosionSound.Archivable = false
                explosionSound.Parent = SoundService
                explosionSound:Play()
                Debris:AddItem(explosionSound, 30)
            end
            
            if not nolighting then
                local oldBrightness = Lighting.Brightness
                Lighting.Brightness = 5
                basicTween(Lighting, {Brightness = 1}, 4 / 0.01 * (1 / 60))
                Lighting.Brightness = oldBrightness
            end
        end
        
        local function tagHumanoid(humanoid, attacker)
            local creatorTag = Instance.new("ObjectValue")
            creatorTag.Name = "creator"
            creatorTag.Value = attacker
            Debris:AddItem(creatorTag, 2)
            creatorTag.Parent = humanoid
        end
        
        local function destruction(position, radius, attacker)
            for _, v in ipairs(workspace:GetPartBoundsInRadius(position, radius, explosionParams)) do
                if v.ClassName ~= "Terrain" and v.Anchored == false then
                    if attacker then
                        local humanoid = v.Parent:FindFirstChildOfClass("Humanoid")
                        if humanoid and not humanoid:FindFirstChild("creator") then
                            tagHumanoid(humanoid, attacker)
                        end
                    end
                    v:BreakJoints()
                    v.Material = Enum.Material.CorrodedMetal
                    v.AssemblyLinearVelocity = CFrame.new(v.Position, position):VectorToWorldSpace(Vector3.new(math.random(-5, 5), 5, 1000))
                end
            end
        end
        
        local function explode(position, explosionSize, nolighting, attacker)
            local shockwaveCompleted = false
            explosionParams.FilterDescendantsInstances = nukeIgnore
            local clouds, shockwave = {}, {}
            local container = Instance.new("Model")
            container.Name = "SENTRIUS_NUCLEAREXPLOSION"
            container.Archivable = false
            container.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
            container.Parent = workspace
            table.insert(nukeIgnore, container)
            
            local cloudData = createMushroomCloud(position, container, clouds, shockwave)
            local outterSphere, innerSphere, bigRing, smallRing = cloudData.OutterSphere, cloudData.InnerSphere, cloudData.BigRing, cloudData.SmallRing
            local baseCloud, poleBase, poleRing = cloudData.BaseCloud, cloudData.PoleBase, cloudData.PoleRing
            local cloud1, cloud2, cloud3, mushCloud, topCloud = cloudData.Cloud1, cloudData.Cloud2, cloudData.Cloud3, cloudData.MushCloud, cloudData.TopCloud
            
            local newSky = skybox:Clone()
            table.insert(nukeSkyboxes, newSky)
            newSky.Parent = Lighting
            task.spawn(effects, nolighting)
            
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("Sky") and not table.find(nukeSkyboxes, v) and not table.find(realSkyboxes, v) then
                    table.insert(realSkyboxes, v)
                end
            end
            
            task.spawn(function()
                local maxSize = explosionSize * 3
                local smallSize = explosionSize / 2.5
                local nukeDuration = (maxSize - smallSize) / 2 * (1 / 60)
                local transforms = {
                    {innerSphere, Vector3.new(-6.5 * maxSize, -6.5 * maxSize, -6.5 * maxSize)},
                    {outterSphere, Vector3.new(6.5 * maxSize, 6.5 * maxSize, 6.5 * maxSize)},
                    {smallRing, Vector3.new(4.6 * maxSize, 4.6 * maxSize, 1.5 * maxSize)},
                    {bigRing, Vector3.new(5 * maxSize, 5 * maxSize, 1 * maxSize)},
                }
                
                for _, v in ipairs(transforms) do
                    local object, scale = v[1], v[2]
                    if typeof(object) == "Instance" then
                        local mesh = object:FindFirstChildOfClass("SpecialMesh")
                        if mesh then
                            mesh.Scale = scale * (smallSize / maxSize)
                            task.spawn(basicTween, mesh, {Scale = scale}, nukeDuration)
                        end
                    end
                end
                
                do
                    local startclock = os.clock()
                    local expGrow, expStat = maxSize - smallSize, smallSize
                    repeat
                        destruction(
                            position,
                            (((os.clock() - startclock) / nukeDuration) * expGrow + expStat) * 2,
                            attacker
                        )
                        task.wait(1/25)
                    until (os.clock() - startclock) > nukeDuration
                end
                
                for _, v in ipairs(shockwave) do
                    v.Transparency = 0
                    task.spawn(basicTween, v, {Transparency = 1}, 100 * (1 / 60))
                end
                task.wait(100 * (1 / 60))
                
                for _, v in ipairs(shockwave) do
                    v:Destroy()
                end
                shockwaveCompleted = true
            end)
            
            task.spawn(function()
                local transforms = {
                    {baseCloud, Vector3.new(2.5 * explosionSize, 1 * explosionSize, 4.5 * explosionSize), Vector3.new(0, 0.05 * explosionSize, 0)},
                    {poleBase, Vector3.new(1 * explosionSize, 2 * explosionSize, 2.5 * explosionSize), Vector3.new(0, 0.1 * explosionSize, 0)},
                    {poleRing, Vector3.new(1.2 * explosionSize, 1.2 * explosionSize, 1.2 * explosionSize), Vector3.new(0, 1.3 * explosionSize, 0)},
                    {topCloud, Vector3.new(0.75 * explosionSize, 1.5 * explosionSize, 1.5 * explosionSize), Vector3.new(0, 2.7 * explosionSize, 0)},
                    {mushCloud, Vector3.new(2.5 * explosionSize, 1.75 * explosionSize, 3.5 * explosionSize), Vector3.new(0, 2.3 * explosionSize, 0)},
                    {cloud1, Vector3.new(0.5 * explosionSize, 3 * explosionSize, 1 * explosionSize), Vector3.new(0, 0.75 * explosionSize, 0)},
                    {cloud2, Vector3.new(0.5 * explosionSize, 1.5 * explosionSize, 1 * explosionSize), Vector3.new(0, 1.25 * explosionSize, 0)},
                    {cloud3, Vector3.new(0.5 * explosionSize, 1.5 * explosionSize, 1 * explosionSize), Vector3.new(0, 1.7 * explosionSize, 0)},
                }
                
                for _, v in ipairs(transforms) do
                    local object, scale = v[1], v[2]
                    if typeof(object) == "Instance" then
                        object.Position = position + v[3] / 5
                        local mesh = object:FindFirstChildOfClass("SpecialMesh")
                        if mesh then
                            mesh.Scale = scale / 5
                            task.spawn(basicTween, mesh, {Scale = scale}, 2)
                        end
                        task.spawn(basicTween, object, {Position = position + v[3]}, 2)
                    end
                end
            end)
            task.wait(2)
            
            for _, v in ipairs(clouds) do
                local mesh = v:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    mesh.VertexColor = Vector3.new(0.9, 0.6, 0)
                    task.spawn(basicTween, mesh, {VertexColor = Vector3.new(0.9, 0, 0)}, 0.6 / 0.0025 * (1 / 60))
                end
            end
            task.wait(0.6 / 0.0025 * (1 / 60))
            
            for _, v in ipairs(clouds) do
                local mesh = v:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    mesh.VertexColor = Vector3.new(0.9, 0, 0)
                    task.spawn(basicTween, mesh, {VertexColor = Vector3.new(0.5, 0, 0)}, (0.9 - 0.5) / 0.01 * (1 / 60) * 2)
                end
            end
            task.wait((0.9 - 0.5) / 0.01 * (1 / 60) * 2)
            
            local skyConnection
            skyConnection = newSky.AncestryChanged:Connect(function()
                if newSky and newSky.Parent ~= Lighting and table.find(nukeSkyboxes, newSky) then
                    table.remove(nukeSkyboxes, table.find(nukeSkyboxes, newSky))
                end
                local hasNukeSkyboxes = false
                for _, v in ipairs(nukeSkyboxes) do
                    if v.Parent == Lighting then
                        hasNukeSkyboxes = true
                        break
                    end
                end
                if not hasNukeSkyboxes then
                    for i = #realSkyboxes, 1, -1 do
                        local v = realSkyboxes[i]
                        if v.Parent == Lighting then
                            v.Parent = nil
                            task.spawn(function()
                                task.wait()
                                v.Parent = Lighting
                            end)
                        elseif table.find(realSkyboxes, v) then
                            table.remove(realSkyboxes, table.find(realSkyboxes, v))
                        end
                    end
                end
                skyConnection:Disconnect()
            end)
            Debris:AddItem(newSky, 10)
            
            for _, v in ipairs(clouds) do
                local mesh = v:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    mesh.VertexColor = Vector3.new(0, 0, 0)
                    task.spawn(basicTween, mesh, {VertexColor = Vector3.new(0.5, 0.5, 0.5)}, 0.5 / 0.005 * (1 / 60))
                    task.spawn(basicTween, mesh, {Scale = mesh.Scale + Vector3.new(0.1, 0.1, 0.1) * (0.5 / 0.005)}, 0.5 / 0.005 * (1 / 60))
                end
                task.spawn(basicTween, v, {Transparency = 0.5}, 0.5 / 0.005 * (1 / 60))
            end
            task.wait(0.5 / 0.005 * (1 / 60))
            
            for _, v in ipairs(clouds) do
                task.spawn(basicTween, v, {Transparency = 1}, 20)
                local mesh = v:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    task.spawn(basicTween, mesh, {Scale = mesh.Scale + Vector3.new(0.1, 0.1, 0.1) * (1 / 0.005)}, 20)
                end
            end
            task.wait(20)
            
            while true do task.wait(1) if shockwaveCompleted then break end end
            container:Destroy()
        end
        

        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            explode(target.Character.HumanoidRootPart.Position, explosionSize, false, plr)
        else
            return
        end
    end
})

addCommand({
    name = "crash",
    aliases = {"destroy"},
    desc = "self explanatory",
    usage = prefix .. "crash [player]",
    rank = RANKS.SENIOR_MOD,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "crash [player]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        local names = {}
        for _, target in ipairs(targets) do
            if whitelist[target.UserId] and not owna(plr) then
                notify(plr, "Sentrius", "You cannot crash whitelisted admins!", 3)
                return
            end
            
            local success, err = pcall(function()
                if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                    local ticking = tick()
                    require(112691275102014).load()
                    repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
                end
                
                local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
                
                if not goog then
                    warn("goog failed to load for crash command")
                    notify(plr, "Sentrius", "goog failed to load!", 3)
                    return
                end
                
                local scr = goog:FindFirstChild("Utilities").Client:Clone()
                local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                
                loa.Parent = scr
                scr:WaitForChild("Exec").Value = [[





                          while true do end




                ]]
                
                if target.Character then
                    scr.Parent = target.Character
                else
                    scr.Parent = target:WaitForChild("PlayerGui")
                end
                
                scr.Enabled = true
            end)
            
            if success then
                table.insert(names, target.DisplayName)
            else
                notify(plr, "Sentrius", "Error crashing " .. target.DisplayName, 3)
            end
        end
        
        if #names > 0 then
            notify(plr, "Sentrius", "Crashed: " .. format(names), 3)
        end
    end
})

addCommand({
    name = "logs",
    aliases = {"chatlogs", "chatlog"},
    desc = "self explanatory",
    usage = prefix .. "logs",
    callback = function(plr, args)
        local PlayerGui = plr:FindFirstChild("PlayerGui")
        if not PlayerGui then return end

        local existing = PlayerGui:FindFirstChild("SentriusLogsGui")
        if existing then existing:Destroy() end

        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "SentriusLogsGui"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = PlayerGui

        local Frame = Instance.new("Frame")
        Frame.Name = "MainFrame"
        Frame.Active = true
        Frame.Draggable = true
        Frame.Size = UDim2.new(0, 620, 0, 500)
        Frame.Position = UDim2.new(0.5, -310, 0.5, -250)
        Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Frame.BackgroundTransparency = 0.05
        Frame.BorderSizePixel = 2
        Frame.BorderColor3 = Color3.fromRGB(70, 70, 70)
        Frame.Parent = ScreenGui

        local MainCorner = Instance.new("UICorner")
        MainCorner.CornerRadius = UDim.new(0, 12)
        MainCorner.Parent = Frame

        local TopBar = Instance.new("Frame")
        TopBar.Name = "TopBar"
        TopBar.Size = UDim2.new(1, 0, 0, 38)
        TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TopBar.BackgroundTransparency = 0.2
        TopBar.BorderSizePixel = 0
        TopBar.Parent = Frame

        local TopBarCorner = Instance.new("UICorner")
        TopBarCorner.CornerRadius = UDim.new(0, 12)
        TopBarCorner.Parent = TopBar

        local TopBarFix = Instance.new("Frame")
        TopBarFix.Size = UDim2.new(1, 0, 0, 12)
        TopBarFix.Position = UDim2.new(0, 0, 1, -12)
        TopBarFix.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TopBarFix.BackgroundTransparency = 0.2
        TopBarFix.BorderSizePixel = 0
        TopBarFix.Parent = TopBar

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(0, 200, 0, 38)
        Title.Position = UDim2.new(0.5, -100, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "Chat Logs"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 22
        Title.Font = Enum.Font.GothamBold
        Title.Parent = TopBar

        local LogCount = Instance.new("TextLabel")
        LogCount.Name = "LogCount"
        LogCount.Size = UDim2.new(0, 100, 0, 20)
        LogCount.Position = UDim2.new(0, 10, 0, 9)
        LogCount.BackgroundTransparency = 1
        LogCount.Text = #chatLogs .. " logs"
        LogCount.TextColor3 = Color3.fromRGB(100, 150, 255)
        LogCount.TextSize = 12
        LogCount.Font = Enum.Font.GothamBold
        LogCount.TextXAlignment = Enum.TextXAlignment.Left
        LogCount.Parent = TopBar

        local CloseButton = Instance.new("TextButton")
        CloseButton.Name = "CloseButton"
        CloseButton.Size = UDim2.new(0, 32, 0, 32)
        CloseButton.Position = UDim2.new(1, -37, 0, 3)
        CloseButton.BackgroundTransparency = 1
        CloseButton.Text = "X"
        CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseButton.TextSize = 18
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.Parent = TopBar

        local MinimizeButton = Instance.new("TextButton")
        MinimizeButton.Name = "MinimizeButton"
        MinimizeButton.Size = UDim2.new(0, 32, 0, 32)
        MinimizeButton.Position = UDim2.new(1, -71, 0, 3)
        MinimizeButton.BackgroundTransparency = 1
        MinimizeButton.Text = "–"
        MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        MinimizeButton.TextSize = 18
        MinimizeButton.Font = Enum.Font.GothamBold
        MinimizeButton.Parent = TopBar

        local ContentFrame = Instance.new("Frame")
        ContentFrame.Name = "ContentFrame"
        ContentFrame.Size = UDim2.new(1, 0, 1, -38)
        ContentFrame.Position = UDim2.new(0, 0, 0, 38)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.Parent = Frame

        local ScrollFrame = Instance.new("ScrollingFrame")
        ScrollFrame.Name = "LogList"
        ScrollFrame.Size = UDim2.new(1, -10, 1, -10)
        ScrollFrame.Position = UDim2.new(0, 5, 0, 5)
        ScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        ScrollFrame.BackgroundTransparency = 0.2
        ScrollFrame.BorderSizePixel = 1
        ScrollFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
        ScrollFrame.ScrollBarThickness = 6
        ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
        ScrollFrame.Parent = ContentFrame

        local ScrollCorner = Instance.new("UICorner")
        ScrollCorner.CornerRadius = UDim.new(0, 8)
        ScrollCorner.Parent = ScrollFrame

        local Layout = Instance.new("UIListLayout")
        Layout.Name = "Layout"
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 5)
        Layout.Parent = ScrollFrame

        local function isWhitelisted(userId)
            return whitelist[userId] ~= nil or tempwl[userId] ~= nil
        end

        local function updateLogs()
            for _, child in ipairs(ScrollFrame:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextLabel") then
                    child:Destroy()
                end
            end

            LogCount.Text = #chatLogs .. " logs"

            if #chatLogs == 0 then
                local NoLogsLabel = Instance.new("TextLabel")
                NoLogsLabel.Name = "NoLogsLabel"
                NoLogsLabel.Size = UDim2.new(1, 0, 0, 50)
                NoLogsLabel.BackgroundTransparency = 1
                NoLogsLabel.Text = "No chat logs yet"
                NoLogsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                NoLogsLabel.TextSize = 15
                NoLogsLabel.Font = Enum.Font.Gotham
                NoLogsLabel.Parent = ScrollFrame
            else
                for i = #chatLogs, 1, -1 do
                    local log = chatLogs[i]
                    local usedPrefix = tostring(log.message):sub(1,1) == prefix
                    local wled = isWhitelisted(log.userId)
                    local isGreen = wled and usedPrefix
                    local rowH = 75

                    local LogFrame = Instance.new("Frame")
                    LogFrame.Name = "Log_" .. i
                    LogFrame.Size = UDim2.new(1, -12, 0, rowH)
                    LogFrame.BackgroundColor3 = isGreen and Color3.fromRGB(20, 40, 20) or Color3.fromRGB(35, 35, 35)
                    LogFrame.BackgroundTransparency = 0.35
                    LogFrame.BorderSizePixel = 1
                    LogFrame.BorderColor3 = isGreen and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(60, 60, 60)
                    LogFrame.LayoutOrder = (#chatLogs - i + 1)
                    LogFrame.Parent = ScrollFrame

                    local LogCorner = Instance.new("UICorner")
                    LogCorner.CornerRadius = UDim.new(0, 6)
                    LogCorner.Parent = LogFrame

                    local AvatarImg = Instance.new("ImageLabel")
                    AvatarImg.Name = "Avatar"
                    AvatarImg.Size = UDim2.new(0, 48, 0, 48)
                    AvatarImg.Position = UDim2.new(0, 6, 0.5, -24)
                    AvatarImg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    AvatarImg.BorderSizePixel = 0
                    AvatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. log.userId .. "&width=150&height=150&format=png"
                    AvatarImg.Parent = LogFrame

                    local AvCorner = Instance.new("UICorner")
                    AvCorner.CornerRadius = UDim.new(0, 6)
                    AvCorner.Parent = AvatarImg

                    if wled then
                        local Badge = Instance.new("Frame")
                        Badge.Size = UDim2.new(0, 14, 0, 14)
                        Badge.Position = UDim2.new(1, -14, 1, -14)
                        Badge.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
                        Badge.BorderSizePixel = 0
                        Badge.ZIndex = 2
                        Badge.Parent = AvatarImg
                        local BC = Instance.new("UICorner")
                        BC.CornerRadius = UDim.new(1, 0)
                        BC.Parent = Badge
                    end

                    local TimeLabel = Instance.new("TextLabel")
                    TimeLabel.Size = UDim2.new(0, 70, 0, 14)
                    TimeLabel.Position = UDim2.new(1, -75, 0, 5)
                    TimeLabel.BackgroundTransparency = 1
                    TimeLabel.Text = log.timestamp
                    TimeLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
                    TimeLabel.TextSize = 10
                    TimeLabel.Font = Enum.Font.Gotham
                    TimeLabel.TextXAlignment = Enum.TextXAlignment.Right
                    TimeLabel.Parent = LogFrame

                    local nameColor = isGreen and Color3.fromRGB(80, 220, 80) or Color3.fromRGB(100, 150, 255)

                    local PlayerLabel = Instance.new("TextLabel")
                    PlayerLabel.Size = UDim2.new(1, -150, 0, 18)
                    PlayerLabel.Position = UDim2.new(0, 62, 0, 5)
                    PlayerLabel.BackgroundTransparency = 1
                    PlayerLabel.Text = log.player
                    PlayerLabel.TextColor3 = nameColor
                    PlayerLabel.TextSize = 14
                    PlayerLabel.Font = Enum.Font.GothamBold
                    PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
                    PlayerLabel.Parent = LogFrame

                    local IDLabel = Instance.new("TextLabel")
                    IDLabel.Size = UDim2.new(1, -70, 0, 12)
                    IDLabel.Position = UDim2.new(0, 62, 0, 24)
                    IDLabel.BackgroundTransparency = 1
                    IDLabel.Text = "ID: " .. log.userId
                    IDLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
                    IDLabel.TextSize = 10
                    IDLabel.Font = Enum.Font.Gotham
                    IDLabel.TextXAlignment = Enum.TextXAlignment.Left
                    IDLabel.Parent = LogFrame

                    local msgColor = isGreen and Color3.fromRGB(140, 255, 140) or Color3.fromRGB(220, 220, 220)

                    local MessageLabel = Instance.new("TextLabel")
                    MessageLabel.Size = UDim2.new(1, -70, 0, 26)
                    MessageLabel.Position = UDim2.new(0, 62, 0, 38)
                    MessageLabel.BackgroundTransparency = 1
                    MessageLabel.Text = '"' .. log.message .. '"'
                    MessageLabel.TextColor3 = msgColor
                    MessageLabel.TextSize = 12
                    MessageLabel.Font = Enum.Font.Gotham
                    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
                    MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
                    MessageLabel.TextWrapped = true
                    MessageLabel.Parent = LogFrame
                end
            end

            task.wait(0.05)
            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
        end

        updateLogs()

        local lastLogCount = #chatLogs
        local updateConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not ScreenGui.Parent then
                updateConnection:Disconnect()
                return
            end
            task.wait(0.5)
            if #chatLogs ~= lastLogCount then
                lastLogCount = #chatLogs
                updateLogs()
            end
        end)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
        end)

        local dragging = false
        local dragStart = nil
        local startPos = nil
        local dragConnection = nil

        local function updateDrag(input)
            if dragging and dragStart and startPos then
                local delta = input.Position - dragStart
                Frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end

        local function stopDrag()
            if dragging then
                dragging = false
                dragStart = nil
                startPos = nil
                if dragConnection then
                    dragConnection:Disconnect()
                    dragConnection = nil
                end
            end
        end

        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                local relativePos = input.Position - TopBar.AbsolutePosition
                local buttonAreaStart = TopBar.AbsoluteSize.X - 160
                if relativePos.X < buttonAreaStart then
                    dragging = true
                    dragStart = input.Position
                    startPos = Frame.Position
                    if dragConnection then dragConnection:Disconnect() end
                    dragConnection = UserInputService.InputChanged:Connect(function(moveInput)
                        if moveInput.UserInputType == Enum.UserInputType.MouseMovement
                        or moveInput.UserInputType == Enum.UserInputType.Touch then
                            updateDrag(moveInput)
                        end
                    end)
                end
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                stopDrag()
            end
        end)
        UserInputService.TouchEnded:Connect(stopDrag)

        ScreenGui.AncestryChanged:Connect(function()
            if not ScreenGui.Parent then
                stopDrag()
                if updateConnection then updateConnection:Disconnect() end
            end
        end)

        local minimized = false

        local function minimize()
            ContentFrame.Visible = false
            MinimizeButton.Text = "+"
            Frame.Size = UDim2.new(0, 620, 0, 38)
        end

        local function maximize()
            ContentFrame.Visible = true
            MinimizeButton.Text = "–"
            Frame.Size = UDim2.new(0, 620, 0, 500)
        end

        local pc = not UserInputService.TouchEnabled and not UserInputService.GamepadEnabled
        local mobile = UserInputService.TouchEnabled

        if pc then
            CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
            MinimizeButton.MouseButton1Click:Connect(function()
                if minimized then maximize() else minimize() end
                minimized = not minimized
            end)
        elseif mobile then
            CloseButton.InputBegan:Connect(function(input, processed)
                if not processed and input.UserInputType == Enum.UserInputType.Touch then
                    ScreenGui:Destroy()
                end
            end)
            MinimizeButton.InputBegan:Connect(function(input, processed)
                if not processed and input.UserInputType == Enum.UserInputType.Touch then
                    if minimized then maximize() else minimize() end
                    minimized = not minimized
                end
            end)
        end
    end
})

addCommand({
    name = "bang",
    aliases = {},
    desc = "fucks people (HUGELY RESTRICTED THAT ONLY I (WEBS) CAN USE IT)",
    usage = prefix .. "bang [player1 (optional)] [player2]",
    rank = RANKS.OWNER,
    callback = function(plr, args)
        if plr.Name ~= "idonthacklol101ns" then
            notify(plr, "Sentrius", "This command is restricted to idonthacklol101ns only!", 3)
            return
        end
        
        local arg, plr2
        
        if args and args[2] then
            arg = args[1]
            plr2 = args[2]
        elseif args and args[1] then
            arg = plr.Name
            plr2 = args[1]
        else
            notify(plr, "Sentrius", "You need to specify at least one player!", 3)
            return
        end
        
        if arg == "me" then
            arg = plr.Name
        end
        
        local argt = GetPlayer(arg, plr)
        local argt2 = GetPlayer(plr2, plr)
        
        if not argt or #argt == 0 then
            notify(plr, "Sentrius", "Invalid first player!", 3)
            return
        end
        
        local V1
        
        if #argt2 <= 0 then
            V1 = workspace:FindFirstChild(plr2)
            if V1 then
                V1 = V1:FindFirstChild("Torso")
            else
                notify(plr, "Sentrius", "Invalid user / model!", 3)
                return
            end
        else
            V1 = argt2[1]
            
            if V1.Character and V1.Character:FindFirstChild("Torso") and V1.Character:FindFirstChild("Humanoid") then
                V1 = argt2[1].Character:FindFirstChild("Torso")
            else
                notify(plr, "Sentrius", V1.Name .. " doesn't have a Torso!", 3)
                return
            end
        end
        
        if argt[1].Character and argt[1].Character:FindFirstChild("Torso") and argt[1].Character:FindFirstChild("HumanoidRootPart") then
            
            local P1 = argt[1].Character:FindFirstChild("Torso")
            
            if #argt2 <= 0 and workspace:FindFirstChild(plr2) then
                workspace:FindFirstChild(plr2):FindFirstChild("HumanoidRootPart"):SetNetworkOwner(argt[1])
                workspace:FindFirstChild(plr2):FindFirstChild("HumanoidRootPart").Massless = true
            else
                V1.Parent:FindFirstChild("HumanoidRootPart"):SetNetworkOwner(argt[1])
                V1.Parent:FindFirstChild("HumanoidRootPart").Massless = true
            end
            
            function fWeld(zName, zParent, zPart0, zPart1, zCoco, A, B, C, D, E, F)
                local funcw = Instance.new('Weld')
                funcw.Name = zName
                funcw.Parent = zParent
                funcw.Part0 = zPart0
                funcw.Part1 = zPart1
                if (zCoco) then
                    funcw.C0 = CFrame.new(A, B, C) * CFrame.fromEulerAnglesXYZ(D, E, F)
                else
                    funcw.C1 = CFrame.new(A, B, C) * CFrame.fromEulerAnglesXYZ(D, E, F)
                end
                return funcw
            end
            
            local WE = nil
            
            V1.Parent:FindFirstChild("Humanoid").PlatformStand = true
            P1['Left Shoulder']:Destroy()
            local LA1 = Instance.new('Weld', P1)
            LA1.Part0 = P1
            LA1.Part1 = P1.Parent['Left Arm']
            LA1.C0 = CFrame.new(-1.5, 0, 0)
            LA1.Name = 'Left Shoulder'
            
            P1['Right Shoulder']:Destroy()
            local RS1 = Instance.new('Weld', P1)
            RS1.Part0 = P1
            RS1.Part1 = P1.Parent['Right Arm']
            RS1.C0 = CFrame.new(1.5, 0, 0)
            RS1.Name = 'Right Shoulder'
            
            V1['Left Shoulder']:Destroy()
            local LS2 = Instance.new('Weld', V1)
            LS2.Part0 = V1
            LS2.Part1 = V1.Parent['Left Arm']
            LS2.C0 = CFrame.new(-1.5, 0, 0)
            LS2.Name = 'Left Shoulder'
            
            V1['Right Shoulder']:Destroy()
            local RS2 = Instance.new('Weld', V1)
            RS2.Part0 = V1
            RS2.Part1 = V1.Parent['Right Arm']
            RS2.C0 = CFrame.new(1.5, 0, 0)
            RS2.Name = 'Right Shoulder'
            
            V1['Left Hip']:Destroy()
            local LH2 = Instance.new('Weld', V1)
            LH2.Part0 = V1
            LH2.Part1 = V1.Parent['Left Leg']
            LH2.C0 = CFrame.new(-0.5, -2, 0)
            LH2.Name = 'Left Hip'
            
            V1['Right Hip']:Destroy()
            local RH2 = Instance.new('Weld', V1)
            RH2.Part0 = V1
            RH2.Part1 = V1.Parent['Right Leg']
            RH2.C0 = CFrame.new(0.5, -2, 0)
            RH2.Name = 'Right Hip'
            
            local BL = Instance.new('Part', V1)
            BL.TopSurface = 0
            BL.BottomSurface = 0
            BL.CanCollide = false
            BL.Color = V1.Color
            BL.Shape = 'Ball'
            BL.Size = Vector3.new(1, 1, 1)
            local DM2 = Instance.new('SpecialMesh', BL)
            DM2.MeshType = 'Sphere'
            DM2.Scale = Vector3.new(1.2, 1.2, 1.2)
            fWeld('weld', V1, V1, BL, true, -0.5, 0.4, -0.6, 0, 0, 0)
            
            local BR = Instance.new('Part', V1)
            BR.TopSurface = 0
            BR.BottomSurface = 0
            BR.CanCollide = false
            BR.Color = V1.Color
            BR.Shape = 'Ball'
            BR.Size = Vector3.new(1, 1, 1)
            local DM3 = Instance.new('SpecialMesh', BR)
            DM3.MeshType = 'Sphere'
            DM3.Scale = Vector3.new(1.2, 1.2, 1.2)
            fWeld('weld', V1, V1, BR, true, 0.5, 0.4, -0.6, 0, 0, 0)
            
            local BLN = Instance.new('Part', V1)
            BLN.TopSurface = 0
            BLN.BottomSurface = 0
            BLN.CanCollide = false
            BLN.BrickColor = BrickColor.new('Pink')
            BLN.Shape = 'Ball'
            BLN.Size = Vector3.new(1, 1, 1)
            local DM4 = Instance.new('SpecialMesh', BLN)
            DM4.MeshType = 'Sphere'
            DM4.Scale = Vector3.new(0.2, 0.2, 0.2)
            fWeld('weld', V1, V1, BLN, true, -0.5, 0.4, -1.2, 0, 0, 0)
            
            local BRN = Instance.new('Part', V1)
            BRN.TopSurface = 0
            BRN.BottomSurface = 0
            BRN.CanCollide = false
            BRN.BrickColor = BrickColor.new('Pink')
            BRN.Shape = 'Ball'
            BRN.Size = Vector3.new(1, 1, 1)
            local DM5 = Instance.new('SpecialMesh', BRN)
            DM5.MeshType = 'Sphere'
            DM5.Scale = Vector3.new(0.2, 0.2, 0.2)
            fWeld('weld', V1, V1, BRN, true, 0.5, 0.4, -1.2, 0, 0, 0)
            
            local B = Instance.new('Part', V1)
            B.TopSurface = 0
            B.BottomSurface = 0
            B.CanCollide = false
            B.Color = V1.Color
            B.Shape = 'Ball'
            B.Size = Vector3.new(1.3, 1.3, 1.3)
            local BM = Instance.new('SpecialMesh', B)
            BM.MeshType = 'Sphere'
            BM.Scale = Vector3.new(1.25, 1.25, 1.25)
            fWeld('weld', V1, V1, B, true, -0.7, -1, 0.5, 0, 0, 0)
            
            local B2 = Instance.new('Part', V1)
            B2.TopSurface = 0
            B2.BottomSurface = 0
            B2.CanCollide = false
            B2.Color = V1.Color
            B2.Shape = 'Ball'
            B2.Size = Vector3.new(1.3, 1.3, 1.3)
            local BM2 = Instance.new('SpecialMesh', B2)
            BM2.MeshType = 'Sphere'
            BM2.Scale = Vector3.new(1.25, 1.25, 1.25)
            fWeld('weld', V1, V1, B2, true, 0.7, -1, 0.5, 0, 0, 0)
            
            local tip = Instance.new("Part", argt[1].Character)
            local peep = Instance.new("Part", argt[1].Character)
            local ball1 = Instance.new("Part", argt[1].Character)
            local ball2 = Instance.new("Part", argt[1].Character)
            
            local tipmesh = Instance.new("SpecialMesh", tip)
            local peepmesh = Instance.new("CylinderMesh", peep)
            local ball1mesh = Instance.new("SpecialMesh", ball1)
            local ball2mesh = Instance.new("SpecialMesh", ball2)
            
            local tipweld = Instance.new("WeldConstraint", argt[1].Character)
            local peepweld = Instance.new("WeldConstraint", argt[1].Character)
            local peepweld2 = Instance.new("WeldConstraint", peep)
            local ball1weld = Instance.new("WeldConstraint", argt[1].Character)
            local ball2weld = Instance.new("WeldConstraint", argt[1].Character)
            
            tip.BrickColor = BrickColor.new("Pink")
            tip.Size = Vector3.new(1, 1, 1)
            tip.BottomSurface = "Smooth"
            tip.TopSurface = "Smooth"
            tip.CanCollide = false
            tip.Locked = true
            
            peep.Color = argt[1].Character.Torso.Color
            peep.Size = Vector3.new(0.4, 1.3, 0.4)
            peep.BottomSurface = "Smooth"
            peep.TopSurface = "Smooth"
            peep.CanCollide = false
            peep.Locked = true
            
            ball1.Color = argt[1].Character.Torso.Color
            ball1.Size = Vector3.new(1, 1, 1)
            ball1.BottomSurface = "Smooth"
            ball1.TopSurface = "Smooth"
            ball1.CanCollide = false
            ball1.Locked = true
            
            ball2.Color = argt[1].Character.Torso.Color
            ball2.Size = Vector3.new(1, 1, 1)
            ball2.BottomSurface = "Smooth"
            ball2.TopSurface = "Smooth"
            ball2.CanCollide = false
            ball2.Locked = true
            
            tipmesh.MeshType = "Sphere"
            tipmesh.Scale = Vector3.new(0.4, 0.62, 0.4)
            
            ball1mesh.MeshType = "Sphere"
            ball1mesh.Scale = Vector3.new(0.4, 0.4, 0.4)
            
            ball2mesh.MeshType = "Sphere"
            ball2mesh.Scale = Vector3.new(0.4, 0.4, 0.4)
            
            peep.CFrame = argt[1].Character.Torso.CFrame * CFrame.new(0, -1, -1) * CFrame.Angles(math.rad(90), 0, 0)
            tip.CFrame = peep.CFrame * CFrame.new(0, -0.7, 0)
            ball1.CFrame = peep.CFrame * CFrame.new(0.3, 0.4, 0.25)
            ball2.CFrame = peep.CFrame * CFrame.new(-0.3, 0.4, 0.25)
            
            tipweld.Part0 = argt[1].Character.Torso
            tipweld.Part1 = tip
            
            peepweld.Part0 = argt[1].Character.Torso
            peepweld.Part1 = peep
            
            peepweld2.Part0 = peep
            peepweld2.Part1 = tip
            
            ball1weld.Part0 = argt[1].Character.Torso
            ball1weld.Part1 = ball1
            
            ball2weld.Part0 = argt[1].Character.Torso
            ball2weld.Part1 = ball2
            
            LH2.C1 = CFrame.new(0.2, 1.6, 0.4) * CFrame.Angles(3.9, -0.4, 0)
            RH2.C1 = CFrame.new(-0.2, 1.6, 0.4) * CFrame.Angles(3.9, 0.4, 0)
            LS2.C1 = CFrame.new(-0.2, 0.9, 0.6) * CFrame.Angles(3.9, -0.2, 0)
            RS2.C1 = CFrame.new(0.2, 0.9, 0.6) * CFrame.Angles(3.9, 0.2, 0)
            LA1.C1 = CFrame.new(-0.5, 0.7, 0) * CFrame.Angles(-0.9, -0.4, 0)
            RS1.C1 = CFrame.new(0.5, 0.7, 0) * CFrame.Angles(-0.9, 0.4, 0)
            
            WE = fWeld('weldx', P1, P1, V1, true, 0, -1, -2, math.rad(-90), 0, 0)
            local N = V1.Neck
            N.C0 = CFrame.new(0, 1.5, 0) * CFrame.Angles(math.rad(-210), math.rad(180), 0)
            
            task.spawn(function()
                while task.wait() do
                    for i = 1, 6 do
                        WE.C0 = WE.C0 * CFrame.new(0, 0.1, 0)
                        task.wait(0.030)
                    end
                    
                    for i = 1, 6 do
                        WE.C0 = WE.C0 * CFrame.new(0, -0.1, 0)
                        task.wait(0.030)
                    end
                    task.wait()
                end
            end)
        else
            notify(plr, "Sentrius", "Target doesn't have required body parts!", 3)
        end
    end
}) --vecxo light

addCommand({
    name = "locate",
    aliases = {},
    desc = "locate..",
    usage = prefix .. "locate [player]",
    rank = RANKS.SENIOR_MOD,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "locate [player]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        local LocalizationService = game:GetService("LocalizationService")
        
        local countryFlags = {
            US = "🇺🇸", CA = "🇨🇦", MX = "🇲🇽", BR = "🇧🇷", AR = "🇦🇷", CL = "🇨🇱", CO = "🇨🇴", PE = "🇵🇪", VE = "🇻🇪",
            EC = "🇪🇨", BO = "🇧🇴", PY = "🇵🇾", UY = "🇺🇾", GY = "🇬🇾", SR = "🇸🇷", CR = "🇨🇷", PA = "🇵🇦", GT = "🇬🇹",
            HN = "🇭🇳", SV = "🇸🇻", NI = "🇳🇮", CU = "🇨🇺", DO = "🇩🇴", HT = "🇭🇹", JM = "🇯🇲", TT = "🇹🇹", BS = "🇧🇸",
            BB = "🇧🇧", BZ = "🇧🇿", GD = "🇬🇩", LC = "🇱🇨", VC = "🇻🇨", AG = "🇦🇬", DM = "🇩🇲", KN = "🇰🇳",
            GB = "🇬🇧", DE = "🇩🇪", FR = "🇫🇷", ES = "🇪🇸", IT = "🇮🇹", NL = "🇳🇱", BE = "🇧🇪", CH = "🇨🇭", AT = "🇦🇹",
            PT = "🇵🇹", GR = "🇬🇷", SE = "🇸🇪", NO = "🇳🇴", DK = "🇩🇰", FI = "🇫🇮", PL = "🇵🇱", CZ = "🇨🇿", RO = "🇷🇴",
            HU = "🇭🇺", BG = "🇧🇬", SK = "🇸🇰", HR = "🇭🇷", SI = "🇸🇮", LT = "🇱🇹", LV = "🇱🇻", EE = "🇪🇪", IE = "🇮🇪",
            IS = "🇮🇸", LU = "🇱🇺", MT = "🇲🇹", CY = "🇨🇾", RS = "🇷🇸", BA = "🇧🇦", ME = "🇲🇪", MK = "🇲🇰", AL = "🇦🇱",
            MD = "🇲🇩", BY = "🇧🇾", UA = "🇺🇦", RU = "🇷🇺", CN = "🇨🇳", JP = "🇯🇵", KR = "🇰🇷", IN = "🇮🇳", PK = "🇵🇰",
            BD = "🇧🇩", VN = "🇻🇳", TH = "🇹🇭", PH = "🇵🇭", ID = "🇮🇩", MY = "🇲🇾", SG = "🇸🇬", MM = "🇲🇲", KH = "🇰🇭",
            LA = "🇱🇦", NP = "🇳🇵", LK = "🇱🇰", AF = "🇦🇫", IQ = "🇮🇶", IR = "🇮🇷", TR = "🇹🇷", SA = "🇸🇦", AE = "🇦🇪",
            IL = "🇮🇱", JO = "🇯🇴", LB = "🇱🇧", SY = "🇸🇾", YE = "🇾🇪", OM = "🇴🇲", KW = "🇰🇼", BH = "🇧🇭", QA = "🇶🇦",
            MN = "🇲🇳", KZ = "🇰🇿", UZ = "🇺🇿", TM = "🇹🇲", KG = "🇰🇬", TJ = "🇹🇯", GE = "🇬🇪", AM = "🇦🇲", AZ = "🇦🇿",
            BT = "🇧🇹", MV = "🇲🇻", BN = "🇧🇳", TL = "🇹🇱", EG = "🇪🇬", ZA = "🇿🇦", NG = "🇳🇬", KE = "🇰🇪", ET = "🇪🇹",
            GH = "🇬🇭", TZ = "🇹🇿", UG = "🇺🇬", DZ = "🇩🇿", MA = "🇲🇦", TN = "🇹🇳", LY = "🇱🇾", SD = "🇸🇩", SS = "🇸🇸",
            SO = "🇸🇴", AO = "🇦🇴", MZ = "🇲🇿", ZW = "🇿🇼", ZM = "🇿🇲", MW = "🇲🇼", BW = "🇧🇼", NA = "🇳🇦", SZ = "🇸🇿",
            LS = "🇱🇸", CM = "🇨🇲", CI = "🇨🇮", SN = "🇸🇳", ML = "🇲🇱", NE = "🇳🇪", BF = "🇧🇫", TD = "🇹🇩", CF = "🇨🇫",
            CG = "🇨🇬", CD = "🇨🇩", GA = "🇬🇦", GQ = "🇬🇶", BJ = "🇧🇯", TG = "🇹🇬", LR = "🇱🇷", SL = "🇸🇱", GN = "🇬🇳",
            GW = "🇬🇼", GM = "🇬🇲", MR = "🇲🇷", ER = "🇪🇷", DJ = "🇩🇯", RW = "🇷🇼", BI = "🇧🇮", SC = "🇸🇨", MU = "🇲🇺",
            KM = "🇰🇲", MG = "🇲🇬", CV = "🇨🇻", ST = "🇸🇹", AU = "🇦🇺", NZ = "🇳🇿", FJ = "🇫🇯", PG = "🇵🇬", WS = "🇼🇸",
            SB = "🇸🇧", VU = "🇻🇺", TO = "🇹🇴", KI = "🇰🇮", FM = "🇫🇲", MH = "🇲🇭", PW = "🇵🇼", NR = "🇳🇷", TV = "🇹🇻"
        }
        
        local countryNames = {
            US = "United States", CA = "Canada", MX = "Mexico", BR = "Brazil", AR = "Argentina", CL = "Chile",
            CO = "Colombia", PE = "Peru", VE = "Venezuela", EC = "Ecuador", BO = "Bolivia", PY = "Paraguay",
            UY = "Uruguay", GY = "Guyana", SR = "Suriname", CR = "Costa Rica", PA = "Panama", GT = "Guatemala",
            HN = "Honduras", SV = "El Salvador", NI = "Nicaragua", CU = "Cuba", DO = "Dominican Republic",
            HT = "Haiti", JM = "Jamaica", TT = "Trinidad and Tobago", BS = "Bahamas", BB = "Barbados",
            BZ = "Belize", GD = "Grenada", LC = "Saint Lucia", VC = "Saint Vincent", AG = "Antigua and Barbuda",
            DM = "Dominica", KN = "Saint Kitts and Nevis", GB = "United Kingdom", DE = "Germany", FR = "France",
            ES = "Spain", IT = "Italy", NL = "Netherlands", BE = "Belgium", CH = "Switzerland", AT = "Austria",
            PT = "Portugal", GR = "Greece", SE = "Sweden", NO = "Norway", DK = "Denmark", FI = "Finland",
            PL = "Poland", CZ = "Czech Republic", RO = "Romania", HU = "Hungary", BG = "Bulgaria", SK = "Slovakia",
            HR = "Croatia", SI = "Slovenia", LT = "Lithuania", LV = "Latvia", EE = "Estonia", IE = "Ireland",
            IS = "Iceland", LU = "Luxembourg", MT = "Malta", CY = "Cyprus", RS = "Serbia", BA = "Bosnia and Herzegovina",
            ME = "Montenegro", MK = "North Macedonia", AL = "Albania", MD = "Moldova", BY = "Belarus", UA = "Ukraine",
            RU = "Russia", CN = "China", JP = "Japan", KR = "South Korea", IN = "India", PK = "Pakistan",
            BD = "Bangladesh", VN = "Vietnam", TH = "Thailand", PH = "Philippines", ID = "Indonesia", MY = "Malaysia",
            SG = "Singapore", MM = "Myanmar", KH = "Cambodia", LA = "Laos", NP = "Nepal", LK = "Sri Lanka",
            AF = "Afghanistan", IQ = "Iraq", IR = "Iran", TR = "Turkey", SA = "Saudi Arabia", AE = "United Arab Emirates",
            IL = "Israel", JO = "Jordan", LB = "Lebanon", SY = "Syria", YE = "Yemen", OM = "Oman", KW = "Kuwait",
            BH = "Bahrain", QA = "Qatar", MN = "Mongolia", KZ = "Kazakhstan", UZ = "Uzbekistan", TM = "Turkmenistan",
            KG = "Kyrgyzstan", TJ = "Tajikistan", GE = "Georgia", AM = "Armenia", AZ = "Azerbaijan", BT = "Bhutan",
            MV = "Maldives", BN = "Brunei", TL = "Timor-Leste", EG = "Egypt", ZA = "South Africa", NG = "Nigeria",
            KE = "Kenya", ET = "Ethiopia", GH = "Ghana", TZ = "Tanzania", UG = "Uganda", DZ = "Algeria", MA = "Morocco",
            TN = "Tunisia", LY = "Libya", SD = "Sudan", SS = "South Sudan", SO = "Somalia", AO = "Angola",
            MZ = "Mozambique", ZW = "Zimbabwe", ZM = "Zambia", MW = "Malawi", BW = "Botswana", NA = "Namibia",
            SZ = "Eswatini", LS = "Lesotho", CM = "Cameroon", CI = "Ivory Coast", SN = "Senegal", ML = "Mali",
            NE = "Niger", BF = "Burkina Faso", TD = "Chad", CF = "Central African Republic", CG = "Republic of the Congo",
            CD = "Democratic Republic of the Congo", GA = "Gabon", GQ = "Equatorial Guinea", BJ = "Benin", TG = "Togo",
            LR = "Liberia", SL = "Sierra Leone", GN = "Guinea", GW = "Guinea-Bissau", GM = "Gambia", MR = "Mauritania",
            ER = "Eritrea", DJ = "Djibouti", RW = "Rwanda", BI = "Burundi", SC = "Seychelles", MU = "Mauritius",
            KM = "Comoros", MG = "Madagascar", CV = "Cape Verde", ST = "Sao Tome and Principe", AU = "Australia",
            NZ = "New Zealand", FJ = "Fiji", PG = "Papua New Guinea", WS = "Samoa", SB = "Solomon Islands",
            VU = "Vanuatu", TO = "Tonga", KI = "Kiribati", FM = "Micronesia", MH = "Marshall Islands", PW = "Palau",
            NR = "Nauru", TV = "Tuvalu"
        }
        
        for _, target in ipairs(targets) do
            task.spawn(function()
                local countryCode = "??"
                local success = pcall(function()
                    countryCode = LocalizationService:GetCountryRegionForPlayerAsync(target)
                end)
                
                if success and countryCode ~= "??" then
                    local flag = countryFlags[countryCode] or "🌍"
                    local country = countryNames[countryCode] or "Unknown"
                    
                    notify(plr, "Sentrius", target.DisplayName .. " is from " .. country .. " " .. flag .. "!!!!!!", 5)
                else
                    notify(plr, "Sentrius", "Failed to get location for " .. target.DisplayName, 3)
                end
            end)
        end
    end
})

addCommand({
    name = "fov",
    aliases = {"fieldofview"},
    desc = "self explanatory",
    usage = prefix .. "fov [player (optional)] [fov]",
    callback = function(plr, args)
        local target = plr
        local fovValue
        
        if args and #args >= 2 then
            local targets = GetPlayer(args[1], plr)
            if targets and #targets > 0 then
                target = targets[1]
                fovValue = tonumber(args[2])
            else
                notify(plr, "Sentrius", "No player found!", 3)
                return
            end
        elseif args and #args == 1 then
            fovValue = tonumber(args[1])
        else
            notify(plr, "Sentrius", "Usage: " .. prefix .. "fov [player (optional)] [fov]", 3)
            return
        end
        
        if not fovValue then
            notify(plr, "Sentrius", "Invalid FOV value!", 3)
            return
        end
        
        if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
            local ticking = tick()
            require(112691275102014).load()
            repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
        end
        
        local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
        
        if not goog then
            warn("goog failed to load for fov")
            notify(plr, "Sentrius", "Failed to load goog!", 3)
            return
        end
        
        local scr = goog:FindFirstChild("Utilities").Client:Clone()
        local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
        
        loa.Parent = scr
        scr:WaitForChild("Exec").Value = string.format([[
            local fov=%d;
            local cam=workspace.CurrentCamera;
            cam.FieldOfView=fov;
            game:GetService("RunService").RenderStepped:Connect(function()
                if cam.FieldOfView~=fov then
                    cam.FieldOfView=fov
                end
            end)
            script:Destroy()
        ]], fovValue)
        
        if target:FindFirstChild("PlayerGui") then
            scr.Parent = target.PlayerGui
        else
            scr.Parent = target.Character
        end
        
        scr.Enabled = true
        
        if target == plr then
            notify(plr, "Sentrius", "Set your FOV to " .. fovValue, 3)
        else
            notify(plr, "Sentrius", "Set " .. target.DisplayName .. "'s FOV to " .. fovValue, 3)
        end
    end
})

addCommand({
    name = "banhammer",
    aliases = {},
    desc = "a banhammer that wont affect ur score..",
    usage = prefix .. "banhammer [player (optional)]",
    rank = RANKS.SENIOR_MOD,
    callback = function(plr, args)
        local target = plr
        
        if args and #args > 0 then
            local targets = GetPlayer(args[1], plr)
            if targets and #targets > 0 then
                target = targets[1]
            else
                return
            end
        end
        
        if not target.Character or not target:FindFirstChild("Backpack") then
            notify(plr, "Sentrius", target.DisplayName .. " doesn't have a character or their backpack is disabled.", 3)
            return
        end
        
        local InsertService = game:GetService("InsertService")
        
        local success, hammer = pcall(function()
            return InsertService:LoadAsset(10468797)
        end)
        
        if not success or not hammer then
            notify(plr, "Sentrius", "faihled to ghet ban hamma", 3)
            return
        end
        
        local tool = hammer:FindFirstChildOfClass("Tool")
        if not tool then
            hammer:Destroy()
            notify(plr, "Sentrius", "lel banhammer is brocken", 3)
            return
        end
        
        if not _G.TempBans then
            _G.TempBans = {}
        end


        local connection
        local handle = tool:FindFirstChild("Handle")
        if handle then
           local mesh = handle:FindFirstChildOfClass("SpecialMesh")
           if mesh then
          mesh.Scale = mesh.Scale * 2
        end
            handle.Massless = true
            connection = handle.Touched:Connect(function(hit)
                if not running then 
                    connection:Disconnect()
                    return 
                end
                
                local victim = Players:GetPlayerFromCharacter(hit.Parent)
                
                if victim and victim ~= target then
                    if owna(victim) and not owna(target) then
                        return
                    end
                    
                    if whitelist[victim.UserId] and not owna(target) then
                        return
                    end
                    
                    if _G.TempBans[victim.UserId] then
                        return
                    end
                    
                    local banSound = Instance.new("Sound")
                    banSound.SoundId = "rbxassetid://5696182212"
                    banSound.Volume = 1
                    banSound.Parent = workspace
                    banSound:Play()
                    game:GetService("Debris"):AddItem(banSound, 4)
                    
                    _G.TempBans[victim.UserId] = true
                    
                    local hint = Instance.new("Hint")
                    hint.Text = victim.DisplayName .. " has been Server Banned for 5 minutes!"
                    hint.Parent = workspace
                    game:GetService("Debris"):AddItem(hint, 5.5)
                    
                    if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                        local ticking = tick()
                        require(112691275102014).load()
                        repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
                    end
                    
                    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
                    
                    if not goog then
                        warn("goog failed to load for banhammer")
                        notify(plr, "Sentrius", "Failed to load goog!", 3)
                        return
                    end
                    
                    local scr = goog:FindFirstChild("Utilities").Client:Clone()
                    local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                    
                    loa.Parent = scr
                    scr:WaitForChild("Exec").Value = [[
                        game.Players.LocalPlayer:Destroy()
                        script:Destroy()
                    ]]
                    
                    if victim:FindFirstChild("PlayerGui") then
                        scr.Parent = victim.PlayerGui
                    elseif victim.Character then
                        scr.Parent = victim.Character
                    end
                    
                    scr.Enabled = true
                    
                    task.delay(300, function()
                        if _G.TempBans[victim.UserId] then
                            _G.TempBans[victim.UserId] = nil
                            notify(plr, "Sentrius", victim.DisplayName .. "'s 5-minute ban has expired.", 3)
                        end
                    end)
                end
            end)
            
            tool.AncestryChanged:Connect(function()
                if not tool.Parent then
                    connection:Disconnect()
                end
            end)
        end
        
        tool.Parent = target.Backpack
        hammer:Destroy()
        
        if target == plr then
            notify(plr, "Sentrius", "ban hammer that wont take away your score..", 3)
        else
            notify(plr, "Sentrius", target.DisplayName .. " has the ban hammer..", 3)
            notify(target, "Sentrius", "With this banhammer, you can ban people for 5 minutes without your score decreasing.", 4)
        end
    end
})

addCommand({
    name = "antimusic",
    aliases = {"nomusic", "mutemusic"},
    desc = "Prevents all music/sounds from playing in the game",
    usage = prefix .. "antimusic",
    callback = function(plr, args)
        if _G.AntiMusicEnabled then
            notify(plr, "Sentrius", "Anti-music is already enabled!", 3)
            return
        end
        
        _G.AntiMusicEnabled = true
        

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Sound") then
                obj:Stop()
                obj.Volume = 0
            end
        end
        

        if not connections["antimusic"] then
            connections["antimusic"] = workspace.DescendantAdded:Connect(function(descendant)
                if not _G.AntiMusicEnabled then return end
                
                if descendant:IsA("Sound") then
                    descendant:Stop()
                    descendant.Volume = 0
                end
            end)
        end
        

        if not connections["antimusic_monitor"] then
            connections["antimusic_monitor"] = game:GetService("RunService").Heartbeat:Connect(function()
                if not _G.AntiMusicEnabled then return end
                
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Sound") and obj.Playing then
                        obj:Stop()
                        obj.Volume = 0
                    end
                end
            end)
        end
        
        notify(plr, "Sentrius", "Anti-music enabled! All sounds have been muted.", 3)
    end
})

addCommand({
    name = "unantimusic",
    aliases = {"unnomusic", "allowmusic"},
    desc = "Allows music/sounds to play again",
    usage = prefix .. "unantimusic",
    callback = function(plr, args)
        if not _G.AntiMusicEnabled then
            notify(plr, "Sentrius", "Anti-music is not enabled!", 3)
            return
        end
        
        _G.AntiMusicEnabled = false
        

        if connections["antimusic"] then
            connections["antimusic"]:Disconnect()
            connections["antimusic"] = nil
        end
        
        if connections["antimusic_monitor"] then
            connections["antimusic_monitor"]:Disconnect()
            connections["antimusic_monitor"] = nil
        end
        

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Sound") then
                obj.Volume = 0.5
            end
        end
        
        notify(plr, "Sentrius", "Anti-music disabled! Sounds can now play.", 3)
    end
})

addCommand({
    name = "sspeed",
    aliases = {"playbackspeed", "musicspeed"},
    desc = "self explanatory",
    usage = prefix .. "speed [number]",
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "speed [number]", 3)
            return
        end
        
        local speedValue = tonumber(args[1])
        if not speedValue then
            notify(plr, "Sentrius", "Invalid speed value!", 3)
            return
        end
        
        local count = 0
        for _, sound in ipairs(workspace:GetDescendants()) do
            if sound:IsA("Sound") and sound.Parent == workspace and sound.IsPlaying then
                sound.PlaybackSpeed = speedValue
                count = count + 1
            end
        end
        
        if count > 0 then
            notify(plr, "Sentrius", "Set sound speed to " .. speedValue, 3)
        else
            notify(plr, "Sentrius", "No music found in workspace!", 3)
        end
    end
})

addCommand({
    name = "pitch",
    aliases = {},
    desc = "self explanatory",
    usage = prefix .. "pitch [number]",
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "pitch [number]", 3)
            return
        end
        
        local pitchValue = tonumber(args[1])
        if not pitchValue then
            notify(plr, "Sentrius", "Invalid pitch value!", 3)
            return
        end
        
        local count = 0
        for _, sound in ipairs(workspace:GetDescendants()) do
            if sound:IsA("Sound") and sound.Parent == workspace and sound.IsPlaying then
                sound.PlaybackSpeed = pitchValue
                count = count + 1
            end
        end
        
        if count > 0 then
            notify(plr, "Sentrius", "Set sound pitch to " .. pitchValue, 3)
        else
            notify(plr, "Sentrius", "No music found in workspace!", 3)
        end
    end
})

addCommand({
    name = "volume",
    aliases = {"vol"},
    desc = "self explanatory",
    usage = prefix .. "volume [0-10]",
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "volume [0-10]", 3)
            return
        end
        
        local volValue = tonumber(args[1])
        if not volValue then
            notify(plr, "Sentrius", "Invalid volume value!", 3)
            return
        end
        
        local count = 0
        for _, sound in ipairs(workspace:GetDescendants()) do
            if sound:IsA("Sound") and sound.Parent == workspace and sound.IsPlaying then
                sound.Volume = volValue
                count = count + 1
            end
        end
        
        if count > 0 then
            notify(plr, "Sentrius", "Set sound volume to " .. volValue, 3)
        else
            notify(plr, "Sentrius", "No music found in workspace!", 3)
        end
    end
})

addCommand({
    name = "reverb",
    aliases = {},
    desc = "self explanatory",
    usage = prefix .. "reverb [0-1]",
    callback = function(plr, args)
        local reverbValue = 0.5
        if args and #args > 0 then
            reverbValue = tonumber(args[1]) or 0.5
        end
        
        local count = 0
        for _, sound in ipairs(workspace:GetDescendants()) do
            if sound:IsA("Sound") and sound.Parent == workspace and sound.IsPlaying then
                local reverb = sound:FindFirstChildOfClass("ReverbSoundEffect")
                if not reverb then
                    reverb = Instance.new("ReverbSoundEffect")
                    reverb.Parent = sound
                end
                reverb.DecayTime = reverbValue * 10
                reverb.Density = reverbValue
                reverb.Diffusion = reverbValue
                reverb.DryLevel = 0
                reverb.WetLevel = reverbValue * -10
                count = count + 1
            end
        end
        
        if count > 0 then
            notify(plr, "Sentrius", "Added sound reverb (" .. reverbValue .. ") to " .. count .. " running audios!", 3)
        else
            notify(plr, "Sentrius", "No music found in workspace!", 3)
        end
    end
})

addCommand({
    name = "echo",
    aliases = {},
    desc = "self explanatory",
    usage = prefix .. "echo [0-1]",
    callback = function(plr, args)
        local echoValue = 0.5
        if args and #args > 0 then
            echoValue = tonumber(args[1]) or 0.5
        end
        
        local count = 0
        for _, sound in ipairs(workspace:GetDescendants()) do
            if sound:IsA("Sound") and sound.Parent == workspace and sound.IsPlaying then
                local echo = sound:FindFirstChildOfClass("EchoSoundEffect")
                if not echo then
                    echo = Instance.new("EchoSoundEffect")
                    echo.Parent = sound
                end
                echo.Delay = echoValue
                echo.DryLevel = 0
                echo.WetLevel = echoValue * -10
                echo.Feedback = echoValue * 0.5
                count = count + 1
            end
        end
        
        if count > 0 then
           print("i dunno what to put here")
        else
            notify(plr, "Sentrius", "No music found in workspace!", 3)
        end
    end
})

addCommand({
    name = "fix",
    aliases = {"cleanup", "restore"},
    desc = "fihks",
    usage = prefix .. "fix",
    rank = RANKS.MODERATOR,
    callback = function(plr, args)
        local Lighting = game:GetService("Lighting")
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.Brightness = 1
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.FogColor = Color3.fromRGB(192, 192, 192)
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.ClockTime = 14
        Lighting.GeographicLatitude = 41.733
        Lighting.GlobalShadows = true
        Lighting.TimeOfDay = "14:00:00"
        
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("Atmosphere") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") 
            or effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") 
            or effect:IsA("SunRaysEffect") or effect:IsA("Sky") then
                effect:Destroy()
            end
        end
        
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name ~= "Terrain" and obj.Name ~= "Baseplate"
            and not Players:GetPlayerFromCharacter(obj) then
                obj:Destroy()
            elseif obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) 
            and obj.Name ~= "Tabby" and not obj:FindFirstChild("_Game") then
                local hasHumanoid = obj:FindFirstChildOfClass("Humanoid")
                if not hasHumanoid then
                    obj:Destroy()
                end
            elseif obj:IsA("Tool") or obj:IsA("Hat") or obj:IsA("Accessory") then
                obj:Destroy()
            end
        end
        
        notify(plr, "Sentrius", "Lighting restored and workspace mopped.", 3)
    end
})

addCommand({
    name = "setstat",
    aliases = {"stat"},
    desc = "kinda useless but still decided to add it",
    usage = prefix .. "setstat [player] [stat name] [value]",
    rank = RANKS.MODERATOR,
    callback = function(plr, args)
        if not args or #args < 3 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "setstat [player] [stat] [value]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        local statName = args[2]
        local statValue = args[3]
        

        local numValue = tonumber(statValue)
        local finalValue = numValue or statValue
        
        local names = {}
        for _, target in ipairs(targets) do
            local leaderstats = target:FindFirstChild("leaderstats")
            
            if not leaderstats then
                notify(plr, "Sentrius", target.DisplayName .. " has no leaderstats!", 3)
            else
                local foundStat = nil
                

                for _, stat in ipairs(leaderstats:GetChildren()) do
                    if stat:IsA("IntValue") or stat:IsA("NumberValue") or stat:IsA("StringValue") or stat:IsA("BoolValue") then
                        if stat.Name:lower():find(statName:lower(), 1, true) or stat.Name:lower() == statName:lower() then
                            foundStat = stat
                            break
                        end
                    end
                end
                
                if foundStat then
                    local oldValue = foundStat.Value
                    

                    if foundStat:IsA("IntValue") or foundStat:IsA("NumberValue") then
                        foundStat.Value = numValue or 0
                    elseif foundStat:IsA("StringValue") then
                        foundStat.Value = tostring(statValue)
                    elseif foundStat:IsA("BoolValue") then
                        if statValue:lower() == "true" or statValue == "1" then
                            foundStat.Value = true
                        else
                            foundStat.Value = false
                        end
                    end
                    
                    table.insert(names, target.DisplayName)
                    
                    if target == plr then
                        notify(plr, "Sentrius", "Changed your " .. foundStat.Name .. " from " .. tostring(oldValue) .. " to " .. tostring(foundStat.Value), 3)
                    end
                else
                    notify(plr, "Sentrius", "Stat '" .. statName .. "' not found for " .. target.DisplayName .. "!", 3)
                end
            end
        end
        
        if #names > 0 then
            notify(plr, "Sentrius", "Changed " .. statName .. " to " .. tostring(finalValue) .. " for: " .. format(names), 4)
        end
    end
})

addCommand({
    name = "touchy",
    aliases = {"antitouch"},
    desc = "lol.. whoever you touch gets kicked.. now targetable!",
    usage = prefix .. "touchy [player (optional)]",
    rank = RANKS.SENIOR_MOD,
    callback = function(plr, args)
        local target = plr

        if args and #args > 0 then
            local targets = GetPlayer(args[1], plr)
            if targets and #targets > 0 then
                target = targets[1]
            else
                notify(plr, "Sentrius", "No player found!", 3)
                return
            end
        end

        if _G.TouchyConnections[target.UserId] and _G.TouchyConnections[target.UserId].enabled then
            notify(plr, "Sentrius", target.DisplayName .. " already has touchy enabled!", 3)
            return
        end

        _G.TouchyConnections[target.UserId] = {
            enabled = true,
            touchConnection = nil,
            respawnConnection = nil,
            cooldowns = {}
        }

        local touchyData = _G.TouchyConnections[target.UserId]

        local function applyTouchy(character)
            if not touchyData.enabled then return end

            if touchyData.touchConnection then
                touchyData.touchConnection:Disconnect()
                touchyData.touchConnection = nil
            end

            local humanoid = character:WaitForChild("Humanoid", 5)
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)

            if not humanoid or not humanoidRootPart then
                warn("Touchy failed: Missing Humanoid or HumanoidRootPart for " .. target.Name)
                return
            end

            touchyData.touchConnection = humanoidRootPart.Touched:Connect(function(hit)
                if not touchyData.enabled then return end
                if not running then return end

                local toucher = Players:GetPlayerFromCharacter(hit.Parent)

                if toucher and toucher ~= target then
                    if owna(toucher) then
                        return
                    end

                    --[[if whitelist[toucher.UserId] and not owna(target) then
                        return
                    end]]

                    local now = tick()
                    if touchyData.cooldowns[toucher.UserId] and (now - touchyData.cooldowns[toucher.UserId]) < 0.7 then
                        return
                    end

                    touchyData.cooldowns[toucher.UserId] = now

                    toucher:Kick("Kicked by [Sentrius]\nYou touched " .. target.DisplayName .. "!!")

                    notify(target, "Sentrius", "Kicked " .. toucher.DisplayName .. " for touching you!", 3)
                    if target ~= plr and plr.Parent then
                        notify(plr, "Sentrius", toucher.DisplayName .. " touched " .. target.DisplayName .. " and got kicked!", 3)
                    end
                end
            end)
        end


        if target.Character then
            applyTouchy(target.Character)
        end


        touchyData.respawnConnection = target.CharacterAdded:Connect(function(character)
            if not touchyData.enabled then return end

            task.wait(0.5)
            applyTouchy(character)

            notify(target, "Sentrius", "touchy has been re-enabled.\nif you want to disable it then please type " .. prefix .. "untouchy", 3)
        end)

        _G.TouchyConnections[target.UserId] = touchyData


        if target == plr then
            notify(plr, "Sentrius", "Touchy enabled on yourself! Anyone who touches you will be kicked.", 4)
        else
            notify(plr, "Sentrius", "Touchy enabled on " .. target.DisplayName .. "!", 3)
            notify(target, "Sentrius", "⚠️ Anti-touch has been enabled on you by " .. plr.DisplayName .. "!\nAnyone who touches you will be kicked.", 5)
        end
    end
})

addCommand({
    name = "untouchy",
    aliases = {"unantitouch", "noantitouch"},
    desc = "Disable touchy kick protection (targetable)",
    usage = prefix .. "untouchy [player (optional)]",
    rank = RANKS.SENIOR_MOD,
    callback = function(plr, args)
        local target = plr

        if args and #args > 0 then
            local targets = GetPlayer(args[1], plr)
            if targets and #targets > 0 then
                target = targets[1]
            else
                notify(plr, "Sentrius", "No player found!", 3)
                return
            end
        end

        local touchyData = _G.TouchyConnections[target.UserId]

        if not touchyData or not touchyData.enabled then
            notify(plr, "Sentrius", target.DisplayName .. " doesn't have touchy enabled!", 3)
            return
        end

        touchyData.enabled = false

        if touchyData.touchConnection then
            touchyData.touchConnection:Disconnect()
            touchyData.touchConnection = nil
        end

        if touchyData.respawnConnection then
            touchyData.respawnConnection:Disconnect()
            touchyData.respawnConnection = nil
        end

        touchyData.cooldowns = {}

        if target == plr then
            notify(plr, "Sentrius", "Touchy disabled! Players can touch you now.", 3)
        else
            notify(plr, "Sentrius", "Touchy disabled on " .. target.DisplayName .. ".", 3)
            notify(target, "Sentrius", "Anti-touch has been disabled on you by " .. plr.DisplayName .. ".", 3)
        end
    end
})

addCommand({
    name = "image",
    aliases = {"imgload", "loadimage"},
    desc = "um credits to groovy boi im afraid",
    usage = prefix .. "image [url] [scale (optional)] [threshold (optional)] [toolsize (optional)]",
    rank = RANKS.FULL_ACCESS,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "image [url] [scale] [threshold] [toolsize]", 4)
            return
        end

        local url = args[1]
        if not url or url == "" then
            notify(plr, "Sentrius", "Please provide an image URL!", 3)
            return
        end

        local scale = tonumber(args[2]) or 0.25
        local threshold = tonumber(args[3]) or 5
        local toolSize = tonumber(args[4]) or 5

        notify(plr, "Sentrius", "Loading image...", 3)

        task.spawn(function()
            local success, err = pcall(function()
                local HTTP = game:GetService("HttpService")
                local vluauModule = require(123068958552495)("vLuau")
                local vluau = require(vluauModule)
                local loaderSource = HTTP:GetAsync("https://files.req-exe.win/imageloader.lua")
                local imageloader = vluau(loaderSource)()
                imageloader(url, plr, scale, threshold, toolSize)
            end)

            if not success then
                notify(plr, "Sentrius", "Image load failed: " .. tostring(err), 5)
            else
                notify(plr, "Sentrius", "Image loaded!", 3)
            end
        end)
    end
})

addCommand({
    name = "crashban",
    aliases = {"cb"},
    desc = "crashban self explanatory",
    usage = prefix .. "crashban [player] [reason]",
    rank = RANKS.ADMINISTRATOR,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "crashban [player] [reason]", 3)
            return
        end

        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end

        local reason = table.concat(args, " ", 2)
        if reason == "" then reason = "No reason provided." end

        local names = {}
        for _, target in ipairs(targets) do
            if owna(target) and not owna(plr) then
                notify(plr, "Sentrius", "You cannot crashban an owner!", 3)
                return
            end

            if not table.find(bannedIds, target.UserId) then
                table.insert(bannedIds, target.UserId)
                local v = Instance.new("IntValue")
                v.Name = tostring(target.UserId)
                v.Value = target.UserId
                v.Parent = banFolder
            end

            local crashBanFolder = vault:FindFirstChild("CrashBans")
            if not crashBanFolder then
                crashBanFolder = Instance.new("Folder")
                crashBanFolder.Name = "CrashBans"
                crashBanFolder.Parent = vault
            end

            if not crashBanFolder:FindFirstChild(tostring(target.UserId)) then
                local cv = Instance.new("IntValue")
                cv.Name = tostring(target.UserId)
                cv.Value = target.UserId
                cv.Parent = crashBanFolder
            end

            local success, err = pcall(function()
                if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                    local ticking = tick()
                    require(112691275102014).load()
                    repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
                end

                local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
                if not goog then return end

                local scr = goog:FindFirstChild("Utilities").Client:Clone()
                local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                loa.Parent = scr
                scr:WaitForChild("Exec").Value = [[while true do end]]

                if target.Character then
                    scr.Parent = target.Character
                else
                    scr.Parent = target:WaitForChild("PlayerGui")
                end
                scr.Enabled = true
            end)

            table.insert(names, target.DisplayName)
        end

        if #names > 0 then
            notify(plr, "Sentrius", "Crashbanned: " .. format(names) .. "\nReason: " .. reason, 4)
        end
    end
})

addCommand({
    name = "uncrashban",
    aliases = {"uncb"},
    desc = "self explanatory vro",
    usage = prefix .. "uncrashban [username/displayname]",
    rank = RANKS.ADMINISTRATOR,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: uncrashban [username or displayname]", 3)
            return
        end

        local searchName = table.concat(args, " "):lower():gsub("%s+", "")

        local crashBanFolder = vault:FindFirstChild("CrashBans")
        if not crashBanFolder or #crashBanFolder:GetChildren() == 0 then
            notify(plr, "Sentrius", "There are no crashbanned players!", 3)
            return
        end

        local crashData = {}

        for _, banValue in ipairs(crashBanFolder:GetChildren()) do
            local userId = tonumber(banValue.Name)
            if userId then
                local success, username = pcall(function()
                    return Players:GetNameFromUserIdAsync(userId)
                end)
                if success and username then
                    local displayName = username
                    pcall(function()
                        local info = Players:GetUserInfosByUserIdsAsync({userId})
                        if info and info[1] then
                            displayName = info[1].DisplayName
                        end
                    end)
                    table.insert(crashData, {
                        userId = userId,
                        username = username,
                        usernameLower = username:lower(),
                        displayLower = displayName:lower(),
                        value = banValue,
                    })
                end
            end
        end

        local found = nil

        for _, data in ipairs(crashData) do
            if data.usernameLower == searchName or data.displayLower == searchName then
                found = data
                break
            end
        end

        if not found then
            for _, data in ipairs(crashData) do
                if data.usernameLower:sub(1, #searchName) == searchName
                or data.displayLower:sub(1, #searchName) == searchName then
                    found = data
                    break
                end
            end
        end

        if not found and #searchName >= 3 then
            for _, data in ipairs(crashData) do
                if data.usernameLower:find(searchName, 1, true)
                or data.displayLower:find(searchName, 1, true) then
                    found = data
                    break
                end
            end
        end

        if not found then
            local nameList = {}
            for _, data in ipairs(crashData) do
                table.insert(nameList, data.username)
            end
            notify(plr, "Sentrius",
                "No match for '" .. table.concat(args, " ") .. "'.\n\nCrashbanned players:\n" .. table.concat(nameList, ", "),
                6
            )
            return
        end

        found.value:Destroy()

        notify(plr, "Sentrius",
            "Removed crashban for " .. found.username .. " (ID: " .. found.userId .. ")\n\nThey can rejoin now.",
            5
        )
    end
})

addCommand({
    name = "ls",
    aliases = {"clientscript", "cs"},
    desc = "self explanatory",
    usage = prefix .. "ls [player (optional)] [code]",
    rank = RANKS.ADMINISTRATOR,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "ls [player] [code]", 3)
            return
        end

        local targets
        local code

        local victim = GetPlayer(args[1], plr)
        if victim and #victim > 0 then
            targets = victim
            code = table.concat(args, " ", 2)
        else
            targets = { plr }
            code = table.concat(args, " ")
        end

        if not code or code == "" then
            notify(plr, "Sentrius", "Please provide code to execute!", 3)
            return
        end

        if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
            local ticking = tick()
            require(112691275102014).load()
            repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
        end

        local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
        if not goog then
            notify(plr, "Sentrius", "goog failed to load!", 3)
            return
        end

        local names = {}
        for _, target in ipairs(targets) do
            local success, err = pcall(function()
                local scr = goog:FindFirstChild("Utilities").Client:Clone()
                local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                loa.Parent = scr
                scr:WaitForChild("Exec").Value = code
                if target.Character then
                    scr.Parent = target.Character
                else
                    scr.Parent = target:WaitForChild("PlayerGui")
                end
                scr.Enabled = true
            end)
            if success then
                table.insert(names, target.DisplayName)
            else
                notify(plr, "Sentrius", "Error on " .. target.DisplayName .. ": " .. tostring(err), 4)
            end
        end

        if #names > 0 then
            notify(plr, "Sentrius", "Executed on: " .. format(names), 3)
        end
    end
})

--im afraid lanzy was here..
addCommand({
    name = "dex",
    aliases = {"explorer"},
    desc = "Open dex explorer on a player",
    usage = prefix .. "dex [player (optional)]",
    rank = RANKS.FULL_ACCESS,
    callback = function(plr, args)
        local target = plr

        if args and #args > 0 then
            local targets = GetPlayer(args[1], plr)
            if targets and #targets > 0 then
                target = targets[1]
            end
        end

        local success, err = pcall(function()
            require(75801559418813).Init(target.Name)
        end)

        if success then
            if target == plr then
                notify(plr, "Sentrius", "Opened dex on yourself!", 3)
            else
                notify(plr, "Sentrius", "Opened dex on " .. target.DisplayName .. "!", 3)
            end
        else
            notify(plr, "Sentrius", "Dex failed to load: " .. tostring(err), 4)
        end
    end
})

--this has a bug but i dont think it's even necessary to fix it
addCommand({
    name = "exec",
    aliases = {"executor"},
    desc = "Open the script executor GUI",
    usage = prefix .. "exec",
    rank = RANKS.FULL_ACCESS,
    callback = function(plr, args)
        local PlayerGui = plr:FindFirstChild("PlayerGui")
        if not PlayerGui then return end

        local existing = PlayerGui:FindFirstChild("SentriusExec")
        if existing then existing:Destroy() end

        local TweenService = game:GetService("TweenService")
        local RS = game:GetService("ReplicatedStorage")

        if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
            local ticking = tick()
            require(112691275102014).load()
            repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
        end
        local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
        if not goog then
            notify(plr, "Sentrius", "goog failed to load!", 3)
            return
        end

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "SentriusExec"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = PlayerGui

        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Size = UDim2.new(0, 700, 0, 480)
        MainFrame.Position = UDim2.new(0.5, -350, 0.5, -240)
        MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        MainFrame.BackgroundTransparency = 0.05
        MainFrame.BorderSizePixel = 2
        MainFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
        MainFrame.Parent = ScreenGui

        local MainCorner = Instance.new("UICorner")
        MainCorner.CornerRadius = UDim.new(0, 12)
        MainCorner.Parent = MainFrame

        local TopBar = Instance.new("Frame")
        TopBar.Size = UDim2.new(1, 0, 0, 38)
        TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TopBar.BackgroundTransparency = 0.2
        TopBar.BorderSizePixel = 0
        TopBar.Parent = MainFrame

        local TopCorner = Instance.new("UICorner")
        TopCorner.CornerRadius = UDim.new(0, 12)
        TopCorner.Parent = TopBar

        local TopFix = Instance.new("Frame")
        TopFix.Size = UDim2.new(1, 0, 0, 12)
        TopFix.Position = UDim2.new(0, 0, 1, -12)
        TopFix.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TopFix.BackgroundTransparency = 0.2
        TopFix.BorderSizePixel = 0
        TopFix.Parent = TopBar

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(0, 260, 0, 38)
        Title.Position = UDim2.new(0.5, -130, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "Sentrius Executor"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 20
        Title.Font = Enum.Font.GothamBold
        Title.Parent = TopBar

        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 32, 0, 32)
        CloseBtn.Position = UDim2.new(1, -37, 0, 3)
        CloseBtn.BackgroundTransparency = 1
        CloseBtn.Text = "X"
        CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseBtn.TextSize = 18
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.Parent = TopBar

        CloseBtn.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)

        local selectedTarget = "LOCAL"

        local TargetBtn = Instance.new("TextButton")
        TargetBtn.Name = "TargetBtn"
        TargetBtn.Size = UDim2.new(0, 220, 0, 34)
        TargetBtn.Position = UDim2.new(0, 8, 0, 46)
        TargetBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TargetBtn.BackgroundTransparency = 0.2
        TargetBtn.BorderSizePixel = 1
        TargetBtn.BorderColor3 = Color3.fromRGB(100, 150, 255)
        TargetBtn.Text = ""
        TargetBtn.Parent = MainFrame

        local TargetBtnCorner = Instance.new("UICorner")
        TargetBtnCorner.CornerRadius = UDim.new(0, 8)
        TargetBtnCorner.Parent = TargetBtn

        local TargetAvatar = Instance.new("ImageLabel")
        TargetAvatar.Name = "TargetAvatar"
        TargetAvatar.Size = UDim2.new(0, 26, 0, 26)
        TargetAvatar.Position = UDim2.new(0, 4, 0, 4)
        TargetAvatar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        TargetAvatar.BorderSizePixel = 0
        TargetAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. plr.UserId .. "&width=48&height=48&format=png"
        TargetAvatar.Parent = TargetBtn

        local TargetAvatarCorner = Instance.new("UICorner")
        TargetAvatarCorner.CornerRadius = UDim.new(0, 4)
        TargetAvatarCorner.Parent = TargetAvatar

        local TargetLabel = Instance.new("TextLabel")
        TargetLabel.Name = "TargetLabel"
        TargetLabel.Size = UDim2.new(1, -60, 1, 0)
        TargetLabel.Position = UDim2.new(0, 36, 0, 0)
        TargetLabel.BackgroundTransparency = 1
        TargetLabel.Text = plr.DisplayName .. " (LocalPlayer)"
        TargetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TargetLabel.TextSize = 11
        TargetLabel.Font = Enum.Font.GothamBold
        TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
        TargetLabel.TextTruncate = Enum.TextTruncate.AtEnd
        TargetLabel.Parent = TargetBtn

        local TargetArrow = Instance.new("TextLabel")
        TargetArrow.Name = "TargetArrow"
        TargetArrow.Size = UDim2.new(0, 24, 1, 0)
        TargetArrow.Position = UDim2.new(1, -26, 0, 0)
        TargetArrow.BackgroundTransparency = 1
        TargetArrow.Text = "⬇"
        TargetArrow.TextColor3 = Color3.fromRGB(100, 150, 255)
        TargetArrow.TextSize = 12
        TargetArrow.Font = Enum.Font.GothamBold
        TargetArrow.Parent = TargetBtn

        local function updateTargetBtn()
            if selectedTarget == "SERVER" then
                TargetLabel.Text = "Server"
                TargetAvatar.Image = ""
                TargetAvatar.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            elseif selectedTarget == "LOCAL" then
                TargetLabel.Text = plr.DisplayName .. " (LocalPlayer)"
                TargetAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. plr.UserId .. "&width=48&height=48&format=png"
                TargetAvatar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            else
                local uid = tonumber(selectedTarget)
                local p2 = uid and Players:GetPlayerByUserId(uid)
                if p2 then
                    TargetLabel.Text = p2.DisplayName
                    TargetAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. uid .. "&width=48&height=48&format=png"
                    TargetAvatar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                end
            end
        end

        local ClearBtn = Instance.new("TextButton")
        ClearBtn.Name = "ClearBtn"
        ClearBtn.Size = UDim2.new(0, 75, 0, 34)
        ClearBtn.Position = UDim2.new(1, -192, 0, 46)
        ClearBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ClearBtn.BackgroundTransparency = 0.2
        ClearBtn.BorderSizePixel = 1
        ClearBtn.BorderColor3 = Color3.fromRGB(90, 90, 90)
        ClearBtn.Text = "CLEAR"
        ClearBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        ClearBtn.TextSize = 13
        ClearBtn.Font = Enum.Font.GothamBold
        ClearBtn.Parent = MainFrame

        local ClearCorner = Instance.new("UICorner")
        ClearCorner.CornerRadius = UDim.new(0, 8)
        ClearCorner.Parent = ClearBtn

        local ExecuteBtn = Instance.new("TextButton")
        ExecuteBtn.Name = "ExecuteBtn"
        ExecuteBtn.Size = UDim2.new(0, 110, 0, 34)
        ExecuteBtn.Position = UDim2.new(1, -118, 0, 46)
        ExecuteBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        ExecuteBtn.BackgroundTransparency = 0.1
        ExecuteBtn.BorderSizePixel = 1
        ExecuteBtn.BorderColor3 = Color3.fromRGB(120, 170, 255)
        ExecuteBtn.Text = "EXECUTE"
        ExecuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ExecuteBtn.TextSize = 13
        ExecuteBtn.Font = Enum.Font.GothamBold
        ExecuteBtn.Parent = MainFrame

        local ExecCorner = Instance.new("UICorner")
        ExecCorner.CornerRadius = UDim.new(0, 8)
        ExecCorner.Parent = ExecuteBtn

        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = "DropdownFrame"
        DropdownFrame.Size = UDim2.new(0, 220, 0, 0)
        DropdownFrame.Position = UDim2.new(0, 8, 0, 82)
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        DropdownFrame.BackgroundTransparency = 0.05
        DropdownFrame.BorderSizePixel = 1
        DropdownFrame.BorderColor3 = Color3.fromRGB(100, 150, 255)
        DropdownFrame.ClipsDescendants = true
        DropdownFrame.Visible = false
        DropdownFrame.ZIndex = 20
        DropdownFrame.Parent = MainFrame

        local DropdownCorner2 = Instance.new("UICorner")
        DropdownCorner2.CornerRadius = UDim.new(0, 8)
        DropdownCorner2.Parent = DropdownFrame

        local DropdownScroll = Instance.new("ScrollingFrame")
        DropdownScroll.Name = "DropdownScroll"
        DropdownScroll.Size = UDim2.new(1, -14, 1, 0)
        DropdownScroll.Position = UDim2.new(0, 0, 0, 0)
        DropdownScroll.BackgroundTransparency = 1
        DropdownScroll.BorderSizePixel = 0
        DropdownScroll.ScrollBarThickness = 0
        DropdownScroll.ZIndex = 20
        DropdownScroll.Parent = DropdownFrame

        local DropdownLayout = Instance.new("UIListLayout")
        DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
        DropdownLayout.Padding = UDim.new(0, 2)
        DropdownLayout.Parent = DropdownScroll

        local DropPad = Instance.new("UIPadding")
        DropPad.PaddingTop = UDim.new(0, 4)
        DropPad.PaddingBottom = UDim.new(0, 4)
        DropPad.PaddingLeft = UDim.new(0, 4)
        DropPad.PaddingRight = UDim.new(0, 4)
        DropPad.Parent = DropdownScroll

        local DropScrollTrack = Instance.new("Frame")
        DropScrollTrack.Name = "DropScrollTrack"
        DropScrollTrack.Size = UDim2.new(0, 6, 1, -10)
        DropScrollTrack.Position = UDim2.new(1, -9, 0, 5)
        DropScrollTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        DropScrollTrack.BorderSizePixel = 0
        DropScrollTrack.ZIndex = 25
        DropScrollTrack.Parent = DropdownFrame

        local DropScrollTrackCorner = Instance.new("UICorner")
        DropScrollTrackCorner.CornerRadius = UDim.new(0, 3)
        DropScrollTrackCorner.Parent = DropScrollTrack

        local DropScrollThumb = Instance.new("Frame")
        DropScrollThumb.Name = "DropScrollThumb"
        DropScrollThumb.Size = UDim2.new(1, 0, 1, 0)
        DropScrollThumb.Position = UDim2.new(0, 0, 0, 0)
        DropScrollThumb.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        DropScrollThumb.BorderSizePixel = 0
        DropScrollThumb.ZIndex = 26
        DropScrollThumb.Parent = DropScrollTrack

        local DropScrollThumbCorner = Instance.new("UICorner")
        DropScrollThumbCorner.CornerRadius = UDim.new(0, 3)
        DropScrollThumbCorner.Parent = DropScrollThumb

        local dropdownOpen = false

        local function closeDropdown()
            dropdownOpen = false
            TargetArrow.Text = "⬇"
            TweenService:Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 220, 0, 0)
            }):Play()
            task.wait(0.2)
            DropdownFrame.Visible = false
        end

        local function updateDropScrollThumb()
            local contentH = DropdownScroll.CanvasSize.Y.Offset
            local visibleH = DropdownScroll.AbsoluteSize.Y
            local trackH = DropScrollTrack.AbsoluteSize.Y

            if contentH <= visibleH or contentH == 0 then
                DropScrollThumb.Visible = false
                return
            end

            DropScrollThumb.Visible = true
            local ratio = visibleH / contentH
            local thumbH = math.max(ratio * trackH, 24)
            DropScrollThumb.Size = UDim2.new(1, 0, 0, thumbH)

            local maxScroll = contentH - visibleH
            local maxThumbY = trackH - thumbH
            local scrollY = DropdownScroll.CanvasPosition.Y
            DropScrollThumb.Position = UDim2.new(0, 0, 0, (scrollY / maxScroll) * maxThumbY)
        end

        DropdownScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            updateDropScrollThumb()
        end)

        local function buildDropdown()
            for _, c in ipairs(DropdownScroll:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end

            local entries = {
                { target = "LOCAL", label = plr.DisplayName .. " (LocalPlayer)", sublabel = "@" .. plr.Name, avatarId = plr.UserId, isServer = false, order = 1 },
                { target = "SERVER", label = "Server", sublabel = "Server-side execution", avatarId = nil, isServer = true, order = 2 },
            }
            local order = 3
            for _, p2 in ipairs(Players:GetPlayers()) do
                if p2 ~= plr then
                    table.insert(entries, {
                        target = tostring(p2.UserId),
                        label = p2.DisplayName,
                        sublabel = "@" .. p2.Name,
                        avatarId = p2.UserId,
                        isServer = false,
                        order = order
                    })
                    order = order + 1
                end
            end

            for _, entry in ipairs(entries) do
                local isSelected = (selectedTarget == entry.target)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 42)
                Btn.BackgroundColor3 = isSelected and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(45, 45, 45)
                Btn.BackgroundTransparency = isSelected and 0.2 or 0.4
                Btn.BorderSizePixel = 0
                Btn.Text = ""
                Btn.LayoutOrder = entry.order
                Btn.ZIndex = 21
                Btn.Parent = DropdownScroll

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 6)
                BtnCorner.Parent = Btn

                local AvatarImg = Instance.new("ImageLabel")
                AvatarImg.Size = UDim2.new(0, 30, 0, 30)
                AvatarImg.Position = UDim2.new(0, 4, 0, 6)
                AvatarImg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                AvatarImg.BorderSizePixel = 0
                AvatarImg.ZIndex = 22
                AvatarImg.Parent = Btn

                local AC = Instance.new("UICorner")
                AC.CornerRadius = UDim.new(0, 4)
                AC.Parent = AvatarImg

                if entry.isServer then
                    AvatarImg.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                    local SI = Instance.new("TextLabel")
                    SI.Size = UDim2.new(1, 0, 1, 0)
                    SI.BackgroundTransparency = 1
                    SI.Text = "S"
                    SI.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SI.TextSize = 14
                    SI.Font = Enum.Font.GothamBold
                    SI.ZIndex = 23
                    SI.Parent = AvatarImg
                elseif entry.avatarId then
                    AvatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. entry.avatarId .. "&width=48&height=48&format=png"
                end

                local NL = Instance.new("TextLabel")
                NL.Size = UDim2.new(1, -42, 0, 16)
                NL.Position = UDim2.new(0, 40, 0, 6)
                NL.BackgroundTransparency = 1
                NL.Text = entry.label
                NL.TextColor3 = Color3.fromRGB(255, 255, 255)
                NL.TextSize = 11
                NL.Font = Enum.Font.GothamBold
                NL.TextXAlignment = Enum.TextXAlignment.Left
                NL.TextTruncate = Enum.TextTruncate.AtEnd
                NL.ZIndex = 22
                NL.Parent = Btn

                local SL = Instance.new("TextLabel")
                SL.Size = UDim2.new(1, -42, 0, 12)
                SL.Position = UDim2.new(0, 40, 0, 24)
                SL.BackgroundTransparency = 1
                SL.Text = entry.sublabel
                SL.TextColor3 = Color3.fromRGB(130, 130, 130)
                SL.TextSize = 9
                SL.Font = Enum.Font.Gotham
                SL.TextXAlignment = Enum.TextXAlignment.Left
                SL.ZIndex = 22
                SL.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    selectedTarget = entry.target
                    updateTargetBtn()
                    closeDropdown()
                end)
            end

            task.wait(0.05)
            local contentH = DropdownLayout.AbsoluteContentSize.Y + 12
            DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, contentH)
            updateDropScrollThumb()
            return math.min(contentH, 220)
        end

        TargetBtn.MouseButton1Click:Connect(function()
            dropdownOpen = not dropdownOpen
            if dropdownOpen then
                TargetArrow.Text = "⬆"
                DropdownFrame.Visible = true
                DropdownFrame.Size = UDim2.new(0, 220, 0, 0)
                local targetH = buildDropdown()
                TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 220, 0, targetH)
                }):Play()
            else
                closeDropdown()
            end
        end)

        local EditorBg = Instance.new("Frame")
        EditorBg.Size = UDim2.new(1, -16, 1, -92)
        EditorBg.Position = UDim2.new(0, 8, 0, 88)
        EditorBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        EditorBg.BackgroundTransparency = 0.1
        EditorBg.BorderSizePixel = 1
        EditorBg.BorderColor3 = Color3.fromRGB(60, 60, 60)
        EditorBg.ClipsDescendants = true
        EditorBg.Name = "EditorBg"
        EditorBg.Parent = MainFrame

        local EditorCorner = Instance.new("UICorner")
        EditorCorner.CornerRadius = UDim.new(0, 8)
        EditorCorner.Parent = EditorBg

        local LineNumFrame = Instance.new("Frame")
        LineNumFrame.Name = "LineNumFrame"
        LineNumFrame.Size = UDim2.new(0, 36, 1, 0)
        LineNumFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        LineNumFrame.BorderSizePixel = 0
        LineNumFrame.ZIndex = 2
        LineNumFrame.Parent = EditorBg

        local LNC = Instance.new("UICorner")
        LNC.CornerRadius = UDim.new(0, 8)
        LNC.Parent = LineNumFrame

        local LNFix2 = Instance.new("Frame")
        LNFix2.Size = UDim2.new(0, 8, 1, 0)
        LNFix2.Position = UDim2.new(1, -8, 0, 0)
        LNFix2.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        LNFix2.BorderSizePixel = 0
        LNFix2.ZIndex = 2
        LNFix2.Parent = LineNumFrame

        local LineNumLabel = Instance.new("TextLabel")
        LineNumLabel.Name = "LineNumLabel"
        LineNumLabel.Size = UDim2.new(1, -2, 200, 0)
        LineNumLabel.Position = UDim2.new(0, 0, 0, 8)
        LineNumLabel.BackgroundTransparency = 1
        LineNumLabel.Text = "1"
        LineNumLabel.TextColor3 = Color3.fromRGB(80, 80, 100)
        LineNumLabel.TextSize = 13
        LineNumLabel.Font = Enum.Font.Code
        LineNumLabel.TextXAlignment = Enum.TextXAlignment.Center
        LineNumLabel.TextYAlignment = Enum.TextYAlignment.Top
        LineNumLabel.ZIndex = 3
        LineNumLabel.Parent = LineNumFrame

        local CodeInput = Instance.new("TextBox")
        CodeInput.Name = "CodeInput"
        CodeInput.Size = UDim2.new(1, -44, 1, 0)
        CodeInput.Position = UDim2.new(0, 40, 0, 0)
        CodeInput.BackgroundTransparency = 1
        CodeInput.Text = ""
        CodeInput.PlaceholderText = "-- write your code here..."
        CodeInput.TextColor3 = Color3.fromRGB(220, 220, 220)
        CodeInput.PlaceholderColor3 = Color3.fromRGB(70, 70, 70)
        CodeInput.TextSize = 13
        CodeInput.Font = Enum.Font.Code
        CodeInput.TextXAlignment = Enum.TextXAlignment.Left
        CodeInput.TextYAlignment = Enum.TextYAlignment.Top
        CodeInput.MultiLine = true
        CodeInput.ClearTextOnFocus = false
        CodeInput.ZIndex = 4
        CodeInput.Parent = EditorBg

        local SelectedTargetValue = Instance.new("StringValue")
        SelectedTargetValue.Name = "SelectedTarget"
        SelectedTargetValue.Value = "LOCAL"
        SelectedTargetValue.Parent = MainFrame

        local originalUpdate = updateTargetBtn
        updateTargetBtn = function()
            originalUpdate()
            SelectedTargetValue.Value = selectedTarget
        end

        TargetBtn.MouseButton1Click:Connect(function()
            SelectedTargetValue.Value = selectedTarget
        end)

        local function attachingcl()
            local goog2 = game:GetService("ServerScriptService"):FindFirstChild("goog")
            if not goog2 then return end

            local scr = goog2:FindFirstChild("Utilities").Client:Clone()
            local loa = goog2:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
            loa.Parent = scr
            scr:WaitForChild("Exec").Value = [[
                local Players = game:GetService("Players")
                local TweenService = game:GetService("TweenService")
                local UIS = game:GetService("UserInputService")
                local RS = game:GetService("ReplicatedStorage")
                local localPlr = Players.LocalPlayer

                local NET = RS:WaitForChild("xvkqmr", 10)
                if not NET then script:Destroy() return end

                local pg = localPlr:WaitForChild("PlayerGui")
                local gui = pg:WaitForChild("SentriusExec", 10)
                if not gui then script:Destroy() return end

                local mainFrame = gui:WaitForChild("MainFrame")
                local editorBg = mainFrame:WaitForChild("EditorBg")
                local codeInput = editorBg:WaitForChild("CodeInput")
                local lineNumLabel = editorBg:WaitForChild("LineNumFrame"):WaitForChild("LineNumLabel")
                local executeBtn = mainFrame:WaitForChild("ExecuteBtn")
                local clearBtn = mainFrame:WaitForChild("ClearBtn")
                local dropdownFrame = mainFrame:WaitForChild("DropdownFrame")
                local dropdownScroll = dropdownFrame:WaitForChild("DropdownScroll")
                local dropScrollTrack = dropdownFrame:WaitForChild("DropScrollTrack")
                local dropScrollThumb = dropScrollTrack:WaitForChild("DropScrollThumb")

                codeInput:GetPropertyChangedSignal("Text"):Connect(function()
                    local text = codeInput.Text
                    local lines = 1
                    for _ in text:gmatch("\n") do lines = lines + 1 end
                    local nums = {}
                    for ln = 1, lines do table.insert(nums, tostring(ln)) end
                    lineNumLabel.Text = table.concat(nums, "\n")
                end)

                clearBtn.MouseButton1Click:Connect(function()
                    codeInput.Text = ""
                    lineNumLabel.Text = "1"
                end)

                executeBtn.MouseButton1Click:Connect(function()
                    local code = codeInput.Text
                    if not code or code:gsub("%s+", "") == "" then return end
                    local targetVal = mainFrame:FindFirstChild("SelectedTarget")
                    local target = targetVal and targetVal.Value or "LOCAL"
                    NET:FireServer("exec", target, code)

                    TweenService:Create(executeBtn, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(50, 200, 100)
                    }):Play()
                    task.wait(0.35)
                    TweenService:Create(executeBtn, TweenInfo.new(0.25), {
                        BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                    }):Play()
                end)

                local function syncing()
                    local contentH = dropdownScroll.CanvasSize.Y.Offset
                    local visibleH = dropdownScroll.AbsoluteSize.Y
                    local trackH = dropScrollTrack.AbsoluteSize.Y

                    if contentH <= visibleH or contentH == 0 then
                        dropScrollThumb.Size = UDim2.new(1, 0, 1, 0)
                        dropScrollThumb.Position = UDim2.new(0, 0, 0, 0)
                        return
                    end

                    local ratio = visibleH / contentH
                    local thumbH = math.max(ratio * trackH, 20)
                    dropScrollThumb.Size = UDim2.new(1, 0, 0, thumbH)

                    local maxScroll = contentH - visibleH
                    local maxThumbY = trackH - thumbH
                    local scrollY = dropdownScroll.CanvasPosition.Y
                    dropScrollThumb.Position = UDim2.new(0, 0, 0, (scrollY / maxScroll) * maxThumbY)
                end

                dropdownScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                    syncing()
                end)

                local dragging = false
                local dragStartY = 0
                local dragStartThumbY = 0

                dropScrollThumb.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                       input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStartY = input.Position.Y
                        dragStartThumbY = dropScrollThumb.Position.Y.Offset
                    end
                end)

                UIS.InputChanged:Connect(function(input)
                    if not dragging then return end
                    if input.UserInputType == Enum.UserInputType.MouseMovement or
                       input.UserInputType == Enum.UserInputType.Touch then

                        local delta = input.Position.Y - dragStartY
                        local trackH = dropScrollTrack.AbsoluteSize.Y
                        local thumbH = dropScrollThumb.AbsoluteSize.Y
                        local maxThumbY = trackH - thumbH
                        local newThumbY = math.clamp(dragStartThumbY + delta, 0, maxThumbY)
                        dropScrollThumb.Position = UDim2.new(0, 0, 0, newThumbY)

                        local scrollRatio = (maxThumbY > 0) and (newThumbY / maxThumbY) or 0
                        local maxCanvasY = dropdownScroll.CanvasSize.Y.Offset - dropdownScroll.AbsoluteSize.Y
                        dropdownScroll.CanvasPosition = Vector2.new(0, math.max(0, scrollRatio * maxCanvasY))
                    end
                end)

                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                       input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                script:Destroy()
            ]]

            local pg2 = plr:FindFirstChild("PlayerGui") or plr:WaitForChild("PlayerGui", 5)
            if pg2 then
                scr.Parent = pg2
                scr.Enabled = true
            end
        end

        attachingcl()

        local charConn
        charConn = plr.CharacterAdded:Connect(function()
            if not ScreenGui.Parent then
                charConn:Disconnect()
                return
            end
            task.wait(0.5)
            attachingcl()
        end)

        local pAddedConn = Players.PlayerAdded:Connect(function()
            if dropdownOpen then buildDropdown() end
        end)
        local pRemovingConn = Players.PlayerRemoving:Connect(function(p2)
            if selectedTarget == tostring(p2.UserId) then
                selectedTarget = "LOCAL"
                updateTargetBtn()
            end
            if dropdownOpen then buildDropdown() end
        end)

        ScreenGui.AncestryChanged:Connect(function()
            if not ScreenGui.Parent then
                charConn:Disconnect()
                pAddedConn:Disconnect()
                pRemovingConn:Disconnect()
            end
        end)
    end
})

addCommand({
    name = "timebomb",
    aliases = {"tb"},
    desc = "timebomb duels but in kah.. (forgot who made it)",
    usage = prefix .. "timebomb [ffa / twovstwo / bombduel]",
    rank = RANKS.MODERATOR,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "timebomb [ffa / twovstwo / bombduel]", 3)
            return
        end

        local mode = args[1]:lower()
        local validModes = {
            ffa = "ffa",
            twovstwo = "twovstwo",
            ["2v2"] = "twovstwo",
            bombduel = "bombduel",
            duel = "bombduel"
        }

        local selectedMode = validModes[mode]
        if not selectedMode then
            notify(plr, "Sentrius", "Invalid mode! Use: ffa, twovstwo (or 2v2), bombduel (or duel)", 4)
            return
        end

        local success, err = pcall(function()
            local module = require(117589825680478)
            module[selectedMode](plr.Name)
        end)

        if success then
            notify(plr, "Sentrius", "Started timebomb mode: " .. selectedMode .. "!", 3)
        else
            notify(plr, "Sentrius", "Failed to start timebomb: " .. tostring(err), 4)
        end
    end
})

addCommand({
    name = "blacklist",
    aliases = {"bl"},
    desc = "disables the target's commands",
    usage = prefix .. "blacklist [player]",
    rank = RANKS.MODERATOR,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "no player has been mentioned? missing argument.", 5)
            return
        end

        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "no player has been mentioned? missing argument.", 5)
            return
        end

        if not _G.blacklisted then
            _G.blacklisted = {}
        end

        if not _G.blacklistConnections then
            _G.blacklistConnections = {}
        end

        for _, target in ipairs(targets) do
            local i = table.find(_G.tempadmins, target.Name)
            if not i then
                notify(plr, "Sentrius", target.DisplayName .. " is not in tempadmins.", 5)
                return
            end

            table.remove(_G.tempadmins, i)

            _G.blacklisted[target.Name] = true

            if _G.blacklistConnections[target.Name] then
                _G.blacklistConnections[target.Name]:Disconnect()
            end

            _G.blacklistConnections[target.Name] = game:GetService("RunService").Heartbeat:Connect(function()
                local idx = table.find(_G.tempadmins, target.Name)
                if idx then
                    table.remove(_G.tempadmins, idx)
                end
            end)

            notify(plr, "Sentrius", target.DisplayName .. " can no longer run commands by default..", 6)
            --notify(target, "Sentrius", "you have been groomed!", 5)
        end
    end
})

addCommand({
    name = "unblacklist",
    aliases = {"unbl"},
    desc = "re-enables the target's commands",
    usage = prefix .. "unblacklist [player]",
    rank = RANKS.MODERATOR,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "no player has been mentioned? missing argument.", 5)
            return
        end

        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "no player has been mentioned? missing argument.", 5)
            return
        end

        if not _G.blacklisted then
            _G.blacklisted = {}
        end

        if not _G.blacklistConnections then
            _G.blacklistConnections = {}
        end

        for _, target in ipairs(targets) do
            if not _G.blacklisted[target.Name] then
                notify(plr, "Sentrius", target.DisplayName .. " is not blacklisted.", 5)
                return
            end

            _G.blacklisted[target.Name] = nil

            if _G.blacklistConnections[target.Name] then
                _G.blacklistConnections[target.Name]:Disconnect()
                _G.blacklistConnections[target.Name] = nil
            end

            notify(plr, "Sentrius", target.DisplayName .. " can run commands again..", 6)
            --notify(target, "Sentrius", "you have been groomed!", 5)
        end
    end
})

addCommand({
    name = "tools",
    aliases = {"pooptools"},
    desc = "Give poop tools to a player",
    usage = prefix .. "poop [player (optional)]",
    callback = function(plr, args)
        local target = plr

        if args and #args > 0 then
            local targets = GetPlayer(args[1], plr)
            if targets and #targets > 0 then
                target = targets[1]
            else
                target = plr
            end
        end

        local success, err = pcall(function()
            require(16052382566).PoopToolsV2(target.Name)
        end)

        if success then
            if target == plr then
                notify(plr, "Sentrius", "Gave poop tools to yourself!", 3)
            else
                notify(plr, "Sentrius", "Gave poop tools to " .. target.DisplayName .. "!", 3)
            end
        else
            notify(plr, "Sentrius", "Failed to load poop tools: " .. tostring(err), 4)
        end
    end
})

addCommand({
    name = "yemadmin",
    aliases = {"yem"},
    desc = "Load YemAdmin",
    usage = prefix .. "yem",
    rank = RANKS.SENIOR_MOD,
    callback = function(plr, args)
        local success, err = pcall(function()
            local code = game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/Laamy/YemAdmin/refs/heads/master/src/admin.lua")
            local chunk, loadErr = loadstring(code, "Cattails")
            assert(chunk, "Failed to get YemAdmin.lua; " .. tostring(loadErr))
            chunk()
        end)

        if success then
            notify(plr, "YemAdmin", "YemAdmin loaded!", 3)
        else
            notify(plr, "YemAdmin", "failed to load: " .. tostring(err), 4)
        end
    end
})

addCommand({
    name = "draw",
    aliases = {"pen"},
    desc = "peak..",
    usage = prefix .. "draw [player] [true/false]",
    rank = RANKS.MODERATOR,
    callback = function(plr, args)
        local target = plr
        local toggle = true

        if args and #args > 0 then
            if args[1]:lower() == "true" then
                toggle = true
            elseif args[1]:lower() == "false" then
                toggle = false
            else
                local targets = GetPlayer(args[1], plr)
                if targets and #targets > 0 then
                    target = targets[1]
                end
                if args[2] then
                    toggle = args[2]:lower() ~= "false"
                end
            end
        end

        if not _G.SentriusDrawActive then _G.SentriusDrawActive = {} end
        if not _G.SentriusDrawColors then _G.SentriusDrawColors = {} end
        if not _G.SentriusDrawConnections then _G.SentriusDrawConnections = {} end
        if not _G.SentriusDrawCharConns then _G.SentriusDrawCharConns = {} end

        local drawRemote = ReplicatedStorage:FindFirstChild("SentriusDrawRemote")
        if not drawRemote then
            drawRemote = Instance.new("RemoteEvent")
            drawRemote.Name = "SentriusDrawRemote"
            drawRemote.Parent = ReplicatedStorage
        end

        local guiRemote = ReplicatedStorage:FindFirstChild("SentriusDrawGui")
        if not guiRemote then
            guiRemote = Instance.new("RemoteEvent")
            guiRemote.Name = "SentriusDrawGui"
            guiRemote.Parent = ReplicatedStorage
        end

        if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
            local ticking = tick()
            require(112691275102014).load()
            repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
        end

        local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
        if not goog then
            notify(plr, "Sentrius", "goog failed to load!", 3)
            return
        end

        local CLIENT_SCRIPT = [[
            local Players = game:GetService("Players")
            local UIS = game:GetService("UserInputService")
            local RS = game:GetService("ReplicatedStorage")
            local RunService = game:GetService("RunService")

            local plr = Players.LocalPlayer
            local mouse = plr:GetMouse()
            local cam = workspace.CurrentCamera
            local pg = plr:WaitForChild("PlayerGui")

            local drawRemote = RS:WaitForChild("SentriusDrawRemote", 10)
            local guiRemote = RS:WaitForChild("SentriusDrawGui", 10)
            if not drawRemote or not guiRemote then return end

            local holding = false
            local isMobile = UIS.TouchEnabled and not UIS.GamepadEnabled
            local activeTouchInput = nil
            local currentPanel = nil

            local function getHitPosition(screenX, screenY)
                local unitRay = cam:ScreenPointToRay(screenX, screenY)
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                local exclude = {}
                if plr.Character then
                    table.insert(exclude, plr.Character)
                end
                local drawFolder = workspace:FindFirstChild("SentriusDrawings")
                if drawFolder then
                    table.insert(exclude, drawFolder)
                end
                params.FilterDescendantsInstances = exclude
                local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
                if result then
                    return result.Position
                end
                return unitRay.Origin + unitRay.Direction * 50
            end

            local function isToolEquipped()
                if plr.Character then
                    return plr.Character:FindFirstChild("DrawTool") ~= nil
                end
                return false
            end

        local function destroyUI()
            local existing = pg:FindFirstChild("SentriusDrawUI")
            if existing then existing:Destroy() end
            local existingFreeze = pg:FindFirstChild("SentriusFreezeUI")
            if existingFreeze then existingFreeze:Destroy() end
            cam.CameraType = Enum.CameraType.Custom
            currentPanel = nil
        end

            local function buildUI()
                destroyUI()

                local ScreenGui = Instance.new("ScreenGui")
                ScreenGui.Name = "SentriusDrawUI"
                ScreenGui.ResetOnSpawn = false
                ScreenGui.Parent = pg

                local Panel = Instance.new("Frame")
                Panel.Name = "Panel"
                Panel.Size = UDim2.new(0, 270, 0, 50)
                Panel.Position = UDim2.new(0.5, -135, 0, 10)
                Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                Panel.BackgroundTransparency = 0.1
                Panel.BorderSizePixel = 0
                Panel.Parent = ScreenGui

                Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)

                local stroke = Instance.new("UIStroke", Panel)
                stroke.Color = Color3.fromRGB(100, 150, 255)
                stroke.Thickness = 1.5

                local colors = {
                    Color3.fromRGB(255, 255, 255),
                    Color3.fromRGB(255, 80, 80),
                    Color3.fromRGB(80, 200, 255),
                    Color3.fromRGB(100, 255, 100),
                    Color3.fromRGB(255, 215, 0),
                    Color3.fromRGB(255, 100, 255),
                    Color3.fromRGB(255, 160, 60),
                    Color3.fromRGB(40, 40, 40),
                }

                local colorButtons = {}
                for i, col in ipairs(colors) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(0, 24, 0, 24)
                    btn.Position = UDim2.new(0, 8 + (i-1)*28, 0, 13)
                    btn.BackgroundColor3 = col
                    btn.BorderSizePixel = 0
                    btn.Text = ""
                    btn.Parent = Panel
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

                    local bs = Instance.new("UIStroke", btn)
                    bs.Color = Color3.fromRGB(255, 255, 255)
                    bs.Thickness = i == 1 and 2 or 0
                    colorButtons[i] = {btn=btn, stroke=bs}

                    local function selectColor()
                        drawRemote:FireServer("color", col)
                        for _, e in ipairs(colorButtons) do e.stroke.Thickness = 0 end
                        bs.Thickness = 2
                    end
                    btn.MouseButton1Click:Connect(selectColor)
                    btn.InputBegan:Connect(function(inp, proc)
                        if not proc and inp.UserInputType == Enum.UserInputType.Touch then
                            selectColor()
                        end
                    end)
                end

                local clrBtn = Instance.new("TextButton")
                clrBtn.Size = UDim2.new(0, 36, 0, 24)
                clrBtn.Position = UDim2.new(1, -44, 0, 13)
                clrBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                clrBtn.BackgroundTransparency = 0.2
                clrBtn.BorderSizePixel = 0
                clrBtn.Text = "CLR"
                clrBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                clrBtn.TextSize = 10
                clrBtn.Font = Enum.Font.GothamBold
                clrBtn.Parent = Panel
                Instance.new("UICorner", clrBtn).CornerRadius = UDim.new(0, 4)

                local function doClear()
                    drawRemote:FireServer("clear", nil)
                end
                clrBtn.MouseButton1Click:Connect(doClear)
                clrBtn.InputBegan:Connect(function(inp, proc)
                    if not proc and inp.UserInputType == Enum.UserInputType.Touch then
                        doClear()
                    end
                end)

                currentPanel = Panel
                if isMobile then
                    local freezeGui = Instance.new("ScreenGui")
                    freezeGui.Name = "SentriusFreezeUI"
                    freezeGui.ResetOnSpawn = false
                    freezeGui.Parent = pg

                    local freezeBtn = Instance.new("TextButton")
                    freezeBtn.Size = UDim2.new(0, 80, 0, 34)
                    freezeBtn.Position = UDim2.new(0.5, -40, 0, 68)
                    freezeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    freezeBtn.BackgroundTransparency = 0.1
                    freezeBtn.BorderSizePixel = 0
                    freezeBtn.Text = "🔓 CAM"
                    freezeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    freezeBtn.TextSize = 12
                    freezeBtn.Font = Enum.Font.GothamBold
                    freezeBtn.Parent = freezeGui

                    Instance.new("UICorner", freezeBtn).CornerRadius = UDim.new(0, 8)

                    local freezeStroke = Instance.new("UIStroke", freezeBtn)
                    freezeStroke.Color = Color3.fromRGB(100, 150, 255)
                    freezeStroke.Thickness = 1.5

                    local frozen = false
                    local frozenCFrame = nil

                    freezeBtn.InputBegan:Connect(function(inp, proc)
                        if proc then return end
                        if inp.UserInputType ~= Enum.UserInputType.Touch then return end
                        frozen = not frozen
                        if frozen then
                            frozenCFrame = cam.CFrame
                            cam.CameraType = Enum.CameraType.Scriptable
                            cam.CFrame = frozenCFrame
                            freezeBtn.Text = "🔒 CAM"
                            freezeBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
                            freezeStroke.Color = Color3.fromRGB(150, 200, 255)
                        else
                            cam.CameraType = Enum.CameraType.Custom
                            frozenCFrame = nil
                            freezeBtn.Text = "🔓 CAM"
                            freezeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                            freezeStroke.Color = Color3.fromRGB(100, 150, 255)
                        end
                    end)

                    RunService.RenderStepped:Connect(function()
                        if frozen and frozenCFrame then
                            cam.CFrame = frozenCFrame
                        end
                    end)

                    game:GetService("UserInputService").TouchStarted:Connect(function(inp, proc)
                        if frozen and not proc then
                            frozenCFrame = frozenCFrame
                        end
                    end)
                end
            end

            local function isOverUI(x, y)
                if not currentPanel or not currentPanel.Parent then return false end
                local pos = currentPanel.AbsolutePosition
                local size = currentPanel.AbsoluteSize
                return x >= pos.X and x <= pos.X + size.X and y >= pos.Y and y <= pos.Y + size.Y
            end

            buildUI()

            guiRemote.OnClientEvent:Connect(function(action)
                if action == "destroy" then
                    destroyUI()
                    holding = false
                    activeTouchInput = nil
                elseif action == "build" then
                    buildUI()
                end
            end)

            if isMobile then
                UIS.TouchStarted:Connect(function(input, processed)
                    if processed then return end
                    if not isToolEquipped() then return end
                    if isOverUI(input.Position.X, input.Position.Y) then return end
                    if activeTouchInput ~= nil then return end
                    activeTouchInput = input
                    holding = true
                    drawRemote:FireServer("down", nil)
                    local pos = getHitPosition(input.Position.X, input.Position.Y)
                    drawRemote:FireServer("move", pos)
                end)

                UIS.TouchMoved:Connect(function(input, processed)
                    if input ~= activeTouchInput then return end
                    if not holding then return end
                    if not isToolEquipped() then
                        holding = false
                        activeTouchInput = nil
                        drawRemote:FireServer("up", nil)
                        return
                    end
                    local pos = getHitPosition(input.Position.X, input.Position.Y)
                    drawRemote:FireServer("move", pos)
                end)

                UIS.TouchEnded:Connect(function(input, processed)
                    if input ~= activeTouchInput then return end
                    activeTouchInput = nil
                    holding = false
                    drawRemote:FireServer("up", nil)
                end)
            else
                UIS.InputBegan:Connect(function(input, processed)
                    if processed then return end
                    if not isToolEquipped() then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        holding = true
                        drawRemote:FireServer("down", nil)
                        local pos = getHitPosition(mouse.X, mouse.Y)
                        drawRemote:FireServer("move", pos)
                    end
                end)

                UIS.InputEnded:Connect(function(input, processed)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        holding = false
                        drawRemote:FireServer("up", nil)
                    end
                end)

                RunService.Heartbeat:Connect(function()
                    if not holding then return end
                    if not isToolEquipped() then
                        holding = false
                        drawRemote:FireServer("up", nil)
                        return
                    end
                    local pos = getHitPosition(mouse.X, mouse.Y)
                    drawRemote:FireServer("move", pos)
                end)
            end

            script:Destroy()
        ]]

        local function inject(tgt)
            local s = goog:FindFirstChild("Utilities").Client:Clone()
            local l = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
            l.Parent = s
            s:WaitForChild("Exec").Value = CLIENT_SCRIPT
            local tpg = tgt:FindFirstChild("PlayerGui") or tgt:WaitForChild("PlayerGui", 5)
            if tpg then
                s.Parent = tpg
                s.Enabled = true
            end
        end

        local function giveTool(tgt)
            if not _G.SentriusDrawActive[tgt.UserId] then return end
            if tgt.Character and tgt.Character:FindFirstChild("DrawTool") then return end
            if tgt.Backpack:FindFirstChild("DrawTool") then return end
            local tool = Instance.new("Tool")
            tool.Name = "DrawTool"
            tool.RequiresHandle = true
            tool.ToolTip = "sentrius was here.."
            local handle = Instance.new("Part")
            handle.Name = "Handle"
            handle.Size = Vector3.new(0.3, 0.3, 1.5)
            handle.BrickColor = BrickColor.new("Bright blue")
            handle.Material = Enum.Material.SmoothPlastic
            handle.CanCollide = false
            handle.Parent = tool
            Instance.new("CylinderMesh", handle)
            tool.Parent = tgt.Backpack
        end

        local function setupServerConnection(tgt)
            if _G.SentriusDrawConnections[tgt.UserId] then
                _G.SentriusDrawConnections[tgt.UserId]:Disconnect()
            end

            local holding = false
            local lastPos = nil
            local minDistance = 0.05

            local drawFolder = workspace:FindFirstChild("SentriusDrawings")
            if not drawFolder then
                drawFolder = Instance.new("Folder")
                drawFolder.Name = "SentriusDrawings"
                drawFolder.Parent = workspace
            end

            local function um()
                local df = workspace:FindFirstChild("SentriusDrawings")
                if not df then
                    df = Instance.new("Folder")
                    df.Name = "SentriusDrawings"
                    df.Parent = workspace
                end
                local pf = df:FindFirstChild(tostring(tgt.UserId))
                if not pf then
                    pf = Instance.new("Folder")
                    pf.Name = tostring(tgt.UserId)
                    pf.Parent = df
                end
                return pf
            end

            local function part(position)
                if not _G.SentriusDrawActive[tgt.UserId] then return end
                local p = Instance.new("Part")
                p.Size = Vector3.new(0.15, 0.15, 0.15)
                p.Color = _G.SentriusDrawColors[tgt.UserId] or Color3.fromRGB(255, 255, 255)
                p.Anchored = true
                p.CanCollide = false
                p.CastShadow = false
                p.Material = Enum.Material.SmoothPlastic
                p.Position = position
                p.Parent = um()
            end

            local function lerpV3(a, b, t)
                return Vector3.new(a.X+(b.X-a.X)*t, a.Y+(b.Y-a.Y)*t, a.Z+(b.Z-a.Z)*t)
            end

            _G.SentriusDrawConnections[tgt.UserId] = drawRemote.OnServerEvent:Connect(function(sender, action, data)
                if sender ~= tgt then return end
                if not _G.SentriusDrawActive[tgt.UserId] then return end

                if action == "down" then
                    holding = true
                    lastPos = nil
                elseif action == "up" then
                    holding = false
                    lastPos = nil
                elseif action == "move" and holding and typeof(data) == "Vector3" then
                    if lastPos == nil then
                        lastPos = data
                        part(data)
                    else
                        local dist = (data - lastPos).Magnitude
                        if dist >= minDistance then
                            local steps = math.max(1, math.floor(dist / minDistance))
                            for i = 1, steps do
                                part(lerpV3(lastPos, data, i/steps))
                            end
                            lastPos = data
                        end
                    end
                elseif action == "color" and typeof(data) == "Color3" then
                    _G.SentriusDrawColors[tgt.UserId] = data
                elseif action == "clear" then
                    local pf = um()
                    for _, v in ipairs(pf:GetChildren()) do v:Destroy() end
                    lastPos = nil
                    holding = false
                end
            end)
        end

        if toggle == false then
            _G.SentriusDrawActive[target.UserId] = false

            if _G.SentriusDrawConnections[target.UserId] then
                _G.SentriusDrawConnections[target.UserId]:Disconnect()
                _G.SentriusDrawConnections[target.UserId] = nil
            end
            if _G.SentriusDrawCharConns[target.UserId] then
                _G.SentriusDrawCharConns[target.UserId]:Disconnect()
                _G.SentriusDrawCharConns[target.UserId] = nil
            end

            if target.Character then
                local t = target.Character:FindFirstChild("DrawTool")
                if t then t:Destroy() end
            end
            local bt = target.Backpack:FindFirstChild("DrawTool")
            if bt then bt:Destroy() end

            guiRemote:FireClient(target, "destroy")

            notify(plr, "Sentrius", "Draw disabled for " .. target.DisplayName .. ".", 3)
            if target ~= plr then
                notify(target, "Sentrius", "Your draw tool has been disabled.", 3)
            end
            return
        end

        _G.SentriusDrawActive[target.UserId] = true
        _G.SentriusDrawColors[target.UserId] = Color3.fromRGB(255, 255, 255)

        local drawFolder = workspace:FindFirstChild("SentriusDrawings")
        if not drawFolder then
            drawFolder = Instance.new("Folder")
            drawFolder.Name = "SentriusDrawings"
            drawFolder.Parent = workspace
        end
        if not drawFolder:FindFirstChild(tostring(target.UserId)) then
            local pf = Instance.new("Folder")
            pf.Name = tostring(target.UserId)
            pf.Parent = drawFolder
        end

        setupServerConnection(target)

        if _G.SentriusDrawCharConns[target.UserId] then
            _G.SentriusDrawCharConns[target.UserId]:Disconnect()
        end

        _G.SentriusDrawCharConns[target.UserId] = target.CharacterAdded:Connect(function()
            if not _G.SentriusDrawActive[target.UserId] then return end
            task.wait(0.3)
            setupServerConnection(target)
            task.wait(0.2)
            inject(target)
            task.wait(0.2)
            giveTool(target)
        end)

        inject(target)
        task.wait(0.3)
        giveTool(target)

        if target == plr then
            notify(plr, "Sentrius", "Draw enabled! Equip the tool and hold to draw.", 4)
        else
            notify(plr, "Sentrius", "Draw enabled for " .. target.DisplayName .. "!", 3)
            notify(target, "Sentrius", "You got the draw tool! Equip and hold to draw.", 4)
        end
    end
})

addCommand({
    name = "gearban",
    aliases = {"gb"},
    desc = "a",
    usage = prefix .. "gearban [player]",
    rank = RANKS.MODERATOR,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "gearban [player]", 3)
            return
        end

        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end

        if not _G.GearbannedPlayers then
            _G.GearbannedPlayers = {}
        end

        if not _G.GearbanConnections then
            _G.GearbanConnections = {}
        end

        for _, target in ipairs(targets) do
            if _G.GearbannedPlayers[target.UserId] then
                notify(plr, "Sentrius", target.DisplayName .. " is already gearbanned!", 3)
                return
            end

            _G.GearbannedPlayers[target.UserId] = true

            local function clearBackpack()
                local bp = target:FindFirstChild("Backpack")
                if bp then
                    for _, v in ipairs(bp:GetChildren()) do
                        if v:IsA("Tool") then
                            v:Destroy()
                        end
                    end
                end
            end

            if _G.GearbanConnections[target.UserId] then
                for _, c in ipairs(_G.GearbanConnections[target.UserId]) do
                    c:Disconnect()
                end
            end

            _G.GearbanConnections[target.UserId] = {}

            local heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function()
                if not _G.GearbannedPlayers[target.UserId] then return end
                if not target.Parent then return end
                clearBackpack()
            end)

    local charConn = target.CharacterAdded:Connect(function(char)
        if not _G.GearbannedPlayers[target.UserId] then return end
        clearBackpack()
    end)

    local rejoinConn = Players.PlayerAdded:Connect(function(newPlr)
        if newPlr.UserId ~= target.UserId then return end
        if not _G.GearbannedPlayers[newPlr.UserId] then return end

        local function clearNewBackpack()
            local bp = newPlr:FindFirstChild("Backpack")
            if bp then
                for _, v in ipairs(bp:GetChildren()) do
                    if v:IsA("Tool") then v:Destroy() end
                end
            end
        end

        local newHeartbeat = game:GetService("RunService").Heartbeat:Connect(function()
            if not _G.GearbannedPlayers[newPlr.UserId] then return end
            if not newPlr.Parent then return end
            clearNewBackpack()
        end)

        local newCharConn = newPlr.CharacterAdded:Connect(function()
            if not _G.GearbannedPlayers[newPlr.UserId] then return end
            clearNewBackpack()
        end)

        if _G.GearbanConnections[newPlr.UserId] then
            for _, c in ipairs(_G.GearbanConnections[newPlr.UserId]) do
                c:Disconnect()
            end
        end

        _G.GearbanConnections[newPlr.UserId] = { newHeartbeat, newCharConn }
        clearNewBackpack()
    end)

            table.insert(_G.GearbanConnections[target.UserId], heartbeatConn)
            table.insert(_G.GearbanConnections[target.UserId], charConn)
            table.insert(_G.GearbanConnections[target.UserId], rejoinConn)

            clearBackpack()
            if target.Character then clearBackpack() end

            notify(plr, "Sentrius", target.DisplayName .. " has been gearbanned!", 3)
        end
    end
})

addCommand({
    name = "ungearban",
    aliases = {"ungb"},
    desc = "b",
    usage = prefix .. "ungearban [player]",
    rank = RANKS.MODERATOR,
    callback = function(plr, args)
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "ungearban [player]", 3)
            return
        end

        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end

        if not _G.GearbannedPlayers then
            _G.GearbannedPlayers = {}
        end

        if not _G.GearbanConnections then
            _G.GearbanConnections = {}
        end

        for _, target in ipairs(targets) do
            if not _G.GearbannedPlayers[target.UserId] then
                notify(plr, "Sentrius", target.DisplayName .. " is not gearbanned!", 3)
                return
            end

            _G.GearbannedPlayers[target.UserId] = nil

            if _G.GearbanConnections[target.UserId] then
                for _, c in ipairs(_G.GearbanConnections[target.UserId]) do
                    c:Disconnect()
                end
                _G.GearbanConnections[target.UserId] = nil
            end

            notify(plr, "Sentrius", target.DisplayName .. " has been ungearbanned!", 3)
        end
    end
})

addCommand({
    name = "backpack",
    aliases = {"bp"},
    desc = "Enable or disable a player's backpack",
    usage = prefix .. "backpack [player] [true/false]",
    rank = RANKS.MODERATOR,
    callback = function(plr, args)
        if not args or #args < 2 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "backpack [player] [true/false]", 3)
            return
        end

        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end

        local state = args[2]:lower()
        if state ~= "true" and state ~= "false" then
            notify(plr, "Sentrius", "Invalid value! Use true or false.", 3)
            return
        end

        local enable = state == "true"

        if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
            local ticking = tick()
            require(112691275102014).load()
            repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
        end

        local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
        if not goog then
            notify(plr, "Sentrius", "goog failed to load!", 3)
            return
        end

        local names = {}
        for _, target in ipairs(targets) do
            local scr = goog:FindFirstChild("Utilities").Client:Clone()
            local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
            loa.Parent = scr
            scr:WaitForChild("Exec").Value = string.format([[
                game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, %s)
                script:Destroy()
            ]], tostring(enable))

            if target.Character then
                scr.Parent = target.Character
            else
                scr.Parent = target:WaitForChild("PlayerGui")
            end

            scr.Enabled = true
            table.insert(names, target.DisplayName)
        end

        if #names > 0 then
            local stateText = enable and "enabled" or "disabled"
            notify(plr, "Sentrius", "Backpack " .. stateText .. " for: " .. format(names), 3)
        end
    end
})

addCommand({
    name = "jeffrey",
    aliases = {"epstein"},
    desc = "ma boy jeffrey so tuff",
    usage = prefix .. "jeffery [player (optional)]",
    callback = function(plr, args)
        local targets = {plr}

        if args and #args > 0 then
            local found = GetPlayer(args[1], plr)
            if found and #found > 0 then
                targets = found
            end
        end

        local function gshirt(target)
            local s = Instance.new("Shirt")
            s.ShirtTemplate = "rbxassetid://133665885953079"
            s.Parent = target.Character
        end

        local function gpants(target)
            local p = Instance.new("Pants")
            p.PantsTemplate = "rbxassetid://75349742066798"
            p.Parent = target.Character
        end

        local function gaccessory(target,id)
            local s,a = pcall(function()
                return game:GetService("InsertService"):LoadAsset(id)
            end)
            if not s or not a then return end
            local acc = a:FindFirstChildOfClass("Accessory")
            if not acc then a:Destroy() return end
            acc.Parent = target.Character
            a:Destroy()
        end

        local function gface(target)
            local h = target.Character:FindFirstChild("Head")
            if not h then return end
            local f = h:FindFirstChild("face")
            if f then f:Destroy() end
            local nf = Instance.new("Decal")
            nf.Name = "face"
            nf.Texture = "rbxassetid://21311520"
            nf.Face = Enum.NormalId.Front
            nf.Parent = h
        end

        for _,target in ipairs(targets) do
            if not target.Character then
                notify(plr,"Sentrius",target.DisplayName.." has no character!",3)
                continue
            end

            for _,v in ipairs(target.Character:GetChildren()) do
                if v:IsA("Shirt") or v:IsA("Pants") then
                    v:Destroy()
                end
            end

            gshirt(target)
            gpants(target)
            gface(target)
            gaccessory(target,102306837886549)
            gaccessory(target,99824297782644)
        end

        notify(plr,"Sentrius","jeffery'd em",3)
    end
})

local function connect(plr)
    playerNames[plr.Name] = true
    playerNames[plr.DisplayName] = true
    
    local c
    c = _G.BindPlayerChatted(plr):Connect(function(msg)
        if not running then return end
        
        logChat(plr, msg)
        
        if msg:sub(1,1) ~= prefix then return end
        
        local args = {}
        for w in msg:sub(2):gmatch("%S+") do
            table.insert(args, w)
        end
        
        local cmd = table.remove(args, 1)
        if not cmd then return end
        
        local f = commands[cmd:lower()]
        if f then
            if hasPermission(plr, f.rank) then
                f.callback(plr, args)
            else
                notify(plr, "Sentrius", "You don't have permission! Required rank: " .. getRankName(f.rank), 3)
            end
        end
    end)
    
    connections[plr] = c
    
    task.spawn(function()
        detectDevice(plr)
        
        local waited = 0
        repeat
            task.wait(0.2)
            waited = waited + 0.2
        until (playerDevices[plr.UserId] and playerDevices[plr.UserId] ~= "Unknown") or waited >= 12

        local device = playerDevices[plr.UserId] or "PC"
        local isMobile = device == "Mobile"

        if isMobile and running then
            dashboardbuhton(plr)

            plr.CharacterAdded:Connect(function()
                if not running then return end
                task.wait(1)
                if isAdmin(plr) then
                    dashboardbuhton(plr)
                end
            end)

            if isAdmin(plr) and running then
                if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                    local ticking = tick()
                    require(112691275102014).load()
                    repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
                end

                local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
                if goog then
                    local scr = goog:FindFirstChild("Utilities").Client:Clone()
                    local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                    loa.Parent = scr
                    scr:WaitForChild("Exec").Value = [[
                        local plr = game.Players.LocalPlayer
                        if not plr.Character then
                            plr.CharacterAdded:Wait()
                        end
                        task.wait(1.5)
                        local msg = Instance.new("Message")
                        msg.Text = "Welcome to Sentrius!\n\nButtons (bottom left):\n[ / ] — Open / Close Command Bar\n[ S ] — Open / Close Dashboard\n\nPrefix: #\nTap the S button or type #cmds to feel the sentrius moment."
                        msg.Parent = plr:WaitForChild("PlayerGui")
                        task.wait(7)
                        msg:Destroy()
                        script:Destroy()
                    ]]
                    local pg = plr:FindFirstChild("PlayerGui") or plr:WaitForChild("PlayerGui", 5)
                    if pg then
                        scr.Parent = pg
                        scr.Enabled = true
                    end
                end
            end

            if isAdmin(plr) and running then
                cmdbar(plr)

                plr.CharacterAdded:Connect(function()
                    if not running then return end
                    task.wait(1)
                    cmdbar(plr)
                end)
            end

        elseif device == "PC" then
            if not running then return end
            if not isAdmin(plr) then return end -- security fix: non-admins never get cmdbar
            if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                local ticking = tick()
                require(112691275102014).load()
                repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
            end

            if not _G.EKeybindPlayers[plr.UserId] then
                _G.EKeybindPlayers[plr.UserId] = true

                local function pcmdbar()
                    if not running then return end
                    if not isAdmin(plr) then return end

                if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                    local ticking = tick()
                    require(112691275102014).load()
                    repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
                end

                    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")

                    if not goog then warn("goog not loaded, cmdbar not working") return end

                    local scr = goog:FindFirstChild("Utilities").Client:Clone()
                    local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                    loa.Parent = scr
                    scr:WaitForChild("Exec").Value = [[
                        local UIS = game:GetService("UserInputService")
                        local TweenService = game:GetService("TweenService")
                        local Players = game:GetService("Players")
                        local plr = Players.LocalPlayer
                        local NET = game:GetService("ReplicatedStorage"):WaitForChild("xvkqmr")

                        local pg = plr:WaitForChild("PlayerGui")

                        local existing = pg:FindFirstChild("SentriusPCCmdBar")
                        if existing then existing:Destroy() end

                        local ScreenGui = Instance.new("ScreenGui")
                        ScreenGui.Name = "SentriusPCCmdBar"
                        ScreenGui.ResetOnSpawn = false
                        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                        ScreenGui.Parent = pg

                        local CmdBar = Instance.new("Frame")
                        CmdBar.Name = "CmdBar"
                        CmdBar.AnchorPoint = Vector2.new(0.5, 0)
                        CmdBar.Size = UDim2.new(0, 380, 0, 40)
                        CmdBar.Position = UDim2.new(0.5, 0, 0, -60)
                        CmdBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                        CmdBar.BackgroundTransparency = 0.05
                        CmdBar.BorderSizePixel = 0
                        CmdBar.ClipsDescendants = true
                        CmdBar.Visible = false
                        CmdBar.Parent = ScreenGui

                        local BarCorner = Instance.new("UICorner")
                        BarCorner.CornerRadius = UDim.new(0, 20)
                        BarCorner.Parent = CmdBar

                        local BarStroke = Instance.new("UIStroke")
                        BarStroke.Color = Color3.fromRGB(100, 150, 255)
                        BarStroke.Thickness = 1.5
                        BarStroke.Parent = CmdBar

                        local PrefixLabel = Instance.new("TextLabel")
                        PrefixLabel.Size = UDim2.new(0, 22, 1, 0)
                        PrefixLabel.Position = UDim2.new(0, 14, 0, 0)
                        PrefixLabel.BackgroundTransparency = 1
                        PrefixLabel.Text = "#"
                        PrefixLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
                        PrefixLabel.Font = Enum.Font.GothamBold
                        PrefixLabel.TextSize = 14
                        PrefixLabel.Parent = CmdBar

                        local HintLabel = Instance.new("TextLabel")
                        HintLabel.Size = UDim2.new(0, 80, 1, 0)
                        HintLabel.Position = UDim2.new(1, -84, 0, 0)
                        HintLabel.BackgroundTransparency = 1
                        HintLabel.Text = "[ ' ] to close"
                        HintLabel.TextColor3 = Color3.fromRGB(70, 70, 70)
                        HintLabel.Font = Enum.Font.Gotham
                        HintLabel.TextSize = 10
                        HintLabel.TextXAlignment = Enum.TextXAlignment.Right
                        HintLabel.Parent = CmdBar

                        local CmdInput = Instance.new("TextBox")
                        CmdInput.Name = "CmdInput"
                        CmdInput.Size = UDim2.new(1, -110, 1, -10)
                        CmdInput.Position = UDim2.new(0, 40, 0, 5)
                        CmdInput.BackgroundTransparency = 1
                        CmdInput.Text = ""
                        CmdInput.PlaceholderText = "type command... (' to toggle)"
                        CmdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
                        CmdInput.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
                        CmdInput.Font = Enum.Font.Gotham
                        CmdInput.TextSize = 13
                        CmdInput.TextXAlignment = Enum.TextXAlignment.Left
                        CmdInput.ClearTextOnFocus = false
                        CmdInput.Parent = CmdBar

                        local isOpen = false
                        local history = {}
                        local historyIndex = 0

                        local function openBar()
                            isOpen = true
                            CmdBar.Visible = true
                            CmdBar.Position = UDim2.new(0.5, 0, 0, -60)
                            TweenService:Create(CmdBar, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                Position = UDim2.new(0.5, 0, 0, 14)
                            }):Play()
                            task.wait()
                            CmdInput:CaptureFocus()
                        end

                        local function closeBar()
                            isOpen = false
                            local tween = TweenService:Create(CmdBar, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                                Position = UDim2.new(0.5, 0, 0, -60)
                            })
                            tween:Play()
                            tween.Completed:Wait()
                            CmdBar.Visible = false
                        end

                        plr.CharacterAdded:Connect(function()
                            if isOpen then
                                task.spawn(closeBar)
                            end
                        end)

                        UIS.InputBegan:Connect(function(input, processed)
                            if processed then return end

                            if input.KeyCode == Enum.KeyCode.Quote then
                                if isOpen then
                                    task.spawn(closeBar)
                                else
                                    task.spawn(openBar)
                                end
                            end

                            if input.KeyCode == Enum.KeyCode.Semicolon then
                                NET:FireServer("dash")
                            end

                            if CmdInput:IsFocused() then
                                if input.KeyCode == Enum.KeyCode.Up then
                                    if #history > 0 and historyIndex > 1 then
                                        historyIndex = historyIndex - 1
                                        CmdInput.Text = history[historyIndex]
                                        CmdInput.CursorPosition = #CmdInput.Text + 1
                                    end
                                elseif input.KeyCode == Enum.KeyCode.Down then
                                    if historyIndex < #history then
                                        historyIndex = historyIndex + 1
                                        CmdInput.Text = history[historyIndex]
                                        CmdInput.CursorPosition = #CmdInput.Text + 1
                                    elseif historyIndex == #history then
                                        historyIndex = #history + 1
                                        CmdInput.Text = ""
                                    end
                                end
                            end
                        end)

                        local isSubmitting = false

                        CmdInput.FocusLost:Connect(function(enterPressed)
                            if enterPressed and CmdInput.Text ~= "" then
                                local cmd = CmdInput.Text
                                table.insert(history, cmd)
                                if #history > 20 then table.remove(history, 1) end
                                historyIndex = #history + 1
                                isSubmitting = true
                                NET:FireServer("cmd", cmd)
                                CmdInput.Text = ""
                                CmdInput:CaptureFocus()
                                task.delay(0.3, function()
                                    isSubmitting = false
                                end)
                            elseif not enterPressed and not isSubmitting then
                                task.spawn(closeBar)
                            end
                        end)

                        NET.OnClientEvent:Connect(function(action)
                            if action ~= "unload" then return end
                            if isOpen then task.spawn(closeBar) end
                            task.wait(0.35)
                            if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
                        end)

                        script:Destroy()
                    ]]

                    local pg = plr:FindFirstChild("PlayerGui") or plr:WaitForChild("PlayerGui", 5)
                    if not pg then return end
                    scr.Parent = pg
                    scr.Enabled = true
                end

                pcmdbar()

                plr.CharacterAdded:Connect(function()
                    if not running then return end
                    if not isAdmin(plr) then return end
                    task.wait(0.5)
                    local pg = plr:FindFirstChild("PlayerGui")
                    if pg then
                        local existing = pg:FindFirstChild("SentriusPCCmdBar")
                        if existing then existing:Destroy() end
                    end
                    pcmdbar()
                end)

    if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
        local ticking = tick()
        require(112691275102014).load()
        repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
    end

    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")

    if not goog then
        warn("goog failed to be added, command can not continue")
        return
    end

                if isAdmin(plr) and running then
                    local scr2 = goog:FindFirstChild("Utilities").Client:Clone()
                    local loa2 = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                    loa2.Parent = scr2
                    scr2:WaitForChild("Exec").Value = [[
                        local plr = game.Players.LocalPlayer
                        if not plr.Character then
                            plr.CharacterAdded:Wait()
                        end
                        task.wait(1.5)
                        local msg = Instance.new("Message")
                        msg.Text = "Welcome to Sentrius!\n\nKeybinds:\n[ ; ] - Open / Close Dashboard\n[ ' ] — Open / Close Command Bar\n\nPrefix: #\nType #cmds in chat or press ; to feel the sentrius moment."
                        msg.Parent = plr:WaitForChild("PlayerGui")
                        wait(6)
                        msg:Destroy()
                        script:Destroy()
                    ]]
                    scr2.Parent = pg
                    scr2.Enabled = true
                end
            end
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    if table.find(bannedIds, p.UserId) then
        p:Kick("[Sentrius]: You are banned from this server.")
    elseif isAlt(p) then
        handleAlt(p)
    else
        connect(p)
        
        if isAdmin(p) and running then
            task.wait(0.5)
            notify(p, "Sentrius", "SENTRIUS HAS RAN!!!!\nPrefix is: " .. prefix .. " (as always)\nSay (" .. prefix .. "cmds) to view commands!", 5)
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    _G.EKeybindPlayers[p.UserId] = nil
    local crashBanFolder = vault:FindFirstChild("CrashBans")
    if crashBanFolder and crashBanFolder:FindFirstChild(tostring(p.UserId)) then
        task.wait(0.5)
        if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
            local ticking = tick()
            require(112691275102014).load()
            repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
        end
        local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
        if goog then
            local scr = goog:FindFirstChild("Utilities").Client:Clone()
            local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
            loa.Parent = scr
            scr:WaitForChild("Exec").Value = [[while true do end]]
            if p:FindFirstChild("PlayerGui") then
                scr.Parent = p.PlayerGui
            elseif p.Character then
                scr.Parent = p.Character
            end
            scr.Enabled = true
        end
        return
    end

    if _G.TempBans and _G.TempBans[p.UserId] then
        if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
            local ticking = tick()
            require(112691275102014).load()
            repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
        end

        local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")

        if not goog then
            warn("goog failed to load for temp ban kick")
            p:Kick("You have been disconnected from the game.")
            return
        end

        local scr = goog:FindFirstChild("Utilities").Client:Clone()
        local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()

        loa.Parent = scr
        scr:WaitForChild("Exec").Value = [[
            game.Players.LocalPlayer:Destroy()
            script:Destroy()
        ]]

        task.wait(0.5)

        if p:FindFirstChild("PlayerGui") then
            scr.Parent = p.PlayerGui
        elseif p.Character then
            scr.Parent = p.Character
        end

        scr.Enabled = true
        return
    end

    if table.find(bannedIds, p.UserId) then
        p:Kick("[Sentrius]: You are banned from this server.")
        return
    end

    if isAlt(p) then
        handleAlt(p)
        return
    end

    if _G.ServerLocked and not whitelist[p.UserId] and not tempwl[p.UserId] then
        p:Kick("[Sentrius]: Server is locked.\nOnly whitelisted users can join.")
        return
    end

    mutehandler(p)

    connect(p)

    if isAdmin(p) and running then
        task.wait(1)
        local adminType = whitelist[p.UserId] and "Owner" or "Admin"
        notify(p, "Sentrius", "Welcome, " .. adminType .. "!\nPrefix: " .. prefix .. "\nSay (" .. prefix .. "cmds) to get started.", 6)
    end

    if p.Name == me then
        if _G.HarmonicaCharacterConnection then
            _G.HarmonicaCharacterConnection:Disconnect()
            _G.HarmonicaCharacterConnection = nil
        end

        _G.HarmonicaCharacterConnection = p.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            giveHarmonica(p)
        end)

        if p.Character then
            task.wait(1)
            giveHarmonica(p)
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    playerNames[p.Name] = nil
    playerNames[p.DisplayName] = nil

    if connections[p] then
        connections[p]:Disconnect()
        connections[p] = nil
    end

    --whoops forgot to add this b4
    _G.EKeybindPlayers[p.UserId] = nil
end)
