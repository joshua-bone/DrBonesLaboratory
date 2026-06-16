-------------
--MENU
-------------
Menu={}
Menu.camera={x=0,y=0,z=4}
Menu.ID="Menu"
Menu.Start=function() 
  bktick=0
  monsterspeed=1/60
  gamestate=Menu
  Menu.hud=Menu.mainhud
  local templevel=level  --save loaded level so Menu doesn't erase things
  
  --add a background map to the menu
  
  bkmap=LoadMap(WD..BKMAPPATH)
  bklevel=level
  level=templevel
  level = nil   --experimental, ensure we don't carry level into editor
  Menu.CurrentDeck=bklevel.CurrentDeck
  Menu.camera={y=(#map[1]/2)+.5,x=(#map/2)+.5,z=4}
end

Menu.LoadAndPlayLevelSet=function() end

Menu.LoadAndPlayLevel=function()
  Browser.Start()
  --if AskLoadMap() then
    --Pregame.Start()
  --end
end

Menu.KeyDown={
  ESC=quit,
}

Menu.mainhud={
{{"","   Dr. Bone's Laboratory","   Main Menu"},{},{"",function() return CurrentAccount.name.."   " end}},
{{
MakeClickableText("   Load and Play a Level",NMTCOLOR, MTCOLOR,Menu.LoadAndPlayLevel,nil),
MakeClickableText("   Start the Editor",NMTCOLOR, MTCOLOR,function() Editor.Start() end,nil),
MakeClickableText(function() return "   Logout "..CurrentAccount.name end, NMTCOLOR, MTCOLOR, function() SelectPlayer.Start() end, nil),
MakeClickableText("   Exit Game",NMTCOLOR, MTCOLOR,quit,nil),
},{},{}},
{{},{},{}},
}

--add a background map to the menu

Menu.render=function()
  MapRender(bkmap)
  drawhud(Menu.hud,TEXTSIZE)
  FlipScreen()
end

Menu.OnTimer=function()
  bktick=bktick+1
  while true do
    if #Pending==0 then break end
	Pending[1]:logic(0)
  end
  Pending, Complete=Complete,Pending
  collectgarbage("collect")
end