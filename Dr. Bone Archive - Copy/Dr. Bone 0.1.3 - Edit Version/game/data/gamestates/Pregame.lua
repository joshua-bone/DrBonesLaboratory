-------------
--PREGAME
-------------

Pregame={camera=GameCamera}
Pregame.ID="Pregame"


Pregame.Start=function()
--[[the Pregame gamestate is responsible for saving the information about 
the mode of play, e.g. whether we are testing a level from the editor,
playing a single level from file, or playing a level as part of a set.
This will be stored in Pregame.mode as the name of the calling gamestate,
e.g. "Menu", "Editor", or "PlaySet"
]]
  local ID=gamestate.ID
  if ID=="Menu" then
    Pregame.hud=Pregame.mainhud
	Pregame.mode=ID
	local guid=level.guid
    local levels=CurrentAccount.levels
	if not levels[guid] then
	  levels[guid]={
	    deaths=0,
		wins=0,
		bestScore=0,
		style=0,
		puzzle=0,
		action=0,
		replays={}
		}
	end
  elseif ID=="Editor" then
    Pregame.mode=ID
    Pregame.hud=Pregame.testhud
  elseif ID=="PlaySet" then
    Pregame.hud=Pregame.levelsethud
	Pregame.mode=ID
  end
  gamestate=Pregame
  map=ParseMap(level)
  ClipMap=true
  tick=0
  monsterspeed=1/12
end

Pregame.Stop=function()
  if Pregame.mode=="Editor" then
    Editor.Start()
  elseif Pregame.mode=="Menu" then
    level,map=nil,nil
    Menu.Start()
  elseif Pregame.mode=="PlaySet" then
    PlaySet.Start()
  end
end

Pregame.KeyDown={
  DEFAULT=function(key)
    PlayLevel.Start()
    KeyDown(key)
  end,   -- wait to start game
  ESC=function() Pregame.Stop()  end,
}

Pregame.render=function()
  MapRender(map)
  drawhud(Pregame.hud,TEXTSIZE)
  FlipScreen()
end

Pregame.CurrentDeck=1

Pregame.loadReplay=function()
  local name=GetOpenFileName("Open Replay", "DBL replay *.rpl\0*.rpl\0")
  if name then dofile(name) end
  if replay then PreReplay.Start() end
end

Pregame.hudtop={
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

Pregame.testhud={  --this is the hud used when testing a level from the editor
Pregame.hudtop,
{{},{
function() return level.title end,
function() return "by "..level.author end,
"Level Test",
},{}},
{{},{
MakeClickableText("Exit", NMTCOLOR, MTCOLOR, function() Pregame.Stop() end, nil)
},{
MakeClickableText("(Load a Replay)", NMTCOLOR, MTCOLOR, function() end, nil)
}},
}

Pregame.mainhud={   --this is the hud used when playing a single level from the menu
Pregame.hudtop,
{{},{
function() return level.title end,
function() return "by "..level.author end,
"","","","",
function()
  local l=CurrentAccount.levels[level.guid]
  if l.wins+l.deaths>0 then
    return (l.wins+l.deaths).." attempts, "..l.wins.." wins"
  else return ""
  end
end,
function() 
  local l = CurrentAccount.levels[level.guid].bestScore
  if l and l>0 then return "Your Best Score: "..string.format("%5d", l)
  else return ""
  end 
end,
function()
  local l = CurrentAccount.levels[level.guid].replays
  if l and #l>0 then
    return MakeClickableText("My Replays", NMTCOLOR, MTCOLOR, function() end, nil)
  else return ""
  end
end
},{}},
{{},{
MakeClickableText("Exit", NMTCOLOR, MTCOLOR, function() Pregame.Stop() end, nil)
},{
MakeClickableText("Load a Replay", NMTCOLOR, MTCOLOR, Pregame.loadReplay, nil)
}},
}

Pregame.levelsethud={   --this is the hud used when playing a level as part of a levelset
Pregame.hudtop,
{{},{
function() return "(Name of Levelset)" end,
function() return "(LEVEL 15:) "..level.title end,
"",
function() return "(My Best Score: 0)" end,
function() return "(My Replays)" end,
},{}},
{{},{
MakeClickableText("Exit", NMTCOLOR, MTCOLOR, function() Pregame.Stop() end, nil)
},{
MakeClickableText("(Load a Replay)", NMTCOLOR, MTCOLOR, function() end, nil)
}},
}



