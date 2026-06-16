-------------
--EDITOR
-------------

Editor={camera={x=0,y=0,z=20}}

Editor.ID="Editor"

Editor.SetTitle=function()
	Editor.flag="Set Title"
	GetString.Start("Enter New Level Title", level.title)
end

Editor.SetTime=function()
    Editor.flag="Set Time"
	GetString.Start("Enter New Time Limit", ""..level.time, true)
end
												 
Editor.StartTest=function()
  Editor.savemap()
  --stop=Editor.Start
  --postwin=Editor.Start
  Pregame.Start()
end

Editor.Start=function()
  ClipMap=false
  tick=0
  gamestate=Editor                              -- capture the game events
  Editor.hud=Editor.mainhud
  if level==nil then
    Help=false
	level=GenerateLevel()
    map=ParseMap(level)
    Editor.CurrentDeck=level.CurrentDeck
    Editor.camera={y=(#map[1]/2)+.5,x=(#map/2)+.5,z=20}
  else
    if Editor.flag=="Set Title" then
		Editor.flag=nil
		level.title=GetString.string
	elseif Editor.flag=="Set Time" then
	    Editor.flag=nil
		level.time=math.min(0+GetString.string,MAXTIME)
	else
		Editor.CurrentDeck=level.CurrentDeck
		if level.lastcamera then Editor.camera=level.lastcamera end
		map=ParseMap(level)
	end
  end
end

Editor.render=function()
  MapRender(map)
  RenderCursor()
  drawhud(Editor.hud,19)
  FlipScreen()
end

Editor.OnTimer=function()
  tick=tick+1 --animate force floors
end

Editor.savemap=function()
  if Help==true then
    Editor.hud=Editor.mainhud
    Help=false
  end
  EncodeLevel(level,map)
end

Editor.Exit=function()
  if CheckDirty() then
    level=nil
    map=nil	
    Menu.Start() 
    return true 
  end  --always start main Menu on Editor Exit
  return false
end

--[[
Editor.replay=function()
  if replay~=nil and level~=nil then
    Editor.savemap()
    Pregame.Start()
    --stop=Editor.Start
    --win=Editor.Start
    --lose=Editor.Start
    replay_speed=1
    ReplayLevel.Start()
  end
end]]

Editor.KeyDown={
  DEFAULT=function(key)
    if key==49 then
      Editor.savemap()
      Parts.Start(1)                           -- show parts page
    end
    return
  end,
  
  A=function()
	if Editor.CurrentDeck < #map[1][1] then
	  Editor.CurrentDeck = Editor.CurrentDeck + 1
	end
  end,
	
  Z=function()
	if Editor.CurrentDeck > 1 then
	  Editor.CurrentDeck = Editor.CurrentDeck - 1
	end
  end,

  UP=function()
    local fcn=Parts.left.item.EditorShuffle
    if fcn then fcn(Parts.left.item,1) end
  end,
  
  DOWN=function()
    local fcn=Parts.left.item.EditorShuffle
    if fcn then fcn(Parts.left.item,-1) end
  end,

  LEFT=function()
    local fcn1=Parts.left.item.EditorRotate
    local fcn2=Parts.right.item.EditorRotate
    if fcn1 then fcn1(Parts.left.item,-1) end
    if fcn2 then fcn2(Parts.right.item,-1) end
  end,
 
  RIGHT=function()
    local fcn1=Parts.left.item.EditorRotate
    local fcn2=Parts.right.item.EditorRotate
    if fcn1 then fcn1(Parts.left.item,1) end
    if fcn2 then fcn2(Parts.right.item,1) end
  end,

  PLUS=function()
    if Editor.camera.z>5 then Editor.camera.z=Editor.camera.z-.5 end
  end,

  MINUS=function()
    if Editor.camera.z<80 then Editor.camera.z=Editor.camera.z+.5 end
  end,
    
  F1=function()
    Help=not Help
	if Help then Editor.hud=Editor.helphud
	else Editor.hud=Editor.mainhud
	end
    return
  end,

  F5=Editor.StartTest,

  F6=function()
    if AskLoadMap() then
      Editor.camera={x=(#map+1)/2,y=(#map[1]+1)/2,z=20}
    end
  end,

  ESC=Editor.Exit,

  F7=function()
    AskSave()
  end,

  F9=function()
    Editor.replay()
    return
  end,
 
--f2 load and play levelset    f3 load and play level    f4 level editor
--f5 start play    f6 load level    f7 save level    f8 resume
--f9 start replay    f11 load replay    f12 save replay

------------------------------------
--  F2=function() if Editor.Exit()==true then Menu.LoadAndPlayLevelSet() end end,
  F3=function() Editor.KeyDown.F6() end,
--  F8=function() if resume~=nil then gamestate=resume end end,
  F11=function() PlaylevelLoadReplay() end,
  F12=function() SaveReplay() end,
------------------------------------

  CTRL=function() CtrlDown=true mousemap=nil SetMousePosition(mouse.x,mouse.y) end,
}

Editor.KeyUp={
  CTRL=function() CtrlDown=false mousemap={} SetMousePosition(mouse.x,mouse.y) end,
}

Editor.PaintLeft=PaintLeft
Editor.PaintRight=PaintRight

Editor.resizehud={
{{
function() 
  return #map.."x"..#map[1].."x"..#map[1][1] end
},{
MakeClickableText("y+",NMTCOLOR, MTCOLOR,inctop,nil),
MakeClickableText("y-",NMTCOLOR, MTCOLOR,dectop,nil),
},{Parts.right}},
{{
MakeClickableText("x+",NMTCOLOR, MTCOLOR,incleft,nil),
MakeClickableText("x-",NMTCOLOR, MTCOLOR,decleft,nil),
},{
MakeClickableText("z+ (above)",NMTCOLOR, MTCOLOR,incabove,nil),
MakeClickableText("z- (above)",NMTCOLOR, MTCOLOR,decabove,nil),
MakeClickableText("z+ (below)",NMTCOLOR, MTCOLOR,incbelow,nil),
MakeClickableText("z- (below)",NMTCOLOR, MTCOLOR,decbelow,nil),
},{
MakeClickableText("x+", NMTCOLOR, MTCOLOR,incright,nil),
MakeClickableText("x-", NMTCOLOR, MTCOLOR,decright,nil),
}},
{{},{
MakeClickableText("y+",NMTCOLOR, MTCOLOR,incbottom,nil),
MakeClickableText("y-",NMTCOLOR, MTCOLOR,decbottom,nil),
},{
MakeClickableText("Return",NMTCOLOR, MTCOLOR,function()
                              Editor.hud=Editor.mainhud
							  end,nil)
}}}


Editor.mainhud={
{{Parts.left},{
function() 
  if mousemap and 
     (mousemap.x>0 and mousemap.x<=#map) and
	 (mousemap.y>0 and mousemap.y<=#map[1]) then 
    return mousemap.x.."."..mousemap.y.."."..gamestate.CurrentDeck
  else
    return ""
  end
end
},{Parts.right}},
{{},{},{}},
{{MakeClickableText("Tiles", NMTCOLOR, MTCOLOR, function() Editor.KeyDown.DEFAULT(49) end, nil)},{},
{MakeClickableText("Options", NMTCOLOR, MTCOLOR, function()
													Editor.hud=Editor.optionshud
												 end, nil)}}}

Editor.optionshud={
{{},{
MakeClickableText(function() return "Title: "..level.title end, NMTCOLOR, MTCOLOR, Editor.SetTitle, nil),
MakeClickableText(function() return "Time Limit: "..level.time end, NMTCOLOR, MTCOLOR, Editor.SetTime, nil),
MakeClickableText(function() return "Map Size: "..#map.."x"..#map[1].."x"..#map[1][1] end, NMTCOLOR, MTCOLOR, function() 
		 Editor.hud=Editor.resizehud
         end, nil),
MakeClickableText("Set Hints", NMTCOLOR, MTCOLOR, function() Editor.savemap() SetHint.Start() end, nil)
},{}},
{{},{
MakeClickableText("Test (F5)", NMTCOLOR, MTCOLOR, function() Editor.KeyDown.F5() end, nil),
MakeClickableText("Load (F6)", NMTCOLOR, MTCOLOR, function() Editor.KeyDown.F6() end, nil),
MakeClickableText("Save (F7)", NMTCOLOR, MTCOLOR, function() Editor.KeyDown.F7() end, nil),
MakeClickableText("Exit (ESC)", NMTCOLOR, MTCOLOR, function() Editor.KeyDown.ESC() end, nil),
},{}},
{{
MakeClickableText("Editor Help (F1)", NMTCOLOR, MTCOLOR, function() Editor.KeyDown.F1() end, nil),
},{},{
MakeClickableText("Close Options", NMTCOLOR, MTCOLOR, function() 
											Editor.hud=Editor.mainhud
											          end, nil),
}},
}

Editor.helphud={
{{
"1=Select Tiles",
"Left/Right=Rotate or Cycle Colors",
"Up/Down=Cycle Element Types", 
"CTRL=Drag Map",
"A/Z=Up/Down A Level",
"+/-=Zoom In/Out",
"Use the Yellow Ring Element to Connect Buttons",
"F5=Test level",
"F6=Load map",
"F7=Save map",
"ESC=Exit to Menu",
},{},{}},
{{},{},{}},
{{"F1=Toggle help"},{},{}}
}