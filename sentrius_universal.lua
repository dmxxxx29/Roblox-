local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")

local prefix = "-"

local backup = {
	{ id = 1702851506, tag = "tech" },
	{ id = 3421321085, tag = "me" },
	{ id = 7809114960, tag = "alt" }
}

local whitelist = backup
local banned = {}
local plrCache = {}

for _, plr in ipairs(Players:GetPlayers()) do
	plrCache[plr.UserId] = {
		name = plr.Name,
		display = plr.DisplayName
	}
end

local function notify(text)
	print(text)
end

local versionUrl = "https://raw.githubusercontent.com/dmxxxx29/Roblox-/main/sentrius_universal_version.txt"
local whitelistUrl = "https://raw.githubusercontent.com/dmxxxx29/Roblox-/main/whitelist.json" --if you're seeing this ask tech for whitelist although it's up to me but still ask tech for whitelist

--maybe i will make a temporary whitelist but i dont think i will
--highly depends on time and future same with updates and thoughts

local function fetchwls()
	local ok, res = pcall(function()
		return HttpService:GetAsync(whitelistUrl, true)
	end)

	if not ok then
		warn("couldn't fetch whitelist, using backup")
		whitelist = backup
		return
	end

	local success, decoded = pcall(function()
		return HttpService:JSONDecode(res)
	end)

	if success and type(decoded) == "table" then
		local valid = true

		for _, v in ipairs(decoded) do
			if type(v) ~= "table" or type(v.id) ~= "number" then
				valid = false
				break
			end
		end

		if valid then
			whitelist = decoded
			return
		end
	end

	warn("whitelist didn't load properly, using backup")
	whitelist = backup
end

fetchwls()

local function isWled(plr)
	local uid = plr.UserId

	for _, data in ipairs(whitelist) do
		if type(data) == "table" then
			if data.id == uid then
				return true, data.tag
			end
		end
	end

	return false
end

local function hasTag(tag, required)
	local roles = {}
	for role in tag:gmatch("%S+") do
		roles[role] = true
	end

	if type(required) == "table" then
		for _, entry in ipairs(required) do
			if tag == entry then
				return true
			end
		end
		return false
	end

	if required:find(",") then
		for req in required:gmatch("[^,]+") do
			req = req:match("^%s*(.-)%s*$")
			if not roles[req] then
				return false
			end
		end
		return true
	end

	for req in required:gmatch("%S+") do
		if roles[req] then
			return true
		end
	end

	return false
end

