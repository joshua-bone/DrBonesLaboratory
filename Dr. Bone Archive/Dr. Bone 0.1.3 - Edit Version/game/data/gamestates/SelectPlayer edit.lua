-------------
--SELECTPLAYER
-------------
SelectPlayer={}
SelectPlayer.camera={x=0,y=0,z=4}
SelectPlayer.ID="SelectPlayer"

SelectPlayer.Start=function() 

  if not SelectPlayer.flag then  --if there's not a flag set
    dofile("game/data/players.lua") --then load the player list
  else                          --otherwise find out what the flag was
    if SelectPlayer.flag=="New Account" then  --if we just got back from creating a new account name
	  SelectPlayer.flag=nil                         --then reset the flag
	  local newP=PlayerAccounts[#PlayerAccounts]    --the new player will be the last entry in the list
	  newP.name=GetString.string  --get the new name from the GetString gamestate
	  newP.guid=GenerateGuid()    --give the player a random guid
      newP.levels={}              --give the player a place to keep track of levels and scores
	  newP.levelsets={}            --and a place to keep track of progress in levelsets
      SelectPlayer.WriteAccounts()   --finally, write the player list to file
	end
  end
  gamestate=SelectPlayer
  SelectPlayer.hud=SelectPlayer.mainhud
  
  --load the background level if necessary
  local templevel=level  --save loaded level so Menu doesn't erase things
  if not bklevel then
    bktick=0
    bkmap=LoadMap(WD..BKMAPPATH)
	bklevel=level
	level=templevel
	SelectPlayer.CurrentDeck=bklevel.CurrentDeck
	SelectPlayer.camera={y=(#map[1]/2)+.5,x=(#map/2)+.5,z=4}
  end
  monsterspeed=1/60       --slow down the monsters for the background
  
  --index will keep track of the currently highlighted menu option
  if not SelectPlayer.lindex then SelectPlayer.lindex=1 end
  if not SelectPlayer.rindex then SelectPlayer.rindex=1 end
  
  --side will keep track of which side (left=1/right=2) of the menu is active
  if not SelectPlayer.side then SelectPlayer.side=1 end

  --top will keep track of the topmost position in a long list of player names
  if not SelectPlayer.top then SelectPlayer.top=1 end
end

--[[
e.g. LISTNUM=5 top=1
""   1
Jenny 2
Joshua 3
Jessica 4
Johanna 5
Janine  6
More    7

top=3
More 1
Jessica 2
Johanna 3
Janine 4
Create a New Player  5
Exit Game  6
"" 7

]]

SelectPlayer.DisplayNames=function()
  local array = {}
  
  --top line
  if SelectPlayer.top > 1 then 
    array[1] = "   More" 
  else
    array[1] = ""
  end
  
  --fill in the names
  local i
  for i=SelectPlayer.top,math.min(SelectPlayer.top+LISTNUM-1,#PlayerAccounts),1 do
    if i==SelectPlayer.lindex then
      table.insert(array, MakeClickableText("   "..PlayerAccounts[i].name, MTCOLOR, MTCOLOR, nil, nil))
	else
	  table.insert(array, MakeClickableText("   "..PlayerAccounts[i].name, NMTCOLOR, NMTCOLOR, nil, nil))
	end
  end
  
  --if there's space after the names add in these menu options
  if (SelectPlayer.top+LISTNUM-1)>#PlayerAccounts then
    local stop = (SelectPlayer.top+LISTNUM-1-#PlayerAccounts)
	
	--Create a New Player Menu Option
	if SelectPlayer.lindex==#PlayerAccounts+1 then
	  table.insert(array, MakeClickableText("   Create a New Player", MTCOLOR, MTCOLOR))
	else
	  table.insert(array, MakeClickableText("   Create a New Player", NMTCOLOR, NMTCOLOR))
	end
	
	--Exit Game Menu Option
	if stop>2 then
	  if SelectPlayer.lindex==#PlayerAccounts+2 then
	    table.insert(array, MakeClickableText("   Exit Game", MTCOLOR, MTCOLOR))
	  else
	    table.insert(array, MakeClickableText("   Exit Game", NMTCOLOR, NMTCOLOR))
	  end
	end
  end
  
  if #PlayerAccounts > SelectPlayer.top+4 then
    array[LISTNUM+2] = "   More"
  else
    array[LISTNUM+2] = ""
  end
  for i = 1,(LISTNUM+2),1 do
    if not array[i] then
	  array[i]=""
	end
  end
  return array
end

SelectPlayer.DisplayMenu=function()
  local array={}
  local i
  for i=1,4 do
    array[i]=""
  end
  return array
end

SelectPlayer.KeyDown={
  DOWN=function() 
    if SelectPlayer.lindex<#PlayerAccounts+2 then
	  SelectPlayer.lindex=SelectPlayer.lindex+1
	  local l = SelectPlayer.lindex
	  if l>SelectPlayer.top+LISTNUM-1 then
	    SelectPlayer.top=SelectPlayer.top+1 
	  end
	end
  end,
  
  UP=function()
    if SelectPlayer.lindex>1 then
	  SelectPlayer.lindex=SelectPlayer.lindex-1
	  if SelectPlayer.lindex<SelectPlayer.top then
	    SelectPlayer.top=SelectPlayer.top-1
	  end
	end
  end,
  
  ENTER=function()
  
    if SelectPlayer.lindex==#PlayerAccounts+2 then  --Exit Game option
	  quit() 
	elseif SelectPlayer.lindex==#PlayerAccounts+1 then  --New Player option
	  table.insert(PlayerAccounts, {name="New Player"})
	  SelectPlayer.flag="New Account"
	  GetString.Start("Enter New Player Name", 
	                  PlayerAccounts[#PlayerAccounts].name)
	else
	  CurrentAccount=SelectPlayer.lindex --temporary set to index until confirm
	end
	  
  end
}

--[[
SelectPlayer.MenuFx={
{"
}]]

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
{
--TOP LEFT
{"","   Dr. Bone's Laboratory","   Select Player"},

--TOP CENTER, TOP RIGHT
{},{}},

--MIDDLE LEFT
{SelectPlayer.DisplayNames,{},

--MIDDLE RIGHT
SelectPlayer.DisplayMenu},

--BOTTOM LEFT, BOTTOM CENTER, BOTTOM RIGHT
{{},{},{}},
}

SelectPlayer.confirmhud={
{{},{},{}},
{{},{},{}},
{{},{},{}},
}

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