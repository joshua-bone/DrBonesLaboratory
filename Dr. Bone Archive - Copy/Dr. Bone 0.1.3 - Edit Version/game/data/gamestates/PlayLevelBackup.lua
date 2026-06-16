-------------
--PLAYLEVEL
-------------

PlayLevel.hud={{{},{},{}},{{},{},{}},{{},{},{}},}

CheckReplay=function()
  local idx=2
  if replay~=nil then
     PlayLevel.hud[3][2][2]=MakeClickableText("Start Replay","yellow","green",StartReplay,nil)
     idx=3
  end
  PlayLevel.hud[3][2][idx]=MakeClickableText("Exit","yellow","green",function() stop() end,nil)
end

PlaylevelLoadReplay=function()
  LoadReplay()
  CheckReplay()
end

SaveReplay=function()
  if replay~=nil then
    local name=GetSaveFileName("Save Replay","lua *.lua\0*.lua\0All *.*\0*.*\0")
    if name~=nil then
      local file=io.open(name,"w")
      file:write("replay=")
      writers.table(file,replay,1)
      file:close()
      PlayLevel.hud[2][2][3]="Replay saved" -- indicate saved
    end
  end
end

LoadReplay=function()
    local name=GetOpenFileName("Open Replay","lua *.lua\0*.lua\0All *.*\0*.*\0")
  if name~=nil then
     dofile(name)
  end
end

DoLogic=function()
-- run the game
  tick=tick+1
  while true do
    if #Pending==0 then break end
    Pending[1]:logic(event)
  end
  -- game timer
  if level.time~=nil then
    if level.time~=0 then
      level.time=level.time-1
      PlayLevel.hud[1][1]["time"]="Time:"..math.floor(level.time/60)
      if level.time==0 then
        lose()
      end
    end
  end
  Pending,Complete=Complete,Pending   -- swap lists
end

PlayLevel={camera=GameCamera}

PlayLevel.SetLose=function(message)
  event=0 -- release the event
  event2=0
  if message==nil then message="You Lose" end
  PlayLevel.hud[2][2]={message}
  gamestate=LoseState
end

PlayLevel.SetWin=function(message)
  event=0 -- release the event
  event2=0
  if message==nil then message="You Win" end
  PlayLevel.hud[2][2]={message}
  if gamestate==PlayLevel then
    replay.date=os.date()
    PlayLevel.hud[2][2][2]=replay.date
    PlayLevel.hud[2][2][3]=MakeClickableText("Save replay","yellow","green",function() SaveReplay() end,nil)
  end
  gamestate=WinState
end

PlayLevel.GenericStart=function()
  map=ParseMap(level)
  InitMap(map)          -- init the map for play
  tick=0
  event=0  
  event2=0
  --monsterspeed=1/12
  replay_count=0
  lose=PlayLevel.SetLose
  win=PlayLevel.SetWin
  ClipMap=true
  --level.score=0
  if level.time>0 then PlayLevel.time=level.time 
  else PlayLevel.time=nil
  end
end

PlayLevel.Start=function()
  PlayLevel.GenericStart()
  replay={}
  replay.list={}
  replay.seed=os.time()
  math.randomseed(replay.seed)
  replay_event=0
  gamestate=PlayLevel
  resume=PlayLevel
  restart=function() Pregame.Start() end
end

PlayLevel.render=function()
  MapRender(map)
  drawhud(PlayLevel.hud,19)
  FlipScreen()
end

PlayLevel.keysdown={0,0,0,0}

PlayLevel.KeyDown={
--  F1=mainMenu.PlayLevel,
--  F2=mainMenu.StartEdit,
  F5=function() Pregame.Start() end,
  ESC=function() gamestate=PauseState end,
  LEFT=function() 
	PlayLevel.keysdown[1]=1
	if event~="W" then
		if event~= 0 then event2="W"
		else event="W" 
		end 
	end
	return end,
  UP=function() 
    PlayLevel.keysdown[2]=1
	if event~="N" then
		if event~= 0 then event2="N"
		else event="N" 
		end 
	end
  return end,
  RIGHT=function() 
    PlayLevel.keysdown[3]=1 
    if event~="E" then
		if event~= 0 then event2="E"
		else event="E" 
		end 	
	end
  return end,
  DOWN=function() 
  PlayLevel.keysdown[4]=1 
	if event~="S" then
		if event~= 0 then event2="S"
		else event="S" 
		end 
	end
  return end,
}

PlayLevel.CheckUp=function()
  if (PlayLevel.keysdown[1]+PlayLevel.keysdown[2]+PlayLevel.keysdown[3]+PlayLevel.keysdown[4])==0 
  then event=0 event2=0 end
end

PlayLevel.KeyUp={
  LEFT=function() 
	PlayLevel.keysdown[1]=0 
	if event=="W" then event=event2 event2=0 end
	if event2=="W" then event2=0 end
	PlayLevel.CheckUp() 
  return end,
  UP=function() 
    PlayLevel.keysdown[2]=0 
	if event=="N" then event=event2 event2=0 end
	if event2=="N" then event2=0 end	
	PlayLevel.CheckUp()  
  return end,
  RIGHT=function() 
    PlayLevel.keysdown[3]=0 
	if event=="E" then event=event2 event2=0 end
	if event2=="E" then event2=0 end
	PlayLevel.CheckUp() 
  return end,
  DOWN=function() 
    PlayLevel.keysdown[4]=0
    if event=="S" then event=event2 event2=0 end	
	if event2=="S" then event2=0 end	
	PlayLevel.CheckUp()
  return end,
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