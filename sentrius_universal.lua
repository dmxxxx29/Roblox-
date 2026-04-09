--!strict
--!optimize 2
--!native

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local prefix: string = "-"

--local whitelistUrl: string = "https://raw.githubusercontent.com/dmxxxx29"

local backup: {number} = {
	--tech
	1702851506,
	--me
	3421321085,
	7809114960
}

local whitelist: {number} = {}
local banned: {[number]: string} = {}
local plrCache: {[number]: {name: string, display: string}} = {}

for _, plr: Player in ipairs(Players:GetPlayers()) do
	plrCache[plr.UserId] = {
		name = plr.Name,
		display = plr.DisplayName
	}
end

local function notify(text: string): ()
	pcall(function(): ()
		StarterGui:SetCore("SendNotification", {
			Title = "Admin",
			Text = text,
			Duration = 4
		})
	end)
end

local function fetchwls(): ()
	local ok: boolean, res: string = pcall(function(): string
		return HttpService:GetAsync(whitelistUrl)
	end)

	if ok then
		local decoded: any

		pcall(function(): ()
			decoded = HttpService:JSONDecode(res)
		end)

		if typeof(decoded) == "table" then
			whitelist = decoded :: {number}
			return
		end
	end

	whitelist = backup
end

fetchwls()

local function isWled(plr: Player): boolean
	return table.find(whitelist, plr.UserId) ~= nil
end

