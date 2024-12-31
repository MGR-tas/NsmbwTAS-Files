local interval  = 19
local button    = 'LEFT'
local buttont   = 0
local startf    = GetFrameCount() + 1
local lastFrame = -1
local step = 0
local lastA = 0
local lastAAdjust = 0
swimForMe = io.open("swimForMe.txt", "w")
io.output(swimForMe)

function onScriptStart()
end

function onScriptCancel()
  swimForMe:close()
  swimForMe = io.open("swimForMe.txt", "w+")
  swimForMe:close()
end

function onScriptUpdate()
  if GetFrameCount() ~= lastFrame then
    lastFrame = GetFrameCount()
    lastAAdjust = GetFrameCount() - lastA
    while lastAAdjust < 0 do
      lastAAdjust = lastAAdjust + 19
    end
    while lastAAdjust > 18 do
      lastAAdjust = lastAAdjust - 19
    end
  end

  if (lastFrame - startf) % interval == 0 then
    PressButton('A')
    lastA = GetFrameCount()
  end
  swimForMe:seek("set", 0)
  io.write(string.format('\nA-cycle     : %.0f     ', lastAAdjust))
end
