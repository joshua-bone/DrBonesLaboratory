-------------
--WINSTATE
-------------
WinState={camera=GameCamera}
WinState.ID="WinState"

WinState.Start=function(message)

  --Level Scoring------------------------------------------
  WinState.BaseScore=gamestate.score
  if gamestate.time then
	WinState.TimeBonus=10*math.floor(gamestate.time/60)
  else
    WinState.TimeBonus=0
  end
  WinState.TotalScore=math.min(MAXSCORE, WinState.BaseScore+WinState.TimeBonus)
  ---------------------------------------------------------
  
  WinState.message=message
  WinState.hud=WinState.mainhud
  WinState.newRecord=nil
  WinState.CurrentDeck=gamestate.CurrentDeck
  WinState.calling=gamestate.ID --save the name of the calling gamestate

  
  if WinState.calling=="PlayLevel" and Pregame.mode=="Menu" then
    local l=CurrentAccount.levels[level.guid]
    if l then
  	  l.wins=l.wins+1
	  if WinState.TotalScore>l.bestScore then
	    l.bestScore=WinState.TotalScore
		WinState.newRecord=true
	  end
	  SelectPlayer.WriteAccounts()
    end
  end
  gamestate=WinState
end

WinState.Stop=function()
  if Pregame.mode=="Editor" then
    Editor.Start()
  elseif Pregame.mode=="Menu" then
    Menu.Start()
  elseif Pregame.mode=="PlaySet" then
    PlaySet.Start()
  end
end

WinState.KeyDown={
  ENTER=WinState.Stop,
  F5=function() Pregame.Start() end,
  --F11=function() SaveReplay() end,

--  F1=mainMenu.PlayLevel,
--  F2=mainMenu.StartEdit,
  --ESC=function() stop() end,
}

WinState.KeyUp=PlayLevel.KeyUp

WinState.render=function()
  MapRender(map)
  drawhud(WinState.hud, TEXTSIZE)
  FlipScreen()
end

WinState.CurrentDeck=1

WinState.saveReplay=function()
  local name=GetSaveFileName("Save replay", "DBL replay *.rpl\0*.rpl\0")
  if name and (not string.find(name, ".rpl")) then
    name=name..".rpl"
  end
  if name then
    replay.saved=true
    local file=io.open(name,"w")
	file:write("replay=")
	writers.table(file,replay,1)
	file:close()
  end
end

WinState.mainhud={
{{},{},{}},
{{},{
function() return WinState.message end,
"",
function() return " Base Score: "..string.format("%5d", WinState.BaseScore) end,
function() return " Time Bonus: "..string.format("%5d", WinState.TimeBonus) end,
function() return "Total Score: "..string.format("%5d", WinState.TotalScore) end,
function() 
  if WinState.newRecord then
    return MakeClickableText("New Personal Record! Good Job!", STCOLOR, STCOLOR, function() end,nil)
  else return ""
  end  
end,
function()
  if replay then
    if replay.saved then
	  if WinState.calling=="PlayLevel" then
	    return "Replay Saved!"
	  else
	    return ""
	  end
	else
	  return MakeClickableText("Save This Replay", NMTCOLOR, MTCOLOR, WinState.saveReplay, nil)
	end
  else
    return ""
  end
end,
MakeClickableText("Watch Replay", NMTCOLOR, MTCOLOR, function() PreReplay.Start() end, nil),
},{}},
{{},{
"Press any key to exit",
"or F5 to restart",
},{}},
}