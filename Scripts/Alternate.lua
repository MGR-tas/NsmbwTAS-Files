local offset = GetFrameCount()

function onScriptStart()
end

function onScriptCancel()
end

local function isPressed(button, inputs)  -- here in case you want to tell the script to do something when you press a specific button
  return button & inputs == button
end

function onScriptUpdate()
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
  RenderText('A | 2', 137, 14, 0xFF00FF, 11)

  if (GetFrameCount() - offset) % 2 == 0 then
    PressButton('A', 4)
  else
    PressButton('2', 4)
  end
end