-----------
--GetString
-----------
GetString={}
GetString.camera={x=0,y=0,z=4}
GetString.ID="GetString"

GetString.Start=function(message, str, numOnly)
  GetString.savestate=gamestate
  gamestate=GetString
  GetString.message=message
  GetString.string=str
  if numOnly then GetString.numOnly=true
  else GetString.numOnly=nil
  end
end

GetString.hud={
{{},{},{}},
{{},{function() return GetString.message end,
    function() return GetString.string end},{}},
{{},{},{}},
}

GetString.KeyDown={
  DEFAULT=function(key)
    if (key==188 or key==190) then key=key-144 end --allow comma and period
	if (not GetString.Shift) and key>=65 and key<=90 then key=key+32 end
    
	if (not GetString.numOnly and((key>=65 and key<=90) or (key==32) 
	or (key>=97 and key<=122)))
	or (key>=48 and key<=57)
	and #GetString.string < MAXSTR then
	    GetString.string=GetString.string..string.char(key)
	end
  end,
  ENTER=function() GetString.savestate.Start() end,
  SHIFT=function() GetString.Shift = true end,
  BACKSPACE = function()
    if  #GetString.string > 0 then
	  GetString.string=string.sub(GetString.string, 1, 
	  #GetString.string-1)
	end
  end,
  ESC = function()
    GetString.savestate.flag = nil
	GetString.savestate.Start()
  end
}

GetString.KeyUp={
  SHIFT=function() GetString.Shift=nil end,
}

GetString.render=function()
  RenderSolidBackground("black")
  drawhud(GetString.hud, 19)
  FlipScreen()
end

GetString.OnTimer=function()
  collectgarbage()
end
  