-------------
--PAUSESTATE
-------------
PauseState={camera=GameCamera}
PauseState.ID="PauseState"
PauseState.CurrentDeck=1

PauseState.Start=function()
  --PauseState.CurrentDeck=gamestate.CurrentDeck
  PauseState.Resume=gamestate
  gamestate=PauseState
end

PauseState.Stop=function()
  if Pregame.mode=="Editor" then
    Editor.Start()
  elseif Pregame.mode=="Menu" then 
    if PauseState.Resume.ID=="PlayLevel" then
      local l = CurrentAccount.levels[level.guid]
	  l.deaths=l.deaths+1
	end
    level,map=nil,nil  
    Menu.Start()
  elseif Pregame.mode=="PlaySet" then
    PlaySet.Start()
  end
end

PauseState.render=function()
  RenderSolidBackground(BKGDCOLOR)
  drawhud(PauseState.hud,TEXTSIZE)
  FlipScreen()
end



PauseState.KeyDown={
  DEFAULT=function(key) 
    gamestate=PauseState.Resume 
	if gamestate.ID=="PlayLevel" then KeyDown(key) end
  end,
  F5=function() 
      if Pregame.mode=="Menu" then
        local l=CurrentAccount.levels[level.guid]
	    l.deaths=l.deaths+1
	    SelectPlayer.WriteAccounts()
	  end
	  Pregame.Start() 
	end,
  ESC=function() PauseState.Stop() end,
}

PauseState.hud={
{{},{"","Paused"},{}},
{{},
{
MakeClickableText("Resume",NMTCOLOR, MTCOLOR,function() gamestate=PauseState.Resume end,nil),
MakeClickableText("Restart",NMTCOLOR, MTCOLOR,function() PauseState.KeyDown.F5() end ,nil),
MakeClickableText("Quit",NMTCOLOR, MTCOLOR,function() PauseState.Stop() end,nil),
},
{}},
{{},{},{}},
}