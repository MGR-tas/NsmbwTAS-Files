
--[[
  TODO:
    - Add functions for players 2-4.
    - Add PAL support (if needed).
]]

local core    = {}
local players = {}
local rng     = {}
local stats   = {}
local time    = {}
local object  = {}
local searchItem = ',KOOPA_FIRE,' -- fill this with objects you want to watch in format ',object1,object2,object3,'  (useful for watching position/speed of enemies/objects or seeing when they load). To use, uncomment this line near the end of Data.lua

function core.game_id_rev()
  local id  = ReadValueString(4, 2)
  local reg = ReadValueString(3, 1)
  local rev = ReadValue8(7)

  return {ID = id, Region = reg, Rev = rev}
end

local id  = core.game_id_rev().ID
local reg = core.game_id_rev().Region
local rev = core.game_id_rev().Rev

-- PLAYER STATS --

p1 = 0x8154b804

function players.P1()
  local inputsUS = ReadValue16(0x8039F460)
  local inputsJP = ReadValue16(0x8039F120)
  local collisionFlags = ReadValue32(p1 + 0x10D4)

  local x_pos = ReadValueFloat(p1 + 0xAC)
  local x_disp = ReadValueFloat(p1 + 0xC4)
  local x_spd = ReadValueFloat(p1 + 0x10C)
  local x_cap = ReadValueFloat(p1 + 0x110)
  local x_accel = ReadValueFloat(p1 + 0x11C)

  local y_pos = ReadValueFloat(p1 + 0xB0)
  local y_disp = ReadValueFloat(p1 + 0xC8)
  local y_spd = ReadValueFloat(p1 + 0xEC)
  local y_accel = ReadValueFloat(p1 + 0x114)

  local star = ReadValue32(p1 + 0x1070)
  local twirl = ReadValue32(p1 + 0x27C8)
  local slide = ReadValue32(p1 + 0x1A18)
  local spin = ReadValue32(p1 + 0x17C4)
  local action = ReadValue32(p1 + 0xEC0)
  local jump = ReadValue8(p1 + 0x1568)

  local powerup = ReadValue32(p1 + 0x14E0)
  local stored_jump = ReadValue32(p1 + 0x1564)
  local lPipe = ReadValue8(p1 + 0x420)
  local rPipe = ReadValue8(p1 + 0x421)

  return {
    Pos    = {x_pos, y_pos},
    Speed  = {x_disp, x_spd, x_cap, x_accel, y_disp, y_spd, y_accel},
    Timers = {star, twirl, slide, spin, action, jump},
    Misc   = {powerup, stored_jump, lPipe, rPipe, inputsUS, inputsJP, collisionFlags}
  }
end


-- RNG --

if reg == 'E' then
  rng.addr = 0x80429F44
elseif reg == 'J' then
  rng.addr = 0x80429C64
end

function rng.next(x, maximum)
  local x = rng.increment(x, 1)
  return (x * maximum) >> 32
end

function rng.increment(x, n)
  local a = 0x19660D
  local b = 0x3C6EF35F
	local c = 0x100000000

  local i = 0
  while i < n do
    x = x * a + b
    x = (x + (x >> 32)) % c
    i = i + 1
  end

  return x
end

-- STATS --

function stats.misc()
  stats.inv_addr_ref = 0x815DBB74

  return {
    mushrooms  = ReadValue32(stats.inv_addr_ref),
    f_flowers  = ReadValue32(stats.inv_addr_ref + 0x4),
    propellers = ReadValue32(stats.inv_addr_ref + 0x8),
    i_flowers  = ReadValue32(stats.inv_addr_ref + 0xC),
    penguins   = ReadValue32(stats.inv_addr_ref + 0x10),
    minis      = ReadValue32(stats.inv_addr_ref + 0x14),
    stars      = ReadValue32(stats.inv_addr_ref + 0x18),
    ps7s       = ReadValue32(stats.inv_addr_ref + 0x1C),
    switch_timer = ReadValue32(0x815E4338)
  }
end

-- TIME --

function time.get()
  local timer_addr = 0x80D25BF8
  return {
    igt = ReadValue32(timer_addr) / 4096 + 1,
    roomFrame = ReadValue16(0x815E44EE)
  }
end

-- OBJECT LIST --

function object.list()
  objName = {}
  objAddr = {}

  if ReadValueString(3, 1) == 'E' then
    objectNodeAddr = ReadValue32(0x80377a34)
  elseif ReadValueString(3, 1) == 'J' then
    objectNodeAddr = ReadValue32(0x803777B4)
  end
  i = 1
  while (objectNodeAddr ~= 0x0) do
    objectAddr    = ReadValue32(objectNodeAddr + 0x8)
    objectNamePtr = ReadValue32(objectAddr + 0x6C)

    objName[i] = ReadValueString(objectNamePtr, 0x100)
    objAddr[i] = string.format('0x%X', objectAddr)

    objectNodeAddr = ReadValue32(objectNodeAddr + 0x4)
    i = i + 1
  end

  local ObjectNum = 1
  local fullObjList = ''
  local compactObjList = ''
  local itemSearchList = ''
  local loadCheckObjs = 0
  while objName[ObjectNum] ~= nil do
    j = 0
    while objName[ObjectNum] == objName[ObjectNum + j] do
      fullObjList = fullObjList .. objAddr[ObjectNum + j] .. ' ' .. objName[ObjectNum] .. '\n'
      if string.find(searchItem, ',' .. objName[ObjectNum] .. ',') ~= nil then
        itemSearchList = itemSearchList .. objName[ObjectNum + j] .. ' ' .. objAddr[ObjectNum + j]
        itemSearchList = itemSearchList .. string.format('\n (%.4f, %.4f)', ReadValueFloat(objAddr[ObjectNum + j] + 0xAC), ReadValueFloat(objAddr[ObjectNum + j] + 0xB0))
	local moveX  = ReadValueFloat(objAddr[ObjectNum + j] + 0xC4)
	local moveY = ReadValueFloat(objAddr[ObjectNum + j] + 0xC8)
        itemSearchList = itemSearchList .. string.format('\n (%.4f, %.4f)', moveX, moveY)


--[[
--Movement Angle--
	local angle = 0
	if moveX == 0 and moveY == 0 then
		angle = 0
	else
		angle = math.acos(moveX/math.sqrt(moveX*moveX+moveY*moveY))
	end

	if moveY < 0 then
		--itemSearchList = itemSearchList .. string.format('\n -%.10f', math.deg(angle))
itemSearchList = itemSearchList .. string.format('\n -%.10f', angle)
	else
		--itemSearchList = itemSearchList .. string.format('\n %.10f', math.deg(angle))
itemSearchList = itemSearchList .. string.format('\n %.10f', angle)
	end
--]]

	itemSearchList = itemSearchList .. '\n\n'
      end
      j = j + 1
    end
    if objName[ObjectNum] == 'YES_NO_WINDOW' or objName[ObjectNum] == 'PLAYER' or objName[ObjectNum] == 'WM_MAP' then
      loadCheckObjs = loadCheckObjs + 1
    end
    if ReadValue8(objAddr[ObjectNum] + 0xE) == 2 then
      compactObjList = compactObjList .. objName[ObjectNum] .. ' x' .. j .. '\n'
    end
    ObjectNum = ObjectNum + j
  end


  return {
    fullObjList = fullObjList,
    compactObjList = compactObjList,
    itemSearchList = itemSearchList,
    loadCheckObjs = loadCheckObjs     -- used for loadless input import/export
  }

end


core.players = players
core.rng     = rng
core.stats   = stats
core.time    = time
core.object  = object

return core
