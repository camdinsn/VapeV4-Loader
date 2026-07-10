local Bomboclat
local rayCheck = RaycastParams.new()
rayCheck.RespectCanCollide = true

local projectileRemote = {InvokeServer = function() end}
task.spawn(function()
	projectileRemote = bedwars.Client:Get(remotes.FireProjectile).instance
end)

local function firePearl(pos, dir, item)
	switchItem(item.tool)

	local threwPearl = projectileRemote:InvokeServer(
		item.tool,
		'telepearl',
		'telepearl',
		pos,
		pos,
		dir,
		'9U3ZAYNE',
		{
			shotId = '2XKTHZ4I',
			drawDurationSec = 9e9
		},
		workspace:GetServerTimeNow()
	)

	if store.hand then
		switchItem(store.hand.tool)
	end

	return threwPearl
end

local antiCrashConnections = {}

local function hookAntiCrash()
	if #antiCrashConnections > 0 then
		return
	end

	for _, connection in getconnections(game:GetService('ReplicatedStorage').ZAP.ZAP_RELIABLE.OnClientEvent) do
		local func = connection.Function
		if func then
			hookfunction(func, newcclosure(function(...)
				local tab = select(2, ...)
				if typeof(tab) == 'table' then
					local vec = tab[1]
					if typeof(vec) == 'Vector3' then
						if vec.Y > 1e7 then
							return tab[2]:Destroy()
						end
					end
				end
				return func(...)
			end))
			table.insert(antiCrashConnections, func)
		end
	end
end

local function unhookAntiCrash()
	for _, func in ipairs(antiCrashConnections) do
		if isfunctionhooked(func) then
			restorefunction(func)
		end
	end
	antiCrashConnections = {}
end

run(function()
	Bomboclat = vape.Categories.Blatant:CreateModule({
		Name = 'Bomboclat',
		Function = function(callback)
			if callback then
				hookAntiCrash()
				if entitylib.isAlive then
					local root = entitylib.character.RootPart
					local pearl = getItem('telepearl')

					if not pearl then
						Bomboclat:Toggle()
						return notif('Bomboclat', 'Missing item buddy', 5, 'warning')
					end

					rayCheck.FilterDescendantsInstances = {lplr.Character, gameCamera}
					rayCheck.CollisionGroup = root.CollisionGroup

					local ray = workspace:Raycast(root.Position, Vector3.new(0, 500, 0), rayCheck)
					if ray then
						Bomboclat:Toggle()
						return notif('Bomboclat', 'You are under a block', 5, 'warning')
					end

					notif('Bomboclat', 'Crashing please wait...', 10)

					local s = firePearl(
						root.Position,
						Vector3.new(9e7, 9e9, 9e6),
						pearl
					)

					return notif('Bomboclat', (s and 'Successfully crashed everyone' or 'Failed to crash, please retry.'), 5, (not s and 'warning'))
				end
			else
				unhookAntiCrash()
			end
		end,
		Tooltip = 'An iq too high?'
	})
end)
