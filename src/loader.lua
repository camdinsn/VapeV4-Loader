local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

local function encodePath(path)
	path = path:gsub('%%', '%%25')
	path = path:gsub(' ', '%%20')
	return path
end

local function repoPath(path)
	local rel = path:gsub('^newvape/', '')
	if rel == 'main.lua' then
		return 'src/main.lua'
	elseif rel == 'loader.lua' then
		return 'src/loader.lua'
	elseif rel == 'games/universal.lua' then
		return 'src/games/universal - base/base.lua'
	elseif rel == 'guis/new.lua' then
		return 'src/guis/new/gui.lua'
	elseif rel == 'guis/old.lua' then
		return 'src/guis/old/gui.lua'
	elseif rel == 'guis/rise.lua' then
		return 'src/guis/rise/gui.lua'
	elseif rel == 'guis/liquidbounce.lua' then
		return 'src/guis/liquidbounce/gui.lua'
	elseif rel == 'guis/wurst.lua' then
		return 'src/guis/wurst/gui.lua'
	end
	return rel
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/camdinsn/VapeV4-Loader/'..readfile('newvape/profiles/commit.txt')..'/'..encodePath(repoPath(path)), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('loader') then continue end
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
			delfile(file)
		end
	end
end

for _, folder in {'newvape', 'newvape/games', 'newvape/profiles', 'newvape/assets', 'newvape/libraries', 'newvape/guis'} do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

if not shared.VapeDeveloper then
	local _, subbed = pcall(function()
		return game:HttpGet('https://github.com/camdinsn/VapeV4-Loader')
	end)
	local commit = subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'
	if commit == 'main' or (isfile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') or '') ~= commit then
		wipeFolder('newvape')
		wipeFolder('newvape/games')
		wipeFolder('newvape/guis')
		wipeFolder('newvape/libraries')
	end
	writefile('newvape/profiles/commit.txt', commit)
end

return loadstring(downloadFile('newvape/main.lua'), 'main')()