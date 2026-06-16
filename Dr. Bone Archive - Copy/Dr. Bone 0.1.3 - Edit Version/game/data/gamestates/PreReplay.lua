-------------
--PreReplay
-------------

PreReplay={camera=GameCamera}
PreReplay.ID="PreReplay"


PreReplay.Start=function()
  local ID=gamestate.ID
  gamestate=PreReplay
  map=ParseMap(level)
  ClipMap=true
  tick=0
  monsterspeed=1/12
  PreReplay.hud=PreReplay.mainhud
end

PreReplay.KeyDown={
  DEFAULT=function()
    ReplayLevel.Start()
  end,   -- wait to start game
  ESC=function() Pregame.Start()  end,
}

PreReplay.render=function()
  MapRender(map)
  drawhud(PreReplay.hud,TEXTSIZE)
  FlipScreen()
end

PreReplay.CurrentDeck=1

PreReplay.hudtop={
  {
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
    function() return "Time: "..string.format("%5d",level.time) end,
    function() return "Score: "..string.format("%5d",0) end,
  }
}

PreReplay.mainhud={   --this is the hud used when playing a single level from the menu
PreReplay.hudtop,
{{},{
function() return "Replay by "..replay.playername end,
function() return "Date: "..replay.date end,
"",
function()
  if replay.levelguid ~= level.guid then
    return MakeClickableText("Warning: Possible Level Mismatch!", WTCOLOR, WTCOLOR, nil, nil)
  else
    return ""
  end
end,
"",
"Press any key to start replay",
"or ESC to exit",
},{}},
{{},{
MakeClickableText("Exit", NMTCOLOR, MTCOLOR, function() PreReplay.Stop() end, nil)
},{
MakeClickableText("(Load a Replay)", NMTCOLOR, MTCOLOR, function() end, nil)
}},
}



