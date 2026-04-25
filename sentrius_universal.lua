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

local whitelistUrl = "https://raw.githubusercontent.com/dmxxxx29/Roblox-/main/whitelist.json"

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
			print("whitelist updated from github")
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

local function addcmd(name, desc, aliases, callback)
	local cmd = {
		desc = desc,
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
	if not isWled(plr) then return end
	if msg:sub(1, #prefix) ~= prefix then return end

	local args = {}

	for w in msg:gmatch("%S+") do
		table.insert(args, w)
	end

	local cmdName = args[1]:sub(#prefix + 1):lower()
	table.remove(args, 1)

	local cmd = commands[cmdName]
	if not cmd then return end

	pcall(function()
		cmd.callback(plr, args)
	end)
end

addcmd("kick", "kicks a player", {"k"}, function(plr, args)
	local reason = args[2] and table.concat(args, " ", 2) or "Kicked by admin"
	for _, t in ipairs(getTarget(args[1] or "", plr)) do
		t:Kick(reason)
	end
end)

addcmd("respawn", "respawns player", {"re"}, function(plr, args)
	for _, t in ipairs(getTarget(args[1] or "", plr)) do
		t:LoadCharacter()
	end
end)

addcmd("speed", "sets walkspeed", {"ws"}, function(plr, args)
	local num = tonumber(args[2]) or 16
	for _, t in ipairs(getTarget(args[1] or "", plr)) do
		local hum = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = num
		end
	end
end)

addcmd("jump", "sets jumppower", {"jp"}, function(plr, args)
	local num = tonumber(args[2]) or 50
	for _, t in ipairs(getTarget(args[1] or "", plr)) do
		local hum = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.JumpPower = num
		end
	end
end)

addcmd("ban", "serverbans a player", {"b"}, function(plr, args)
	local reason = args[2] and table.concat(args, " ", 2) or "No reason provided"
	for _, t in ipairs(getTarget(args[1] or "", plr)) do
		if isWled(t) then
			notify(t.Name .. " is whitelisted, you cannot ban them.")
		else
			banned[t.UserId] = reason
			t:Kick("You have been banned.\nReason: " .. reason)
			notify("Banned " .. t.Name .. " | " .. reason)
		end
	end
end)

addcmd("unban", "unbans a player", {}, function(plr, args)
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

addcmd("taskbar", "loads taskbar", {"tb"}, function(plr, args)
	require(132159594800467)
	task.wait(0.15)
	local TeleportService = game:GetService("TeleportService")
	local placeId = game.PlaceId
	local jobId = game.JobId
	TeleportService:TeleportToPlaceInstance(placeId, jobId, plr)
end)

addcmd("rejoin", "rejoin the server", {"rj"}, function(plr, args)
	local TeleportService = game:GetService("TeleportService")
	local placeId = game.PlaceId
	local jobId = game.JobId
	local targets = (args[1] and #args[1] > 0) and getTarget(args[1], plr) or {plr}
	for _, t in ipairs(targets) do
		TeleportService:TeleportToPlaceInstance(placeId, jobId, t)
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

notify("admin loaded")
