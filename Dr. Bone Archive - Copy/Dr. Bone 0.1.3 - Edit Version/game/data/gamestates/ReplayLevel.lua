-------------
--REPLAYLEVEL
-------------
ReplayLevel={camera=GameCamera}
ReplayLevel.ID="ReplayLevel"

ReplayLevel.Start=function()
  map=ParseMap(level)
  InitMap(map)
  ReplayLevel.CurrentDeck=level.CurrentDeck
  ReplayLevel.hud=ReplayLevel.mainhud
  tick,event,event2=0,0,0
  if level.time>0 then
    ReplayLevel.time=level.time*60
  else
    ReplayLevel.time=nil
  end
  ReplayLevel.score=0
  ReplayLevel.index=0
  gamestate=ReplayLevel
  math.randomseed(replay.seed)
end

ReplayLevel.render=function()
  MapRender(map)
  drawhud(ReplayLevel.hud, TEXTSIZE)
  FlipScreen()  
end

ReplayLevel.KeyDown={
  ESC=function() PauseState.Start() end,
}

ReplayLevel.SetWin=function(message)
  if message==nil then message="You Win" end
  WinState.Start(message)
end

ReplayLevel.SetLose=function(message)
  if message==nil then message="You Lose" end
  LoseState.Start(message)
end

ReplayLevel.OnTimer=function()
  tick=tick+1
  if (ReplayLevel.index<#replay.list) and
     (tick==replay.list[ReplayLevel.index+1][1]) then
	   ReplayLevel.index=ReplayLevel.index+1
	   event=replay.list[ReplayLevel.index][2]
	   event2=replay.list[ReplayLevel.index][3]
  end
  
  while true do
    if #Pending==0 then break end
	Pending[1]:logic(event)
  end
  
  -- game timer
  if ReplayLevel.time then
    ReplayLevel.time=ReplayLevel.time-1
	if math.floor(ReplayLevel.time/60)==0 then
	  ReplayLevel.SetLose("Out Of Time!")
	end
  end
  Pending,Complete=Complete,Pending   -- swap lists
end

ReplayLevel.mainhud={
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
"Replay Running.",
"Press ESC to pause."
},{
function()
  if ReplayLevel.time then 
    return "Time: "..string.format("%5d",math.floor(ReplayLevel.time/60))
  else 
    return "Time: "..string.format("%5d", 0)
  end
end,
function() return "Score: "..string.format("%5d",ReplayLevel.score) end,
}},
{{},{},{}},
{{},{},{}},
}