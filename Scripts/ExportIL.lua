local core = require 'NSMBWii_Core'

local round = 1
local text = ''
local lastFrame = GetFrameCount()
local offset = GetFrameCount()+1
local initFrame = GetFrameCount()
--Determines whether playing with or without nunchuck, which changes how tilt controlls are recorded
if ReadValueString(3, 1) == 'E' then
  dataaddr = '0x8039F460'
  nunchuckaddr = '0x8039FBA3'
elseif ReadValueString(3, 1) == 'J' then
  dataaddr = '0x8039F120'
  nunchuckaddr = '0x8039F923'
end
if ReadValue8(nunchuckaddr) == 0 then
  nunchuck = false
else
  nunchuck = true
end
local tilt = 512
local accZ = 616

settings = io.open("sharedSettings.txt", "w+")

function onScriptStart()
  file = io.open("tas.txt", "w+")
  io.output(file)
  text = 'A'  -- file format ID
  local rngInit = string.format('%X', ReadValue32(core.rng.addr))
  text = text .. string.format('%2.i', rngInit.len(rngInit) + 5)  -- Length of file header, which may be shorter if the rng is less than 8 digits. Also makes this easier to customize in the future
  if nunchuck then
    text = text .. '1'
  else
    text = text .. '0'
  end
  text = text .. rngInit
  io.write(text,'\n')
end

function onScriptCancel()
  settings:close()
  settings = io.open("sharedSettings.txt", "w+")
  settings:close()
end

function onScriptUpdate()
  --The GetAccel() function, along with some data values, don't always update on the first 'script update' of a frame. This configuration of GetFrameCount() and lastframe ensures that the data is read through on the second script update of the frame and therefore will get the correct information. The round system is then used to make sure the data is only read through once per frame.
  if GetFrameCount() ~= lastFrame then
    data = ReadValue16(dataaddr)
	round = 0
	lastFrame = GetFrameCount()
  else
    if round == 0 and core.object.list().loadCheckObjs >= 2 then
      text = string.format('%4X%3X%3X', data, tilt, accZ)
      RenderText('Exporting Inputs', 137, 14, 0xFF00FF, 11)
      firstInput = false
	  if nunchuck then
	    tilt, accY, accZ = GetAccel(4)
	  else
	    accX, tilt, accZ = GetAccel(4)
	  end
      io.write(text,'\n')
      recordState = 'Recording'
      settings:seek("set", 0)
      settings:write(string.format('\n--  Recording inputs to tas.txt  --\nRecording State: %s\nFrame Output: "%s"               ', recordState, text))
      round = 1
    elseif round == 0 and core.object.list().loadCheckObjs <= 1 then
      recordState = 'Loading'
      text = ''
      settings:seek("set", 0)
      settings:write(string.format('\n--  Recording inputs to tas.txt  --\nRecording State: %s\nFrame Output: "%s"               ', recordState, text))
      round = 1
    end
  end
end