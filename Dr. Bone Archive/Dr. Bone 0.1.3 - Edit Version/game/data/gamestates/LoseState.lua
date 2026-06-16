-------------
--LOSESTATE
-------------
LoseState={camera=GameCamera}
LoseState.ID="LoseState"

LoseState.Start=function(message)

  --save for hud display
  if gamestate.time then LoseState.time=math.floor(gamestate.time/60)
  else LoseState.time=0 end
  LoseState.score=gamestate.score
  
  LoseState.message=message
  LoseState.hud=LoseState.mainhud
  LoseState.CurrentDeck=gamestate.CurrentDeck
  LoseState.calling=gamestate.ID --save the name of the calling gamestate
  
  if LoseState.calling=="PlayLevel" and Pregame.mode=="Menu" then
    local l=CurrentAccount.levels[level.guid]
    if l then
	  l.deaths=l.deaths+1
    end
	SelectPlayer.WriteAccounts()
  end
  gamestate=LoseState
end

LoseState.Stop=function()
  if Pregame.mode=="Editor" then
    Editor.Start()
  elseif Pregame.mode=="Menu" then								
    Menu.Start()
  elseif Pregame.mode=="PlaySet" then
    PlaySet.Start()
  end
end

LoseState.KeyDown={
  ENTER=function() Pregame.Start() end,
  ESC=LoseState.Stop,
}

LoseState.KeyUp=PlayLevel.KeyUp

LoseState.render=function()
  MapRender(map)
  drawhud(LoseState.hud, TEXTSIZE)
  FlipScreen()
end



LoseState.mainhud={
{{
  function()
    local disk="d2982f8c-6935-4129-9744-dcddfd11a6ba"
      if Globals[disk] then
        return "Disks left: "..Globals[disk]
      else
        return ""
      end
  end,
},
{},
{
  function() return "Time: "..string.format("%5d",gamestate.time) end,
  function() return "Score: "..string.format("%5d", gamestate.score) end,
}},
{{},{
function() return LoseState.message end,
"",
"Press ENTER to restart",
"or ESC to exit",
"",
function()
  if LoseState.calling=="ReplayLevel" then
    return MakeClickableText("View Replay Again", NMTCOLOR, MTCOLOR, function() PreReplay.Start() end, nil)
  else
    return ""
  end
end
},{}},
{{},{},{}},
}