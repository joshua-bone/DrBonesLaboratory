gsEditor={}
gsEditor.ID="gsEditor"

gsEditor.Start=function()
  if not Level then
    gsParts.Start() --load the gsParts.Left/Right
    Level=fxL.GenerateLevel()
  end
  gs=gsEditor
  gs.hud=gs.MainHud
  gs.t=0 --the game timer tick
  Map=fxL.ParseMap(Level) --Map is now parsed AND initialized
  gs.Cam={y=(#Map[1]/2)+.5,x=(#Map/2)+.5,z=20}
  gs.atZ=Level.atZ --which floor we're on
  if Level.LastCam then gs.Cam=Level.LastCam end --last camera view if applicable
  gs.mode="Edit"
  gs.OptionsMenu=inL.MakeMenu(gs.OptionsMenuBuild(),
    "yellow50", "yellow", 1)
  gs.menu=gs.OptionsMenu
  gs.glist=gsMenu.glist
end



gsEditor.OnTimer=function()
  gs.t=gs.t+1 --run the clock to animate force floors
  if gs.ZoomZ and math.abs(gs.ZoomZ-gs.Cam.z)>0.2 then
    --print(gs.ZoomZ)
    if gs.ZoomZ>gs.Cam.z then gs.Cam.z=gs.Cam.z+0.2
	elseif gs.ZoomZ<gs.Cam.z then gs.Cam.z=gs.Cam.z-0.2
	else gs.ZoomZ=nil
	end
  end
  if gs.ZoomX then
    if gs.ZoomX>(gs.Cam.x+2) then gs.Cam.x=gs.Cam.x+0.08
	elseif gs.ZoomX<(gs.Cam.x-2) then gs.Cam.x=gs.Cam.x-0.08
	else gs.ZoomX=nil
	end
  end
  if gs.ZoomY then
	if gs.ZoomY>(gs.Cam.y+2) then gs.Cam.y=gs.Cam.y+0.08
	elseif gs.ZoomY<(gs.Cam.y-2) then gs.Cam.y=gs.Cam.y-0.08
	else gs.ZoomY=nil
	end
  end
end

gsEditor.Render=function()
  --grL.RenderGLList(gs.glist)
  grL.RenderMap(map)
  if gs.mode=="Edit" then grL.RenderCursor() end
  grL.RenderHud(gs.hud)
  FlipScreen()
end



gsEditor.PaintLeft=function(x,y)
  if gs.mode=="Edit" then
    local obj=gsParts.Left.Item
    if obj.PaintWith then obj.PaintWith(obj,x,y,gs.atZ)
    else fxL.AddObject(obj,x,y,gs.atZ)
    end
    Level.modified=true --flag so it asks to be saved
  end
end

gsEditor.PaintRight=function(x,y)
  if gs.mode=="Edit" then
    local obj=gsParts.Right.Item
    if obj.PaintWith then obj.PaintWith(obj,x,y,gs.atZ)
    else fxL.AddObject(obj,x,y,gs.atZ)
    end
    Level.modified=true --flag so it asks to be saved
  end
end

gsEditor.MainHud={
{{function() return gsParts.Left end,
},
{
function() 
  local m=inL.mouse.map
  if m and m.x>0 and m.y>0 and m.x<=#Map and m.y<=#Map[1] then
    return m.x.." "..m.y.." "..gs.atZ
  else return "" end
end
},
{function() return gsParts.Right end,
}},
{{},{},{}},
{
function()
  local result=gs.menu.GetList(gs.menu)
  result["background"]={color="black", border="yellow", size="fit"}
  return result
end,{
"Press F1 to toggle Editor Help screen",
},{}
}}

gsEditor.SetTitle=function()
  gs.mode="Set Title"
  gs.string=Level.title
  gs.hud=gs.SetTitleHud
end

gsEditor.SetTime=function()
  gs.mode="Set Time"
  gs.string=string.format("%d", Level.time)
  gs.hud=gs.SetTimeHud
end

gsEditor.SetTitleHud={
{{},{},{}},
{{},{
"Enter New Level Title",
"",
function() return gs.string end,
background={color="black", border="yellow", size="fit"}
},{}},
{{},{},{}},
}

gsEditor.SetTimeHud={
{{},{},{}},
{{},{
"Enter New Level Time Limit",
"",
function() return gs.string end,
background={color="black", border="yellow", size="fit"}
},{}},
{{},{},{}},
}

gsEditor.HelpHud={
{{},{},{}},
{{},{
"Editor Help",
"",
"F1: Return To Editor",
"F2: Select Tiles",
"+/-: Zoom In/Zoom Out",
"A/Z: Up/Down a Level",
"CTRL: Drag Map",
background={color="black", border="yellow", size="fit"}
},{}},
{{},{},{}},
}

gsEditor.OptionsMenuBuild=function()
  local result={}
  table.insert(result,
    {function() return "Title: "..Level.title end,
	gsEditor.SetTitle})
  table.insert(result,
    {function() return "Time Limit: "..Level.time end,
	gsEditor.SetTime})
  table.insert(result, 
    {function() return "Map Size: "..#Map.."x"..#Map[1].."x"..#Map[1][1] end,
	function() end})
  table.insert(result,
    {"Select Tiles (F2)", function() gs.KeyDown.F2() end})
  table.insert(result,
    {"Test (F5)        ", function() gs.KeyDown.F5() end})
  table.insert(result,
    {"Load (F6)        ", function() gs.KeyDown.F6() end})
  table.insert(result,
    {"Save (F7)        ", function() gs.KeyDown.F7() end})
  table.insert(result,
    {"Exit Editor (ESC)", function() gs.KeyDown.ESC() end})
  return result
end

gsEditor.KeyDown={
  DEFAULT=function(key)
    if gs.string then
	  if gs.mode=="Set Title" then
	    --lower case unless pressing Shift
	    if (not gs.Shift) and key>=65 and key<=90 then
	      key=key+32
	    end
	    if (key>=65 and key<=90) or (key==32)
	      or (key>=48 and key<=57) or (key>=97 and key<=122)
		  and #gs.string < MAXPLAYERNAME then
		    gs.string=gs.string..string.char(key)
	    end
	  elseif gs.mode=="Set Time" then
	    if (key>=48 and key<=57) then
		  gs.string=gs.string..string.char(key)
		  if #gs.string>3 then gs.string="999" end
		end
	  end
	end
  end,
  ESC=function()
    if gs.mode~="Edit" then
	  gs.Start()
	else
	  gsMenu.Start()
	end
  end,
  F1=function() 
    if gs.mode=="Help" then
	  gs.mode="Edit"
	  gs.hud=gs.MainHud
	elseif gs.mode=="Edit" then
	  gs.mode="Help"
	  gs.hud=gs.HelpHud
	end
  end,
  F2=function() 
    fxL.WriteLevel(Level,Map)
    gsParts.Start() 
  end,
  --F5=function() gsPregame.Start() end,
  CTRL=function() gs.Ctrl=true end,
  UP=function() 
      if gs.mode=="Edit" then
	    gs.menu:Select(gs.menu.pos-1)
	  end
    end,
  DOWN=function()
      if gs.mode=="Edit" then
	    gs.menu:Select(gs.menu.pos+1)
	  end
    end,
  ENTER=function()
    local opt=gs.menu.list[gs.menu.pos]
	if gs.mode=="Edit" and opt then 
	  opt.Choose(opt) 
	elseif gs.mode=="Set Title" then
	  fxL.WriteLevel(Level,Map)
	  Level.title=gs.string
	  gs.Start()
	elseif gs.mode=="Set Time" then
	  fxL.WriteLevel(Level,Map)
	  Level.time=gs.string
	  gs.Start()
	end
  end,
  A=function(key)
    if gs.mode=="Edit" then
      if gs.atZ<#Map[1][1] then gs.atZ=gs.atZ+1 end
	else
	  gs.KeyDown.DEFAULT(key)
	end
	end,
  Z=function(key)
    if gs.mode=="Edit" then
      if gs.atZ>1 then gs.atZ=gs.atZ-1 end
	else
	  gs.KeyDown.DEFAULT(key)	 
    end	  
	end,
  PLUS=function()
    gs.ZoomZ=math.max(gs.Cam.z-4, 4)
  end,
  MINUS=function()
    gs.ZoomZ=math.min(gs.Cam.z+4, 48)
  end,
  MWheelUp=function()
    gs.ZoomZ=math.min(gs.Cam.z+4, 48)
	local m = inL.mouse.map
	if m then gs.ZoomX, gs.ZoomY=m.x, m.y end
  end,
  MWheelDown=function()
    gs.ZoomZ=math.max(gs.Cam.z-4, 4)
	local m = inL.mouse.map
	if m then gs.ZoomX, gs.ZoomY=m.x, m.y end
  end,
  SHIFT=function()
    gs.Shift=true
  end,
  BACKSPACE=function()
    if gs.string and #gs.string>0 then
	  gs.string=string.sub(gs.string,1,#gs.string-1) 
	end
  end,
}

gsEditor.KeyUp={
  DEFAULT=function(key) end,
  CTRL=function() gs.Ctrl=false end,
  SHIFT=function() gs.Shift=false end,
}












