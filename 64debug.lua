-- name: 64 short debug
-- description: Show fake coopdx version, fake beta warning, mod numbers, name, device's platform, ping, Romhack Name And levelName on the bottom left, Like some game of short debug info from screen of the bottom right. \n\nByToad114514

-- toboolean
local toboolean={ ["true"]=true, ["false"]=false }
-- Version
local version = mod_storage_load("version")
local beta = toboolean[mod_storage_load("beta")]
-- check mod_storage_load value
if version == nil then
  version = "v1.3.1"
  mod_storage_save("version", "v1.3.1")
elseif beta == nil then
  beta = false
  mod_storage_save("beta", "false")
end

local mods_number = 0

-- table of System and Platform 

-- 0: Windows, 1: Linux, 2: Mac, 3: Android
local os = {
  	["Unknown"] = 1,
	["Windows"] = 0,
	["Linux"] = 1,
	["Unix"] = 1,
	["FreeBSD"] = 1,
	["Mac OSX"] = 2,
	["Android"] = 3
}

for x in pairs(gActiveMods) do
  mods_number = mods_number + 1
end

-- remove color function
local function remove_color(text, get_color)
	local start = text:find("\\")
	local next = 1
	while (next ~= nil) and (start ~= nil) do
		start = text:find("\\")
		if start ~= nil then
			next = text:find("\\", start + 1)
			if next == nil then
				next = text:len() + 1
			end

			if get_color then
				local color = text:sub(start, next)
				local render = text:sub(1, start - 1)
				text = text:sub(next + 1)
				return text, color, render
			else
				text = text:sub(1, start - 1) .. text:sub(next + 1)
			end
		end
	end
	return text
end

-- Romhack
local romhack = "none"
for x in pairs(gActiveMods) do
  if gActiveMods[x].incompatible == "Romhack" or gActiveMods[x].incompatible == "romhack" then
    romhack = remove_color(gActiveMods[x].name, false)
  end
end
if romhack == "none" then
  romhack = "Vanilla Super Mario 64"
end

-- platform reset
local os = get_os_name()
if os == "Linux" or os == "Unix" or os == "FreeBSD" or os == "Unknown" then
  os_txt = "Linux/Unix/BSD"
else
  os_txt = get_os_name()
end

local function hud_render()
  djui_hud_set_resolution(RESOLUTION_N64)
  sdf = djui_menu_get_font()
  djui_hud_set_font(sdf)
  
  local p = gNetworkPlayers[0]
  local ping = p.ping
  local levelName = p.overrideLocation ~= "" and p.overrideLocation or get_level_name(p.currCourseNum, p.currLevelNum, p.currAreaIndex)
  local player = remove_color(p.name, false)
  
  local text = "SM64Coopdx " .. version .. "(" .. os_txt .. "), " .. player .. ", " .. mods_number .. " Mods Loaded, Ping " .. ping .. "ms"
  djui_hud_set_color(255,255,255,255)
  djui_hud_print_text("Romhack: " .. romhack .. ", C" .. p.currCourseNum .. " - " .. levelName .. "(Area " .. tostring(p.currAreaIndex) .. ")", 0, 225, 0.25)
  djui_hud_print_text(text, 0, 232, 0.25)
  
  -- beta text description
  if beta then
    djui_hud_set_color(255,0,0,255)
    djui_hud_print_text("BETA VERSION! The stability of this version cannot be guaranteed", 0, 218, 0.25)
  end
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)
-- mod menu hook
local function beta(index, value)
  beta = value
  mod_storage_save("beta", tostring(value))
end

local function version(index, value)
  version = tostring(value)
  mod_storage_save("version", value)
end

hook_mod_menu_text("Change will be enable on next server host.")
hook_mod_menu_checkbox("Beta version warning", toboolean[mod_storage_load("beta")], beta)
hook_mod_menu_inputbox("Fake version", mod_storage_load("version"), 30, version)
  