local function getTarget(str, speaker)
	local found = {}
	local targ = tostring(str):lower()

	if targ:find(",") then
		local parts = {}

		for part in targ:gmatch("[^,]+") do
			part = part:match("^%s*(.-)%s*$")
			if part ~= "" then
				table.insert(parts, part)
			end
		end

		if #parts == 1 then
			return getTarget(parts[1], speaker)
		end

		local seen = {}

		for _, part in ipairs(parts) do
			for _, plr in ipairs(getTarget(part, speaker)) do
				if not seen[plr.UserId] then
					seen[plr.UserId] = true
					table.insert(found, plr)
				end
			end
		end

		return found
	end

	if targ == "me" then
		return {speaker}
	elseif targ == "all" then
		return Players:GetPlayers()
	elseif targ == "others" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= speaker then
				table.insert(found, p)
			end
		end
		return found
	elseif targ == "random" then
		local list = Players:GetPlayers()
		if #list > 0 then
			return {list[math.random(1, #list)]}
		end
		return {}
	end

	local exact = {}
	local partial = {}

	for _, plr in ipairs(Players:GetPlayers()) do
		local name = plr.Name:lower()
		local display = plr.DisplayName:lower()

		if name == targ or display == targ then
			table.insert(exact, plr)
		elseif name:sub(1, #targ) == targ or display:sub(1, #targ) == targ then
			table.insert(partial, plr)
		end
	end

	if #exact > 0 then return exact end
	if #partial > 0 then return partial end

	if #targ >= 3 then
		for _, plr in ipairs(Players:GetPlayers()) do
			local name = plr.Name:lower()
			local display = plr.DisplayName:lower()

			if name:find(targ, 1, true) or display:find(targ, 1, true) then
				table.insert(found, plr)
			end
		end
	end

	return found
end

local commands = {}

local function addcmd(name, desc, aliases, tag, callback)
	local cmd = {
		desc = desc,
		tag = tag,
		callback = callback
	}

	commands[name:lower()] = cmd

	if aliases then
		for _, a in ipairs(aliases) do
			commands[a:lower()] = cmd
		end
	end
end

local function runCmd(plr, msg)
	local wled, tag = isWled(plr)
	if not wled then return end
	if msg:sub(1, #prefix) ~= prefix then return end

	local args = {}

	for w in msg:gmatch("%S+") do
		table.insert(args, w)
	end

	local cmdName = args[1]:sub(#prefix + 1):lower()
	table.remove(args, 1)

	local cmd = commands[cmdName]
	if not cmd then return end

	if cmd.tag and not hasTag(tag, cmd.tag) then return end

	pcall(function()
		cmd.callback(plr, args)
	end)
end

addcmd("kick", "kicks a playuh", {}, {"tech", "tech alt", "me", "me alt", "Palamode", "ROBLOXIanGuy", "ROBLOXIanGuy alt"}, function(plr, args)
	if not args[1] or args[1] == "" then
		notify("kick: specify a target")
		return
	end
	local reason = args[2] and table.concat(args, " ", 2) or "Kicked by admin"
	for _, t in ipairs(getTarget(args[1], plr)) do
		t:Kick(reason)
	end
end)

addcmd("respawn", "respawns a playuh", {"res"}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	for _, t in ipairs(targets) do
		t:LoadCharacter()
	end
end)

addcmd("speed", "sets walkspeed", {"ws"}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	local num = tonumber(args[2]) or 16
	for _, t in ipairs(targets) do
		local hum = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = num
		end
	end
end)

addcmd("jumppower", "sets jumppower", {"jp"}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	local num = tonumber(args[2]) or 50
	for _, t in ipairs(targets) do
		local hum = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.JumpPower = num
		end
	end
end)

addcmd("ban", "serverbans a playuh", {}, {"tech", "tech alt", "me", "me alt", "Palamode", "ROBLOXIanGuy", "ROBLOXIanGuy alt"}, function(plr, args)
	if not args[1] or args[1] == "" then
		notify("ban: specify a target")
		return
	end
	local reason = args[2] and table.concat(args, " ", 2) or "No reason provided"
	for _, t in ipairs(getTarget(args[1], plr)) do
		if isWled(t) then
			notify(t.Name .. " is whitelisted, you cannot ban them.")
		else
			banned[t.UserId] = reason
			t:Kick("You have been banned.\nReason: " .. reason)
			notify("Banned " .. t.Name .. " | " .. reason)
		end
	end
end)

addcmd("unban", "unbans a playuh", {}, {"tech", "tech alt", "me", "me alt", "Palamode", "ROBLOXIanGuy", "ROBLOXIanGuy alt"}, function(plr, args)
	local query = (args[1] or ""):lower()

	for uid, data in pairs(plrCache) do
		if data.name:lower() == query or data.display:lower() == query
			or data.name:lower():find(query, 1, true)
			or data.display:lower():find(query, 1, true) then
			if banned[uid] then
				banned[uid] = nil
				notify("Unbanned " .. data.name .. " (" .. uid .. ")")
				return
			end
		end
	end

	local uid = tonumber(query)
	if not uid then
		notify("No player found or player is not banned.")
		return
	end
	if not banned[uid] then
		notify("UserId " .. uid .. " is not banned.")
		return
	end
	banned[uid] = nil
	notify("Unbanned UserId: " .. uid)
end)

addcmd("taskbar", "loads taskbar", {"tb"}, {"tech", "tech alt", "me", "me alt", "Palamode", "ROBLOXIanGuy", "ROBLOXIanGuy alt"}, function(plr, args) --maybe in future, people will essentially get whitelisted after all
	require(132159594800467)
	task.wait(0.15)
	local TeleportService = game:GetService("TeleportService")
	local placeId = game.PlaceId
	local jobId = game.JobId
	TeleportService:TeleportToPlaceInstance(placeId, jobId, plr)
end)

addcmd("rejoin", "rejoin the serveh", {"rj"}, nil, function(plr, args)
	local TeleportService = game:GetService("TeleportService")
	local placeId = game.PlaceId
	local jobId = game.JobId
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	for _, t in ipairs(targets) do
		TeleportService:TeleportToPlaceInstance(placeId, jobId, t)
	end
end)

addcmd("kill", "kills a playuh", {}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	for _, t in ipairs(targets) do
		local hum = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Health = 0
		end
	end
end)

addcmd("fling", "flings a playuh", {}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	for _, t in ipairs(targets) do
		local char = t.Character
		if not char then continue end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then continue end

		hum.Sit = true

		local bv = Instance.new("BodyVelocity")
		bv.Velocity = Vector3.new(math.random(-1, 1) * 500, 800, math.random(-1, 1) * 500)
		bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		bv.Parent = hrp

		game:GetService("Debris"):AddItem(bv, 0.15)
	end
end)

addcmd("invisible", "makes a playuh invisible", {"invis"}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	for _, t in ipairs(targets) do
		local char = t.Character
		if not char then continue end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.Transparency = 1
			elseif part:IsA("Decal") then
				part.Transparency = 1
			end
		end
	end
end)

addcmd("visible", "makes a playuh visible", {"vis"}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	for _, t in ipairs(targets) do
		local char = t.Character
		if not char then continue end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.Transparency = 0
			elseif part:IsA("Decal") then
				part.Transparency = 0
			end
		end
	end
end)

addcmd("gear", "gives gear to a playuh by id or name", {"fgear"}, nil, function(plr, args)
	if not args or #args == 0 then
		notify("gear: no arguments provided")
		return
	end

	local InsertService = game:GetService("InsertService")
	local targets = getTarget(args[1] or "", plr)
	local gearArg

	if #targets > 0 and #args >= 2 then
		gearArg = table.concat(args, " ", 2)
	else
		targets = {plr}
		gearArg = table.concat(args, " ", 1)
	end

	local gearId = tonumber(gearArg)

	if not gearId then
		local encoded = HttpService:UrlEncode(gearArg)
		local url = "https://catalog.roproxy.com/v1/search/items?category=Accessories&includeNotForSale=true&limit=10&salesTypeFilter=1&subcategory=Gear&Keyword=" .. encoded

		local ok, res = pcall(function()
			return HttpService:GetAsync(url)
		end)

		if not ok or not res then
			notify("gear: failed to fetch roblox catalog")
			return
		end

		local success, data = pcall(function()
			return HttpService:JSONDecode(res)
		end)

		if not success or not data or not data.data or #data.data == 0 then
			notify("gear: no results for '" .. gearArg .. "'")
			return
		end

		gearId = data.data[1].id
		notify("gear: found '" .. (data.data[1].name or "?") .. "' (id: " .. gearId .. ")")
	end

	local ok, asset = pcall(function()
		return InsertService:LoadAsset(gearId)
	end)

	if not ok or not asset then
		notify("gear: failed to load asset id " .. tostring(gearId))
		return
	end

	local tool = asset:FindFirstChildOfClass("Tool")
	if not tool then
		asset:Destroy()
		notify("gear: asset is not a valid tool/gear")
		return
	end

	for _, t in ipairs(targets) do
		if t:FindFirstChild("Backpack") then
			tool:Clone().Parent = t.Backpack
		end
	end

	asset:Destroy()
end)

addcmd("health", "sets a playuh's health", {"hp"}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	local num = tonumber(args[2]) or 100
	for _, t in ipairs(targets) do
		local hum = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.MaxHealth = num
			hum.Health = num
		end
	end
end)

addcmd("damage", "damages a playuh", {"dmg"}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	local num = tonumber(args[2]) or 10
	for _, t in ipairs(targets) do
		local hum = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Health = math.max(0, hum.Health - num) -- fun fact: damage uses math.max(0, ...) so it bottoms out at 0 instead of going negative which can cause weird behavior in some games!
		end
	end
end)

addcmd("sit", "forces a playuh to sit", {}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	for _, t in ipairs(targets) do
		local hum = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Sit = true
		end
	end
end)

addcmd("freeze", "freezes a playuh", {}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	for _, t in ipairs(targets) do
		if not t.Character then continue end
		for _, part in ipairs(t.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end
	end
end)

addcmd("unfreeze", "unfreezes a playuh", {}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	for _, t in ipairs(targets) do
		if not t.Character then continue end
		for _, part in ipairs(t.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = false
			end
		end
	end
end)

addcmd("god", "gives a playuh infinite health", {}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	for _, t in ipairs(targets) do
		local hum = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.MaxHealth = math.huge
			hum.Health = math.huge
		end
	end
end)

addcmd("ungod", "removes god mode from a playuh", {}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	for _, t in ipairs(targets) do
		local hum = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.MaxHealth = 100
			hum.Health = 100
		end
	end
end)

addcmd("size", "resizes a playuh's charactuh", {}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	local num = tonumber(args[2]) or 1

	for _, t in ipairs(targets) do
		local char = t.Character
		if not char then continue end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then continue end

		if hum.RigType == Enum.HumanoidRigType.R15 then
			local desc = hum:GetAppliedDescription()
			desc.HeadScale = num
			desc.BodyDepthScale = num
			desc.BodyHeightScale = num
			desc.BodyWidthScale = num
			desc.LegHeightScale = num
			desc.LegWidthScale = num
			desc.UpperBodyDepthScale = num
			desc.UpperBodyHeightScale = num
			desc.UpperBodyWidthScale = num
			desc.LowerBodyDepthScale = num
			desc.LowerBodyHeightScale = num
			desc.LowerBodyWidthScale = num
			hum:ApplyDescription(desc)
		else
			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.Size = part.Size * num
					for _, weld in ipairs(part:GetChildren()) do
						if weld:IsA("Motor6D") then
							weld.C0 = weld.C0 + Vector3.new(0, (num - 1) * 0.5, 0)
						end
					end
				end
			end
		end
	end
end)

addcmd("char", "loads a charactuh appearance by userid or username", {}, nil, function(plr, args)
	if not args[1] or args[1] == "" then
		notify("char: no args provided")
		return
	end

	local target
	local argument

	if args[2] and args[2] ~= "" then
		target = getTarget(args[1], plr)
		if #target == 0 then
			notify("char: couldn't find target player")
			return
		end
		argument = args[2]
	else
		target = {plr}
		argument = args[1]
	end

	local userId = tonumber(argument)

	if not userId then
		local ok, result = pcall(function()
			return Players:GetUserIdFromNameAsync(argument)
		end)
		if not ok or not result then
			notify("char: couldn't find user '" .. argument .. "'")
			return
		end
		userId = result
	end

	local ok, desc = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(userId)
	end)

	if not ok or not desc then
		notify("char: failed to fetch appearance for " .. tostring(userId))
		return
	end

	for _, t in ipairs(target) do
		local hum = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			pcall(function()
				hum:ApplyDescription(desc)
			end)
		end
	end
end)

addcmd("bring", "brings a playuh to you", {}, nil, function(plr, args)
	if not args[1] or args[1] == "" then
		notify("bring: specify a target")
		return
	end
	local myChar = plr.Character
	if not myChar then return end
	local myHrp = myChar:FindFirstChild("HumanoidRootPart")
	if not myHrp then return end

	for _, t in ipairs(getTarget(args[1], plr)) do
		if t == plr then continue end
		local char = t.Character
		if not char then continue end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = myHrp.CFrame + myHrp.CFrame.LookVector * 3
		end
	end
end)

addcmd("goto", "teleports you to a playuh", {"to"}, nil, function(plr, args)
	if not args[1] or args[1] == "" then
		notify("goto: specify a target")
		return
	end
	local myChar = plr.Character
	if not myChar then return end
	local myHrp = myChar:FindFirstChild("HumanoidRootPart")
	if not myHrp then return end

	local targets = getTarget(args[1], plr)
	if #targets == 0 then
		notify("goto: player not found")
		return
	end

	local t = targets[1]
	local char = t.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		myHrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 3
	end
end)

addcmd("reset", "reset player charactuh", {"re"}, nil, function(plr, args)
	local targets = (args[1] and args[1] ~= "") and getTarget(args[1], plr) or {plr}
	for _, t in ipairs(targets) do
		if t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
			local pos = t.Character.HumanoidRootPart.CFrame
			t:LoadCharacter()
			if t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
				t.Character.HumanoidRootPart.CFrame = pos
			end
		else
			t:LoadCharacter()
		end
	end
end)

local isNewChat = TextChatService.ChatVersion == Enum.ChatVersion.TextChatService

local function bindChat(plr)
	if isNewChat then return end

	if game.PlaceId == 14747334292 then
		_G.BindPlayerChatted(plr):Connect(function(msg)
			runCmd(plr, msg)
		end)
	else
		plr.Chatted:Connect(function(msg)
			runCmd(plr, msg)
		end)
	end
end

Players.PlayerAdded:Connect(function(plr)
	plrCache[plr.UserId] = {
		name = plr.Name,
		display = plr.DisplayName
	}

	if banned[plr.UserId] then
		plr:Kick("You are banned.\nReason: " .. banned[plr.UserId])
		return
	end

	bindChat(plr)
end)

for _, plr in ipairs(Players:GetPlayers()) do
	bindChat(plr)
end

if isNewChat then
	TextChatService.OnIncomingMessage = function(message)
		local src = message.TextSource
		if not src then return end

		local plr = Players:GetPlayerByUserId(src.UserId)
		if plr then
			runCmd(plr, message.Text)
		end
	end
end

task.spawn(function()
	while true do
		fetchwls()
		task.wait(60)
	end
end)

local success, response = pcall(function()
	return HttpService:GetAsync(versionUrl)
end)

if success then
	notify("Universal Version (UV): " .. response)
else
	notify("Failed to fetch version")
end
