-------------
--PLAYLEVEL
-------------

PlayLevel={camera=GameCamera}
PlayLevel.ID="PlayLevel"

PlayLevel.Start=function()
  map=ParseMap(level)
  InitMap(map)
  PlayLevel.CurrentDeck=level.CurrentDeck
  PlayLevel.hud=PlayLevel.mainhud
  tick, event, event2 = 0,0,0
  
  if level.time>0 then
	PlayLevel.time=level.time*60
  else
    PlayLevel.time=nil
  end
  
  PlayLevel.score=0
  gamestate=PlayLevel  
  
  --start recording the replay
  replay={
    list={},
	seed=os.time(),
	date=os.date(),
	playername=CurrentAccount.name,
	playerguid=CurrentAccount.guid,
	levelname=level.title,
	levelguid=level.guid,
	guid=GenerateGuid(),
  }
  replay_event, replay_event2=0,0
  math.randomseed(replay.seed)
end

PlayLevel.keysdown={0,0,0,0}

PlayLevel.KeyDown={
  F5=function() 
      if Pregame.mode=="Menu" then
        local l=CurrentAccount.levels[level.guid]
	    l.deaths=l.deaths+1
	    SelectPlayer.WriteAccounts()
	  end
      Pregame.Start() 
  end,
  ESC=function() PauseState.Start() end,
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

PlayLevel.render=function()
  MapRender(map)
  drawhud(PlayLevel.hud,TEXTSIZE)
  FlipScreen()
end

PlayLevel.SetWin=function(message)
  if message==nil then message="You Win" end
  WinState.Start(message)
end

PlayLevel.SetLose=function(message)
  if message==nil then message="You Lose" end
  LoseState.Start(message)
end

PlayLevel.OnTimer=function()
  tick=tick+1
  --record the replay
  if (#replay.list==0) or    --if the replay has no entries, or
    (replay.list[#replay.list][2]~=event) or --if event has changed, or
	(replay.list[#replay.list][3]~=event2) then --if event 2 has changed
	table.insert(replay.list, {tick, event, event2}) --append the next entry
  end
  
  while true do
    if #Pending==0 then break end
    Pending[1]:logic(event)
  end
  -- game timer
  if PlayLevel.time then
    PlayLevel.time=PlayLevel.time-1
	if math.floor(PlayLevel.time/60)==0 then
	  PlayLevel.SetLose("Out Of Time!")
	end
  end
  Pending,Complete=Complete,Pending   -- swap lists
end

--[[
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
]]

PlayLevel.mainhud={
{{
function()
  local disk="d2982f8c-6935-4129-9744-dcddfd11a6ba"
  if Globals[disk] then
    return "Disks left: "..Globals[disk]
  else
    return ""
  end
end,
},{
function()
  if Pregame.mode=="Editor" then
    return "Level Test"
  else
    return ""
  end
end,
},{
function()
  if PlayLevel.time then 
    return "Time: "..string.format("%5d",math.floor(PlayLevel.time/60))
  else 
    return "Time: "..string.format("%5d", 0)
  end
end,
function() return "Score: "..string.format("%5d",PlayLevel.score) end,
}},
{{},{},{}},
{{},{},{}},
}