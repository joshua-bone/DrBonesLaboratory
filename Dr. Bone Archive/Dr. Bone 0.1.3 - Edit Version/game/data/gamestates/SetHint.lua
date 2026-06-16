-------------
--SETHINT
-------------

SetHint={camera=GameCamera}
SetHint.ID="SetHint"

SetHint.DisplayMessage=function()
  if SetHint.current then
    local message = Clone(SetHint.current.message)
	if not SetHint.line then
		SetHint.line = #message
	end
	if not message[SetHint.line] then message[SetHint.line]="" end
	message[SetHint.line]="--> "..message[SetHint.line].." <--"
    return message
  else
    return {}
  end
end

SetHint.Hud={
{{"TAB to switch between hint tiles", "ESC to exit"},{},{}},
{{},SetHint.DisplayMessage,{}},
{{},{},{}}
}

SetHint.HelpHud={
{{},{},{}},
{{},{},{}},
{{},{},{}}
}
--[[
SetHint.StartTest=function()
--  PlayHud[1][2]["type"]="Test level"
  Editor.savemap()
  stop=Editor.Start
  postwin=Editor.Start
  Pregame.Start()
end ]]--
SetHint.FindNext=function()
  local x, y, z = SetHint.x, SetHint.y, SetHint.z
  while true do
	x=x-1           -- scan in reverse reading order as per CC rules
	if x<1 then
		x=#map
		y=y-1
		if y<1 then 
			y=#map[1]
			z=z-1
			if z<1 then
				z=#map[1][1]
			end
		end
	end
	
	if (x==SetHint.x and y==SetHint.y and z==SetHint.z) then  --if we've come full circle
	  return
	end
	
	local w
	local here=map[x][y][z]
	if here then
		for w=#here,1,-1 do
		  if here[w].name=="Hint" then	
		    SetHint.x, SetHint.y, SetHint.z, SetHint.CurrentDeck = x, y, z, z
			SetHint.current=here[w]
			SetHint.line=#here[w].message
			return
		  end
		end
	end
	
	
  end
  
end

SetHint.Start=function()
  ClipMap=false
  stop=Editor.Start
  gamestate=SetHint
  SetHint.x, SetHint.y, SetHint.z, SetHint.CurrentDeck = 1, 1, 1, 1
  SetHint.FindNext()
end

SetHint.render=function()
  SetHint.camera={x=SetHint.x, y=SetHint.y, z=GameCamera.z}
  MapRender(map)
  drawhud(SetHint.Hud,19)
  FlipScreen()
end

SetHint.Exit=function()
  stop()
  --if CheckDirty() then stop() return true end
  --return false
end

SetHint.KeyDown={
  DEFAULT=function(key)
    if (key==188 or key==190) then key=key-144 end --allow comma and period
    if ((key>=65 and key<=90) or (key>=48 and key<=57) or (key==32))
	and SetHint.current and #SetHint.current.message[SetHint.line] < MAXSTR then
	    SetHint.current.message[SetHint.line]=SetHint.current.message[SetHint.line]..string.char(key)
	end
  end,
  UP = function()
    if SetHint.line and SetHint.line>1 then
	  SetHint.line=SetHint.line-1
	  local s
	  for s=#SetHint.current.message,SetHint.line+1,-1 do
	    if SetHint.current.message[s]=="" then
		  SetHint.current.message[s]=nil
		else
		  break
		end
      end
	end
  end,
  DOWN = function()
    if SetHint.line and SetHint.current then
	  if SetHint.line < MAXHINT then
	    SetHint.line=SetHint.line+1
		if SetHint.line > #SetHint.current.message then
		  SetHint.current.message[SetHint.line]=""
		end
	  end
	end
  end,
  BACKSPACE = function()
    if SetHint.current and #SetHint.current.message[SetHint.line] > 0 then
	  local l = #SetHint.current.message[SetHint.line]
	  SetHint.current.message[SetHint.line]=string.sub(SetHint.current.message[SetHint.line], 1, l-1)
	end
  end,
  TAB=SetHint.FindNext,
  ENTER = function()
    SetHint.KeyDown.DOWN()
  end,
  ESC=SetHint.Exit,
}