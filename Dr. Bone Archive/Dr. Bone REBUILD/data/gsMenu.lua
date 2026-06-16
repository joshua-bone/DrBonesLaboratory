gsMenu={}
gsMenu.BKGDPATH="data/background.bmp"
gsMenu.ID="gsMenu"
gsMenu.Cam={x=0, y=0, z=-20}
gsMenu.atZ=1

gsMenu.Start=function()
  gs=gsMenu
  gs.glist=grL.LoadBackgroundImage(gs.BKGDPATH, 160, 120, -75)
  gs.hud=gsMenu.SelectHud
  if not Player then--if starting the game
    dofile("data/players.lua") --load the players list into PlayerAccounts
    gs.SelectMenu=inL.MakeMenu(gs.SelectMenuBuild(), "yellow50", "yellow", 1)
    gs.NewPlayerMenu=inL.MakeMenu(gs.NewPlayerMenuBuild(), "yellow50", "yellow", 1)
    gs.menu=gs.SelectMenu
  else
    gs.MainMenu=inL.MakeMenu(gs.MainMenuBuild(), "yellow50", "yellow", 1)
	gs.menu=gs.MainMenu
  end
end

gsMenu.KeyDown={
  DEFAULT=function(key) 
    if gs.menu.string then
	  --lower case unless pressing Shift
	  if (not gs.Shift) and key>=65 and key<=90 then
	    key=key+32
	  end
	  if (key>=65 and key<=90) or (key==32)
	    or (key>=48 and key<=57) or (key>=97 and key<=122)
		and #gs.menu.string < MAXPLAYERNAME then
		  gs.menu.string=gs.menu.string..string.char(key)
	  end
	else
	  --Ctrl-D to delete player at main screen
	  if not Player and gs.Ctrl and key==68 then
	    local name=gs.menu.list[gs.menu.pos].text
	    local i, pos
		for i=1,#PlayerAccounts do
		  if PlayerAccounts[i].name==name then
		    table.remove(PlayerAccounts, i)
			fxL.WritePlayerList()
			gs.Start()
			return
	      end
		end
	  end
	end
  end,
  UP=function() gs.menu.Select(gs.menu, gs.menu.pos-1) end,
  DOWN=function() gs.menu.Select(gs.menu, gs.menu.pos+1) end,
  ENTER=function() 
    local opt=gs.menu.list[gs.menu.pos]
	if opt then opt.Choose(opt) end
	end,
  SHIFT=function() gs.Shift=true end,
  CTRL=function() gs.Ctrl=true end,
  BACKSPACE=function()
    if gs.menu.string and #gs.menu.string>0 then
	  gs.menu.string=string.sub(gs.menu.string,1,#gs.menu.string-1)
	end
  end,
}

gsMenu.KeyUp={
  DEFAULT=function(key) end,
  SHIFT=function() gs.Shift=false end,
  CTRL=function() gs.Ctrl=false end,
}

gsMenu.OnTimer=function()
end

gsMenu.Render=function()
  grL.RenderGLList(gs.glist)
  --grL.RenderSolidBackground("white60")
  grL.RenderHud(gsMenu.hud)
  FlipScreen()
end

gsMenu.SelectHud={
{{}, --Top Middle
function() return gs.menu.header() end,
{}},
{
function() --Center Left
  local result=gs.menu.GetList(gs.menu)
  result["background"]={color="black", border="yellow", size="fit"}
  return result
end,
function() --Center Middle
  local result={}
  if gs.menu.string then
    table.insert(result, gs.menu.string)
	result.background={color="black", border="yellow", size="fit"}
  end
  return result
end
,{}},
{{},{},{}}
}

gsMenu.SelectMenuBuild=function()
  local result={}
  --header for display top middle
  result.header=function() 
    local result={"Welcome to Dr. Bone's Laboratory", 
            "Please Select A Player",
			"",
			"(Ctrl-D to Delete Selected Player)",
			background={color="black", border="yellow", size="fit"}}
	return result
    end
  --make the menu for display left center
  table.insert(result, {"Create A New Player", 
    function() 
	  gs.menu=inL.MenuReset(gs.NewPlayerMenu)
	  gs.menu.string="New Player"
	end})
  table.insert(result, {"Exit Game", function() Quit() end})
  if PlayerAccounts then
    local i
	for i=1,#PlayerAccounts do
	  table.insert(result, {PlayerAccounts[i].name, function() Player=PlayerAccounts[i] gs.Start() end})
	end
  end
  return result
end

gsMenu.MainMenuBuild=function()
  local result={}
  result.header=function()
    return {"Welcome to Dr. Bone's Laboratory",
	        "You are currently logged in as "..Player.name,
			"Please choose an option from the menu",
			background={color="black", border="yellow", size="fit"}}
	end
  table.insert(result, {"Play the Game (DEBUG)", function() end})
  table.insert(result, {"Start the Level Browser (DEBUG)", function() end})
  table.insert(result, {"Start the Level Editor (DEBUG)", function() gsEditor.Start() end})
  table.insert(result, {function() return "Logout "..Player.name end, 
                        function() Player=nil gs.Start() end})
  table.insert(result, {"Exit Game", function() Quit() end})
  return result
end

gsMenu.NewPlayerMenuBuild=function()
  local result={}
  result.header=function()
    return {
	        function() 
			  if gs.menu.error then return gs.menu.error
			  else return "Enter New Player Name" end
			end,
	        background={color="black", border="yellow", size="fit"}}
    end
  table.insert(result, {"Accept", function()
			local i
			gs.menu.error=nil
			for i=1,#PlayerAccounts do
			  if gs.menu.string==PlayerAccounts[i].name then
			    gs.menu.error="ERROR: Player "..gs.menu.string.." Already Exists!"
			  end
			end
			if not gs.menu.error then
			  local newP={}
			  newP.name=gs.menu.string
			  newP.guid=fxL.GenerateGuid()
			  newP.levels={}
			  newP.levelsets={}
			  table.insert(PlayerAccounts,newP)
			  fxL.WritePlayerList() --write player list
			  Player=newP --global Player
			  gs.Start()
			end
          end})
  table.insert(result, {"Cancel (ESC)", function() 
                           gs.menu=inL.MenuReset(gs.SelectMenu)
						   end})
  return result
end





