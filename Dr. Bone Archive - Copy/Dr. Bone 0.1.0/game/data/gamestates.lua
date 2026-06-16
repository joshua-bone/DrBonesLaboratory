--GAMESTATES

-------------
--MENU
-------------
menu={}
menu.camera={x=0,y=0,z=20}
menu.Start=function() gamestate=menu end
menu.LoadAndPlayLevelSet=function() end
menu.LoadAndPlayLevel=function()
  if AskLoadMap() then
    stop=menu.Start
    postwin=menu.Start
    Pregame.Start()
  end
end

menu.replay=function()
  if replay~=nil and level~=nil then
    Pregame.Start()
    stop=menu.Start
    postwin=menu.Start
    replay_speed=1
    ReplayLevel.Start()
  end
end

menu.restart=function()
  if level==nil then
     Editor.KeyDown.F6()        -- load a level if none loaded
  end
  Pregame.Start()
  stop=menu.Start
  postwin=menu.Start
end

menu.KeyDown={
  F2=menu.LoadAndPlayLevelSet,
  F3=menu.LoadAndPlayLevel,
  F4=function() Editor.Start() end,
  F5=function() menu.restart() end,  -- start play from editor
  F6=function() Editor.Start() Editor.KeyDown.F6() end,  -- start editor and load level
  F7=function() AskSave() end,
  F8=function() if resume~=nil then gamestate=resume end end,
  F9=menu.replay,
  F11=function() PlaylevelLoadReplay() end,
  F12=function() SaveReplay() end,
  ESC=function() if close()~=0 then 
    quit() 
  end
  end,
}

menu.hud={
{{},{"","Dr. Bone's Laboratory","Main Menu"},{}},
{{},{
MakeClickableText("Load and Play a Level","red","green",menu.KeyDown.F3,nil),
MakeClickableText("Start the Editor","red","green",menu.KeyDown.F4,nil),
MakeClickableText("Quit Dr. Bone's Laboratory","red","green",menu.KeyDown.ESC,nil),
},{}},
{{},{},{}},
}

menu.render=function()
  RenderSolidBackground("black")
  drawhud(menu.hud,19)
end

menu.OnTimer=function()
  collectgarbage("collect")
end

-------------
--PREGAME
-------------

Pregame={camera=GameCamera}

Pregame.Start=function()
  PlayHud={{{},{},{}},{{},{},{}},{{},{},{}},}
  gamestate=Pregame
  map=ParseMap(level)
  ClipMap=true
end

Pregame.KeyDown={
  DEFAULT=function(key)
    PlayLevel.Start()
    KeyDown(key)
  end,   -- wait to start game
  F1=menu.LoadAndPlayLevelSet,
  F2=menu.LoadAndPlayLevel,
  F4=function() Editor.Start() end,
  F9=function() StartReplay() end,
  F11=function() PlaylevelLoadReplay() end,
  ESC=function() stop()  end,
}

Pregame.GetBottomMenu=function()
  result={
  MakeClickableText("Load Replay","yellow","green",Pregame.KeyDown.F11,nil),
  MakeClickableText("Exit","yellow","green",Pregame.KeyDown.ESC,nil),
  }
  if replay~=nil then table.insert(result,2,MakeClickableText("Start Replay","yellow","green",Pregame.KeyDown.F9,nil)) end
  return result
end

Pregame.hud={
{PlayHud[1][1],{"","Press arrow keys to Begin"},{}},
{{},function() return {level.title,level.author,level.date} end,{}},
{{},Pregame.GetBottomMenu,{}},
}

Pregame.render=function()
  MapRender(map)
  drawhud(Pregame.hud,19)
end

Pregame.CurrentDeck=1

-------------
--PARTS
-------------

Parts={left={},right={},camera={x=0,y=0,z=20}} 

PartsHud={   --SHOULD BE PART OF PARTS GAMESTATE BUT IT ISN'T, NEED TO FIX
{{Parts.left},{"Parts","Left and right click to select part"},{Parts.right}}
,{{},{},{}}
,{{},{},{
MakeClickableText("Exit","yellow","green",function() Editor.Start()() end,nil),
}}
}

