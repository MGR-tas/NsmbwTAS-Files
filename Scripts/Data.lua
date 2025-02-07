local core = require 'NSMBWii_Core'
if io.open("sharedSettings.txt", "r") == nil then
  file = io.open("sharedSettings.txt", "w+")
  file:close()
end
if io.open("swimForMe.txt", "r") == nil then
  file = io.open("swimForMe.txt", "w+")
  file:close()
end
file = io.open("sharedSettings.txt", "r")  --used for sending text from the input import/export scripts to the lua script
swimForMe = io.open("swimForMe.txt", "r")

function onScriptStart()
  if ReadValueString(0, 3) ~= 'SMN' then
    CancelScript()
  end
end

function onScriptCancel()
  SetScreenText('')
end

local function isPressed(button, inputs)  --copied from the input import/export scripts, but is used for detecting collision properties here
  return button & inputs == button
end

function onScriptUpdate()
  local p1   = core.players.P1()
  local ps   = p1.Misc[1]
  local rng  = ReadValue32(core.rng.addr)
  local objList = core.object.list()

  local text = ''

  file:seek("set", 0)
  text = text .. tostring(file:read("*all"))

  text = string.format('%s\n\n--  Level %s  --', text, core.stats.misc().current_instance)
--if core.time.get().roomFrame == core.time.get().levelFrame then  --optional display only one level frame counter if they are the same
  --text = text .. string.format('\nLevel Timer : %.3f (%.0f)', core.time.get().igt, core.time.get().roomFrame)
--else
  text = text .. string.format('\nLevel Timer : %.3f (%.0f, %.0f)', core.time.get().igt, core.time.get().levelFrame, core.time.get().roomFrame)
--end
  text = text .. '\nRNG Value   : ' .. string.format('%X', rng)
  if core.stats.misc().switch_timer ~= 0 then
    text = text .. string.format('\nSwitch Timer : %.0f', core.stats.misc().switch_timer)
  end
  text = string.format('%s\nLoad Check Objects: %s', text, core.object.list().loadCheckObjs)

--Input-State Change
--Useful for level banner dismissal - mash 2/A and this will show the frame that the banner got dismissed. Then go back and press 2/A 3f before the number shown by this (also dolphin's turbo is bad so use a script to mash (Alternate.lua) or just experiment with pressing 2/A on a few different frames to see which one is optimal). Automatically hidden if you're in-level.

  if core.time.get().igt == 1 then
    if ReadValue8(0x80C87DBB) == 0 then
      if recordstate == 1 then
        --loadlength = GetFrameCount() - lastchange
        lastchange = GetFrameCount() - 1
      end
      recordstate = 0
    else
       if recordstate == 0 then
        lastchange = GetFrameCount() - 1
      end
      recordstate = 1
    end
    text = text .. '\nInput-State Change: ' .. tostring(lastchange)
    --text = text .. '\nPrev Transition Time: ' .. tostring(loadlength)
  end

  text = text .. '\n\n--  Mario  --'
if ReadValueString(3, 1) == 'E' then
  text = string.format('%s\nInputs : %X', text, core.players.P1().Misc[5])
elseif ReadValueString(3, 1) == 'J' then
  text = string.format('%s\nInputs : %X', text, core.players.P1().Misc[6])
end

  local collisionText = '\n'
    if isPressed(1, core.players.P1().Misc[7]) then
      collisionText = collisionText .. 'Ground '
      if isPressed (0x1000000, core.players.P1().Misc[7]) then
        collisionText = collisionText .. '(Ice) '
      end
    end
    if isPressed(2, core.players.P1().Misc[7]) then
      collisionText = collisionText .. 'Ceiling '
    end
    if isPressed(0x10, core.players.P1().Misc[7]) then
      collisionText = collisionText .. 'WallR '
    end
    if isPressed(8, core.players.P1().Misc[7]) then
      collisionText = collisionText .. 'WallL '
    end
    if isPressed(0x4000, core.players.P1().Misc[7]) then  --0x10000 is also related?
      collisionText = collisionText .. 'Water '
      if isPressed(0x40000, core.players.P1().Misc[7]) then
        collisionText = collisionText .. '(bubble) '
      end
    elseif isPressed(0x8000, core.players.P1().Misc[7]) then
      collisionText = collisionText .. 'Liquid (Surface) '
    end
  text = text .. collisionText

  text = string.format('%s\n\nX Position  : %.4f', text, p1.Pos[1])
  text = string.format('%s\nY Position  : %.4f', text, p1.Pos[2])
  text = string.format('%s\n\nX Displaced : %.4f', text, p1.Speed[1])
  if math.abs(p1.Speed[1]-p1.Speed[2]) <= 0.00005 then  --prevents the difference from swapping between +0.0000 and -0.0000 absurdly frequently
    text = text .. ' (0.0000)'
  else
    text = string.format('%s (%.4f)', text, p1.Speed[1]-p1.Speed[2])
  end
  text = string.format('%s\nX Speed     : %.4f', text, p1.Speed[2])
  text = string.format('%s\nX Speed Cap : %.4f', text, p1.Speed[3])
  text = string.format('%s\nX Accel     : %.4f', text, p1.Speed[4])
  text = string.format('%s\n\nY Displaced : %.4f', text, p1.Speed[5])
  text = string.format('%s\nY Speed     : %.4f', text, p1.Speed[6])
  text = string.format('%s\nY Accel   : %.4f\n', text, p1.Speed[7])

  swimForMe:seek("set", 0)
  text = text .. tostring(swimForMe:read("*all"))

  if p1.Timers[1] ~= 0 then
    text = string.format('%s\nStar Timer  : %.0f', text, p1.Timers[1])
  end
  if ps == 4 then
    text = string.format('%s\nSpin Timer  : %.0f', text, p1.Timers[4])
  end
  if p1.Timers[2] ~= 0 then
    text = string.format('%s\nTwirl Timer : %.0f', text, p1.Timers[2])
  end
  if ps == 5 then
    text = string.format('%s\nSlide Timer : %.0f', text, p1.Timers[3])
  end
    text = string.format('%s\nAction Timer: %.0f', text, p1.Timers[5])
    text = string.format('%s\nStored Jump : %.0f', text, p1.Misc[2])
    text = string.format('%s\nJump Timer  : %.0f', text, p1.Timers[6])
  if p1.Misc[3] ~= 0 then
    text = string.format('%s\nPipe Timer  : %.0f', text, p1.Misc[3])
  else
    text = string.format('%s\nPipe Timer  : %.0f', text, p1.Misc[4])
  end

  --text = text .. '\n\n' .. core.object.list().itemSearchList  --select an object to watch at the top of NSMBW_Core.lua. Displays object address, position, and speed by default; watch data can be cusomized in NSMBW_Core.lua.
  text = text .. '\n\n' .. core.object.list().compactObjList
  --text = text .. '\n\n' .. core.object.list().fullObjList  --uncomment this line and comment the above line to see the full object list, with object addresses.

  SetScreenText(text)
end
