local core = require 'NSMBWii_Core'
local lastFrame = GetFrameCount()
local index = 0
local headerOffset = 0
local replay = 0
local message = ''
local messageC = 0x00FF00
local timer = 120

local offset = GetFrameCount()
local initialOffset = offset

settings = io.open("sharedSettings.txt", "w+")  -- used to send text to Data.lua
io.output(settings)

local YChanged = false
if ReadValueString(3, 1) == 'E' then  -- Determines whether playing with or without nunchuck, which changes where tilt controlls are sent
  nunchuckaddr = '0x8039FBA3'
  rng = '0x80429F44'
elseif ReadValueString(3, 1) == 'J' then
  nunchuckaddr = '0x8039F923'
  rng = '0x80429C64'
end
nunchuck = true

function onScriptStart()
  file = io.open("tas.txt", "r")
  file = tostring(file:read("*all"))
  local fileFormat = string.sub(file, 1, 1)
  if fileFormat == 'A' then
    headerOffset = string.sub(file, 2, 3)
    recordNunchuck = tonumber(string.sub(file, 4, 4))
    rngInit = tonumber(string.sub(file, 5, headerOffset-1),16)

    if ReadValue8(nunchuckaddr) ~= recordNunchuck then
      nunchuck = false
      message = message .. 'Warning! Controller settings do not match the recorded file!\n'
      messageC = 0xFF0000
      timer = 420
    else
      nunchuck = true
      message = message .. 'Controller settings OK!\n'
    end

    if ReadValue32(core.rng.addr) ~= rngInit then
      message = message .. 'RNG is mismatched! This is either just fine or really bad depending \non the level. If this is just for an IL, set the RNG to ' .. string.sub(file, 5, headerOffset-1) .. ' in \nDolphin Memory Engine before starting the script.'
      if messageC == 0x00FF00 then
        messageC = 0xFFCF00
      end
      timer = 420
    else
      nunchuck = true
      message = message .. 'RNG is synced!'
    end
    --RenderText(message, 375, 14, messageC, 11)
  else
    message = message .. 'File format unknown! Make sure you are using the \nmost up-to-date version of the input import script! \n'
    messageC = 0xFF0000
   timer = 9999
  end
end

function onScriptCancel()
  settings:close()
  settings = io.open("sharedSettings.txt", "w+")
  settings:close()
end

local function isPressed(button, inputs)
  return button & inputs == button
end

function onScriptUpdate()

  if GetFrameCount() ~= lastFrame then
    round = 0
    replay = replayNext
    replayNext = 0
    lastFrame = GetFrameCount()
  else
    if round == 0 and core.object.list().loadCheckObjs >= 2 then
      replayNext = 1
      --RenderText('Will Replay Next', 137, 14, 0xFF00FF, 11)
      if index/11+1 <= timer then
        RenderText(message, 375, 14, messageC, 11)
      end
    end
    if round == 0 and core.object.list().loadCheckObjs <= 1 then
      offset = offset + 1
      --RenderText('Loading', 137, 14, 0xFF0000, 11)
      --RenderText(offset, 237, 14, 0xFF0000, 11)
    end
    round = 1
  end


  --[[  This is what each button is stored as
    HOME = 32768
    C = 16384
    Z = 8192
    - = 4096
    A = 2048
    B = 1024	
    1 = 512	
    2 = 256
    + = 16	
    LEFT = 8
    RIGHT = 4	
    UP = 2
    DOWN = 1
  ]]--


 if replay == 1 then
  --Sets the current line to the correct position based off of an initial offset
  if timer == 9999 then
    index = 11 + headerOffset
    if GetFrameCount() - offset >= 420 then
      settings:close()
      settings = io.open("sharedSettings.txt", "w+")
      settings:close()
      cancelscript()
    end
  else
    index = (GetFrameCount() - offset) * 11 + headerOffset
  end
  local data = tonumber(string.sub(file, index + 1, index + 4), 16)
  local tilt = tonumber(string.sub(file, index + 5, index + 7), 16)
  local accZ = tonumber(string.sub(file, index + 8, index + 10), 16)
  XXX, YYY, ZZZ = GetAccel(4)
  --RenderText('Importing Inputs', 137, 14, 0x00FF00, 11)
  if file.len(file) - 11 <= index or index <= -1 then  -- Cancels the script if the end of the file has been reached or if a savestate was loaded before the start of the file
    CancelScript()
  end
  
  --Translate inputs from the current line into actual button presses
  if isPressed(32768, data) then
    PressButton('Home', 4)
  end
  if isPressed(16384, data) then
    PressButton('C', 4)
  end
  if isPressed(8192, data) then
    PressButton('Z', 4)
  end
  if isPressed(4096, data) then
    PressButton('-', 4)
  end
  if isPressed(2048, data) then
    PressButton('A', 4)
  end
  if isPressed(1024, data) then
    PressButton('B', 4)
  end
  if isPressed(512, data) then
    PressButton('1', 4)
  end
  if isPressed(256, data) then
    PressButton('2', 4)
  end
  gameData = ReadValue16(dataaddr)
  if YYY == 410 and YChanged == false then
    offset = offset + 1
    YChanged = true
  elseif YYY == 512 then
    YChanged = false
  end
  if YYY == 614 and YChanged == false then
    offset = offset - 1
    YChanged = true
  end
  if isPressed(16, data) then
    PressButton('+', 4)
  end
  if isPressed(8, data) then
    PressButton('UP', 4)
  end
  if isPressed(4, data) then
    PressButton('DOWN', 4)
  end
  if isPressed(2, data) then
    PressButton('RIGHT', 4)
  end
  if isPressed(1, data) then
    PressButton('LEFT', 4)
  end
  if nunchuck then
    SetAccelX(tilt, 4)
  else  
    SetAccelY(tilt, 4)
  end
  SetAccelZ(accZ, 4)
  local text = string.format('\n   Input index:  %.0f / %.0f\nCurrent offset:  %.0f\nTime difference from initial offset:  %.0f     ', index/11+1, file.len(file)/11-1, offset,offset-initialOffset)
  settings:seek("set", 0)
  io.write(text)
 else
  local text = string.format('\n   Input index:  %.0f / %.0f\nLoading                                                               ', index/11+1, file.len(file)/11-1) -- gotta add some extra spaces at the end of this to overwrite the rest of the stuff from when the file was longer. Could also be done with reopening the file with w+, but that's really inneficient
  settings:seek("set", 0)
  io.write(text)
 end
end