function getTarget(str: string, speaker: Player): {Player}
	local found: {Player} = {}
	local targ: string = tostring(str):lower()

	if targ:find(",") then
		local parts: {string} = {}

		for part: string in targ:gmatch("[^,]+") do
			part = part:match("^%s*(.-)%s*$") :: string
			if part ~= "" then
				table.insert(parts, part)
			end
		end

		if #parts == 1 then
			return getTarget(parts[1], speaker)
		end

		local seen: {[number]: boolean} = {}

		for _, part: string in ipairs(parts) do
			for _, plr: Player in ipairs(getTarget(part, speaker)) do
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
		for _, p: Player in ipairs(Players:GetPlayers()) do
			if p ~= speaker then
				table.insert(found, p)
			end
		end
		return found
	elseif targ == "random" then
		local list: {Player} = Players:GetPlayers()
		if #list > 0 then
			return {list[math.random(1, #list)]}
		end
		return {}
	end

	local exact: {Player} = {}
	local partial: {Player} = {}

	for _, plr: Player in ipairs(Players:GetPlayers()) do
		local name: string = plr.Name:lower()
		local display: string = plr.DisplayName:lower()

		if name == targ or display == targ then
			table.insert(exact, plr)
		elseif name:sub(1, #targ) == targ or display:sub(1, #targ) == targ then
			table.insert(partial, plr)
		end
	end

	if #exact > 0 then
		return exact
	end

	if #partial > 0 then
		return partial
	end

	if #targ >= 3 then
		for _, plr: Player in ipairs(Players:GetPlayers()) do
			local name: string = plr.Name:lower()
			local display: string = plr.DisplayName:lower()

			if name:find(targ, 1, true) or display:find(targ, 1, true) then
				table.insert(found, plr)
			end
		end
	end

	return found
end

type Command = {
	desc: string,
	callback: (Player, {string}) -> ()
}

local commands: {[string]: Command} = {}

local function addcmd(
	name: string,
	desc: string,
	aliases: {string}?,
	callback: (Player, {string}) -> ()
): ()
	local cmd: Command = {
		desc = desc,
		callback = callback
	}

	commands[name:lower()] = cmd

	if aliases then
		for _, a: string in ipairs(aliases) do
			commands[a:lower()] = cmd
		end
	end
end

local function runCmd(plr: Player, msg: string): ()
	if not isWled(plr) then return end
	if msg:sub(1, #prefix) ~= prefix then return end

	local args: {string} = {}

	for w: string in msg:gmatch("%S+") do
		table.insert(args, w)
	end

	local cmdName: string = args[1]:sub(#prefix + 1):lower()
	table.remove(args, 1)

	local cmd: Command? = commands[cmdName]
	if not cmd then return end

	pcall(function(): ()
		cmd.callback(plr, args)
	end)
end

addcmd("kick", "kicks a player", {"k"}, function(plr: Player, args: {string}): ()
	local reason: string = args[2] and table.concat(args, " ", 2) or "Kicked by admin"
	for _, t: Player in ipairs(getTarget(args[1] or "", plr)) do
		t:Kick(reason)
	end
end)

addcmd("respawn", "respawns player", {"re"}, function(plr: Player, args: {string}): ()
	for _, t: Player in ipairs(getTarget(args[1] or "", plr)) do
		t:LoadCharacter()
	end
end)

addcmd("speed", "sets walkspeed", {"ws"}, function(plr: Player, args: {string}): ()
	local num: number = tonumber(args[2]) or 16
	for _, t: Player in ipairs(getTarget(args[1] or "", plr)) do
		local hum: Humanoid? = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = num
		end
	end
end)

addcmd("jump", "sets jumppower", {"jp"}, function(plr: Player, args: {string}): ()
	local num: number = tonumber(args[2]) or 50
	for _, t: Player in ipairs(getTarget(args[1] or "", plr)) do
		local hum: Humanoid? = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.JumpPower = num
		end
	end
end)

addcmd("ban", "serverbans a player", {"b"}, function(plr: Player, args: {string}): ()
	local reason: string = args[2] and table.concat(args, " ", 2) or "No reason provided"
	for _, t: Player in ipairs(getTarget(args[1] or "", plr)) do
		if isWled(t) then
			notify(t.Name.." is whitelisted, you cannot ban them.")
			continue
		end
		banned[t.UserId] = reason
		t:Kick("You have been banned.\nReason: "..reason)
		notify("Banned "..t.Name.." | "..reason)
	end
end)

addcmd("unban", "unbans a player", {}, function(plr: Player, args: {string}): ()
	local query: string = (args[1] or ""):lower()

	for uid: number, data: {name: string, display: string} in pairs(plrCache) do
		if data.name:lower() == query or data.display:lower() == query
			or data.name:lower():find(query, 1, true)
			or data.display:lower():find(query, 1, true) then
			if banned[uid] then
				banned[uid] = nil
				notify("Unbanned "..data.name.." ("..uid..")")
				return
			end
		end
	end

	local uid: number? = tonumber(query)
	if not uid then
 	   notify("No player found or player is not banned.")
	    return
	end
	if not banned[uid] then
 	   notify("UserId "..uid.." is not banned.")
   	 return
	end
	banned[uid] = nil
	notify("Unbanned UserId: "..uid)
end)

addcmd("taskbar", "loads taskbar then rejoin", {"tb"}, function(plr: Player, args: {string}): ()
	require(132159594800467)
	task.wait(0.15)
	local TeleportService = game:GetService("TeleportService")
	TeleportService:Teleport(game.PlaceId, plr)
end)

addcmd("rejoin", "rejoin the server", {"rj"}, function(plr: Player, args: {string}): ()
	local TeleportService = game:GetService("TeleportService")
	local targets: {Player} = #(args[1] or "") > 0 and getTarget(args[1], plr) or {plr}
	for _, t: Player in ipairs(targets) do
		TeleportService:Teleport(game.PlaceId, t)
	end
end)

Players.PlayerAdded:Connect(function(plr: Player): ()
	plrCache[plr.UserId] = {
		name = plr.Name,
		display = plr.DisplayName
	}

	local reason: string? = banned[plr.UserId]
	if reason then
		plr:Kick("You are banned.\nReason: "..reason)
		return
	end

	plr.Chatted:Connect(function(msg: string): ()
		runCmd(plr, msg)
	end)
end)

if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
	TextChatService.OnIncomingMessage = function(message: TextChatMessage): TextChatMessage?
		local src = message.TextSource
		if not src then return message end

		local plr: Player? = Players:GetPlayerByUserId(src.UserId)
		if plr then
			runCmd(plr, message.Text)
		end

		return message
	end
end

notify("admin loaded")
