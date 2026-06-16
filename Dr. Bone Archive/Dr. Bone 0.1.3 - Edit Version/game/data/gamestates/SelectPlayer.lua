-------------
--SELECTPLAYER
-------------
SelectPlayer={}
SelectPlayer.camera={x=0,y=0,z=4}
SelectPlayer.ID="SelectPlayer"

SelectPlayer.Start=function() 
  if not SelectPlayer.flag then
    dofile("game/data/players.lua") --load the player list
  else
    if SelectPlayer.flag=="New Account" then  --just got back from creating a new account name
	  SelectPlayer.flag=nil
	  local newP=PlayerAccounts[#PlayerAccounts]
	  newP.name=GetString.string  --get the name from the GetString gamestate
	  newP.guid=GenerateGuid()
      newP.levels={}
	  newP.levelsets={}
      SelectPlayer.WriteAccounts()
	end
  end
  gamestate=SelectPlayer
  SelectPlayer.hud=SelectPlayer.mainhud
  local templevel=level  --save loaded level so Menu doesn't erase things
  
  --add a background map to the menu
  
  if not bklevel then
    bktick=0
	monsterspeed=1/60
    bkmap=LoadMap(WD..BKMAPPATH)
	bklevel=level
	level=templevel
	SelectPlayer.CurrentDeck=bklevel.CurrentDeck
	SelectPlayer.camera={y=(#map[1]/2)+.5,x=(#map/2)+.5,z=4}
	
  --else
    --Menu.CurrentDeck=level.CurrentDeck
	--bkmap=ParseMap(bklevel)
  end
end

SelectPlayer.DisplayNames=function()
  --if not SelectPlayer.index then SelectPlayer.index=1 end
  if not SelectPlayer.top then SelectPlayer.top=1 end
  local array = {}
  if SelectPlayer.top > 1 then 
    array[1] = MakeClickableText("   Scroll Up", "white", MTCOLOR, SelectPlayer.ScrollUp, nil) 
  else
    array[1] = ""
  end
  local i
  for i=SelectPlayer.top,math.min(SelectPlayer.top+4,#PlayerAccounts),1 do
    --if i==SelectPlayer.index then
    --  table.insert(array, MakeClickableText(PlayerAccounts[i].name, "green", "green", nil, nil))
	--else
	  table.insert(array, MakeClickableText("   "..PlayerAccounts[i].name, NMTCOLOR, MTCOLOR, function() CurrentAccount=PlayerAccounts[i] Menu.Start() end, nil))
	--end
  end
  if #PlayerAccounts > SelectPlayer.top+4 then
    array[7] = MakeClickableText("   Scroll Down", "white", MTCOLOR, SelectPlayer.ScrollDown, nil)
  else
    array[7] = ""
  end
  for i = 1,7,1 do
    if not array[i] then
	  array[i]=""
	end
  end
  return array
end

SelectPlayer.DeleteNames=function()
  --if not SelectPlayer.index then SelectPlayer.index=1 end
  if not SelectPlayer.top then SelectPlayer.top=1 end
  local array = {}
  if SelectPlayer.top > 1 then 
    array[1] = MakeClickableText("   Scroll Up", "white", MTCOLOR, SelectPlayer.ScrollUp, nil) 
  else
    array[1] = ""
  end
  local i
  for i=SelectPlayer.top,math.min(SelectPlayer.top+4,#PlayerAccounts),1 do
    --if i==SelectPlayer.index then
    --  table.insert(array, MakeClickableText(PlayerAccounts[i].name, "green", "green", nil, nil))
	--else
	  table.insert(array, MakeClickableText("   "..PlayerAccounts[i].name, WTCOLOR, MTCOLOR, 
	    function()  
		  CurrentAccount=i 
		  SelectPlayer.hud=SelectPlayer.confirmhud
		end,
		nil))
	--end
  end
  if #PlayerAccounts > SelectPlayer.top+4 then
    array[7] = MakeClickableText("   Scroll Down", "white", MTCOLOR, SelectPlayer.ScrollDown, nil)
  else
    array[7] = ""
  end
  for i = 1,7,1 do
    if not array[i] then
	  array[i]=""
	end
  end
  return array
end

SelectPlayer.WriteAccounts = function()
  local i, j
  local file=io.open(WD.."game/data/players.lua", "w")
  
  --Players
  file:write("PlayerAccounts={")
  --writers.table(file,PlayerAccounts,1)
  for i=1,#PlayerAccounts do
    file:write("\n{")
    for key, val in pairs(PlayerAccounts[i]) do
	  if key=="levels" or key=="levelsets" then
	    file:write(key.."={},")
	  else
	    local fnc=writers[type(val)]
		if fnc then
		  if type(key)~="number" then file:write(key.."=") end
		  fnc(file, val, 2)
		  file:write(",")
		end
	  end
	end
	file:write("},")
  end
  file:write("\n}\n")
  
  --Levels
  for i=1,#PlayerAccounts do
    local levels=PlayerAccounts[i].levels
	for guid, level in pairs(levels) do
	  file:write("PlayerAccounts["..i.."].levels['"..guid.."']=")
	  writers.table(file, level, 2)
      file:write("\n")
	end
  end
  
  file:close()
end

SelectPlayer.ScrollDown = function()
  SelectPlayer.top=SelectPlayer.top+1
  --SelectPlayer.index=SelectPlayer.index+1
end

SelectPlayer.ScrollUp = function()
  SelectPlayer.top=SelectPlayer.top-1
  --SelectPlayer.index=SelectPlayer.index-1
end

SelectPlayer.mainhud={
{{"","   Dr. Bone's Laboratory","   Select Player"},{},{
"", MakeClickableText("Exit Game   ", NMTCOLOR, MTCOLOR, quit, nil)}},
{SelectPlayer.DisplayNames,{},{}},
{{
MakeClickableText("   Create a Player", NMTCOLOR, MTCOLOR, function()
  table.insert(PlayerAccounts, {name="New Player"})
  SelectPlayer.flag="New Account"
  GetString.Start("Enter New Player Name", 
  PlayerAccounts[#PlayerAccounts].name)
end, nil)
},{},{
MakeClickableText("Delete a Player   ", NMTCOLOR, MTCOLOR, function() SelectPlayer.hud=SelectPlayer.deletehud end, nil)
}},
}

SelectPlayer.deletehud={
{{"","   Dr. Bone's Laboratory","   Choose A Player To Delete"},{},{}},
{SelectPlayer.DeleteNames,{},{}},
{{},{},{}},
}

SelectPlayer.confirmhud={
{{},{},{}},
{{},{
function() return "Delete Player Account "..PlayerAccounts[CurrentAccount].name.."?" end,
MakeClickableText("Yes", NMTCOLOR, MTCOLOR, function() 
											table.remove(PlayerAccounts, CurrentAccount)
											SelectPlayer.hud=SelectPlayer.mainhud
											SelectPlayer.WriteAccounts()
									     end,
										 nil),
MakeClickableText("No", NMTCOLOR, MTCOLOR, function()
										  SelectPlayer.hud=SelectPlayer.mainhud
										end,
										nil),											
},{}},
{{},{},{}},
}


--add a background map to the menu:
 
SelectPlayer.render=function()
  MapRender(bkmap)
  drawhud(SelectPlayer.hud,TEXTSIZE)
  FlipScreen()
end

SelectPlayer.OnTimer=function()
  bktick=bktick+1
  while true do
    if #Pending==0 then break end
	Pending[1]:logic(0)
  end
  Pending, Complete=Complete,Pending
  collectgarbage("collect")
end