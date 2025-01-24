local interval  = 29 + 1    --replace '1' with the number of igt frames you want to elapse between pauses (must be greater than or equal to 0)
local mode = 1    --1 = do one pause;  2 = pause spam as indicated by the previous line
local button = ''
local buttont = 0
local startf = GetFrameCount() + 1
local lastFrame = -1
local lastPause = GetFrameCount() + 1
local lastPauseAdjust = 0
local cancelNext = 0
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
    lastPauseAdjust = GetFrameCount() - lastPause
    if cancelNext == 1 then
      onScriptCancel()
      cancelscript()
    end
    if GetFrameCount() - lastPause == 28 and mode == 1 then
      cancelNext = 1
    end
    while lastPauseAdjust < 0 do
      lastPauseAdjust = lastPauseAdjust + interval
    end
    while lastPauseAdjust > (interval - 1) do
      lastPauseAdjust = lastPauseAdjust - interval
    end
  end

  if (lastFrame - startf) % interval == 0 or (lastFrame - startf - 19) % interval == 0 then
   PressButton('+')
    if (lastFrame - startf) % interval == 0 then
     lastPause = GetFrameCount()
    end
  end
  swimForMe:seek("set", 0)
    if lastPauseAdjust < 29 then
      io.write(string.format('\nPause-cycle : %.0f/29                    ', lastPauseAdjust + 1))
    else
      io.write(string.format('\nPause-cycle : Input Allowed! : %.0f/%.0f     ', lastPauseAdjust - 28, interval - 29))
    end
end