Parts.Start=function(page)
  gamestate=Parts                              -- capture the game events
  BuildParts(page)
  Parts.camera={y=(#map[1]/2)+.5,x=(#map/2)+.5,z=20}
  Parts.CurrentDeck=1
end

Parts.render=function()
  MapRender(map)
  RenderCursor()
  drawhud(PartsHud,19)
end

Parts.PaintLeft=GrabLeft
Parts.PaintRight=GrabRight

Parts.KeyDown={
  DEFAULT=function(key)
    Editor.Start()
    return
  end,
}


-------------
--EDITOR
-------------

Editor={camera={x=0,y=0,z=20}}

Editor.LowerLeft=function()
  result={
  MakeClickableText("Test","yellow","green",function() Editor.StartTest() end,nil),
  MakeClickableText("Exit","yellow","green",function() Editor.Exit() end,nil),
  }
  if level.modified==true then
    table.insert(result,1,MakeClickableText("Save","yellow","green",function() AskSave() end,nil))
  end
  return result
end

Editor.Hud={
{{Parts.left},{},{Parts.right}},
{{},{},{}},
{Editor.LowerLeft,{},{
MakeClickableText(function() return #map.."x"..#map[1].."x"..#map[1][1] end,"yellow","green",function() ToggleDimensions() end,nil),
MakeClickableText("Parts","yellow","green",function() StartParts(1) end,nil),
}}
}

Editor.HelpHud={
{{
"Editor Help",
"1=Parts page 1",
"<>=Rotate Selected Object",
"spacebar=Shuffle between object types", 
"F5=Test level",
"F6=Load map",
"F7=Save map",
"ESC=Quit Puzzle Studio",
"CTRL=Drag",
},{},{}},
{{},{},{}},
{{"F1=Toggle help"},{},{}}
}

Editor.StartTest=function()
--  PlayHud[1][2]["type"]="Test level"
  Editor.savemap()
  stop=Editor.Start
  postwin=Editor.Start
  Pregame.Start()
end

Editor.Start=function()
  ClipMap=false
  stop=menu.Start
  tick=0
  gamestate=Editor                              -- capture the game events
  if level==nil then
    Help=false
    LoadMap(WD..MAPPATH)
    map=ParseMap(level)
    Editor.CurrentDeck=level.CurrentDeck
    Editor.camera={y=(#map[1]/2)+.5,x=(#map/2)+.5,z=20}
  else
    Editor.CurrentDeck=level.CurrentDeck
    if level.lastcamera then Editor.camera=level.lastcamera end
    map=ParseMap(level)
  end
end

Editor.render=function()
  MapRender(map)
  RenderCursor()
  drawhud(Editor.Hud,19)
end

Editor.savemap=function()
  if Help==true then
    Editor.Hud,Editor.HelpHud=Editor.HelpHud,Editor.Hud
    Help=false
  end
  EncodeLevel(level,map)
end

Editor.Exit=function()
  if CheckDirty() then stop() return true end
  return false
end

Editor.replay=function()
  if replay~=nil and level~=nil then
    Editor.savemap()
    Pregame.Start()
    stop=Editor.Start
    win=Editor.Start
    lose=Editor.Start
    replay_speed=1
    ReplayLevel.Start()
  end
end

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
    Editor.Hud,Editor.HelpHud=Editor.HelpHud,Editor.Hud
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
--  F2=function() if Editor.Exit()==true then menu.LoadAndPlayLevelSet() end end,
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

-------------
--PLAYLEVEL
-------------

PlayLevel={camera=GameCamera}

PlayLevel.SetLose=function(message)
  event=0 -- release the event
  if message==nil then message="You Lose" end
  PlayHud[2][2]={message}
  gamestate=LoseState
end

PlayLevel.SetWin=function(message)
  event=0 -- release the event
  if message==nil then message="You Win" end
  PlayHud[2][2]={message}
  if gamestate==PlayLevel then
    replay.date=os.date()
    PlayHud[2][2][2]=replay.date
    PlayHud[2][2][3]=MakeClickableText("Save replay","yellow","green",function() SaveReplay() end,nil)
  end
  gamestate=WinState
end

PlayLevel.GenericStart=function()
  map=ParseMap(level)
  InitMap(map)          -- init the map for play
  tick=0
  event=0  
  --monsterspeed=1/12
  replay_count=0
  lose=PlayLevel.SetLose
  win=PlayLevel.SetWin
  ClipMap=true
  level.score=0
  if origtime~=nil then
    level.time=origtime-60
end
  if level.time~=nil then
    level.time=level.time+60
    origtime=level.time
  end
end

PlayLevel.Start=function()
  PlayLevel.GenericStart()
  replay={}
  replay.list={}
  replay.seed=os.time()
  replay_event=0
  gamestate=PlayLevel
  resume=PlayLevel
  restart=function() Pregame.Start() end
end

PlayLevel.render=function()
  MapRender(map)
  drawhud(PlayHud,19)
end

PlayLevel.keysdown={0,0,0,0}

PlayLevel.KeyDown={
--  F1=mainmenu.PlayLevel,
--  F2=mainmenu.StartEdit,
  F5=function() Pregame.Start() end,
  ESC=function() gamestate=PauseState end,
  LEFT=function() PlayLevel.keysdown[1]=1 event="W" return end,
  UP=function() PlayLevel.keysdown[2]=1 event="N" return end,
  RIGHT=function() PlayLevel.keysdown[3]=1 event="E" return end,
  DOWN=function() PlayLevel.keysdown[4]=1 event="S" return end,
}

PlayLevel.CheckUp=function()
  if (PlayLevel.keysdown[1]+PlayLevel.keysdown[2]+PlayLevel.keysdown[3]+PlayLevel.keysdown[4])==0 
  then event=0 end
end

PlayLevel.KeyUp={
  LEFT=function() PlayLevel.keysdown[1]=0 PlayLevel.CheckUp() return end,
  UP=function() PlayLevel.keysdown[2]=0 PlayLevel.CheckUp() return end,
  RIGHT=function() PlayLevel.keysdown[3]=0 PlayLevel.CheckUp() return end,
  DOWN=function() PlayLevel.keysdown[4]=0 PlayLevel.CheckUp() return end,
}

PlayLevel.OnTimer=function()
-- record replay
  if replay_event~=event then
    local i=#replay.list
    replay.list[i+1]=replay_event
    replay.list[i+2]=replay_count
    replay_event=event
    replay_count=0
  end
  replay_count=replay_count+1
  local save_replay=replay  -- save it because logic might reload
  DoLogic()
  replay=save_replay
  if gamestate~=PlayLevel then
    local i=#replay.list
    replay.list[i+1]=replay_event
    replay.list[i+2]=replay_count  -- final count
  end
end

PlayLevel.CurrentDeck=1

-------------
--REPLAYLEVEL
-------------
ReplayLevel={camera=GameCamera}

ReplayLevel.Start=function()
  PlayLevel.GenericStart()
  PlayHud[1][2]={"Replay",level.title}
  PlayHud[2][2]={}
  PlayHud[3][2]={}
  gamestate=ReplayLevel
  resume=ReplayLevel
  restart=function() ReplayLevel.Start() end
  math.randomseed(replay.seed)  --seed the random number generator
  replay_index=1
end

ReplayLevel.render=PlayLevel.render

ReplayLevel.KeyDown={
  ESC=function() gamestate=PauseState end,
}

ReplayLevel.OnTimer=function()
  local i
  for i=1,replay_speed do
  -- playback replay
    while replay_count==0 and replay_index<#replay.list do
      replay_event=replay.list[replay_index]
      replay_count=replay.list[replay_index+1]  
      replay_index=replay_index+2
    end
    replay_count=replay_count-1
    event=replay_event
    DoLogic()
  end
end

-------------
--WINSTATE
-------------
WinState={camera=GameCamera}

WinState.KeyDown={
  DEFAULT=function(key)
    if event~=0 then return end   -- disable auto repeate
    postwin()
  end,
  F11=function() SaveReplay() end,

--  F1=mainmenu.PlayLevel,
--  F2=mainmenu.StartEdit,
  ESC=function() stop() end,
}

WinState.KeyUp=PlayLevel.KeyUp
WinState.render=PlayLevel.render
WinState.CurrentDeck=1

-------------
--LOSESTATE
-------------
LoseState={camera=GameCamera}

LoseState.KeyDown={
  DEFAULT=function(key)
    if event~=0 then return end   -- disable auto repeate
    Pregame.Start()
  end,
  F1=menu.LoadAndPlayLevelSet,
  F2=menu.LoadAndPlayLevel,
  F4=function() Editor.Start() end,
  F5=function() restart() end,
  F9=function() StartReplay() end,
  F11=function() PlaylevelLoadReplay() end,
  ESC=function() stop() end,
}

LoseState.KeyUp=PlayLevel.KeyUp
LoseState.render=PlayLevel.render
LoseState.CurrentDeck=1

-------------
--PAUSESTATE
-------------
PauseState={camera=GameCamera}

PauseState.hud={
{{},{"","Paused"},{}},
{{},
{
MakeClickableText("Resume","yellow","green",function() gamestate=resume end,nil),
MakeClickableText("Restart","yellow","green",function() Pregame.Start() end ,nil),
MakeClickableText("Quit","yellow","green",function() stop() end,nil),
},
{}},
{{},{},{}},
}

PauseState.render=function()
  MapRender(map)
  drawhud(PauseState.hud,19)
end

PauseState.Start=function()
  gamestate=PauseState
end

PauseState.KeyDown={
  DEFAULT=function(key) gamestate=resume KeyDown(key) end,
  F5=function() restart() end,
  ESC=function() stop() end,
}

PauseState.CurrentDeck=1

