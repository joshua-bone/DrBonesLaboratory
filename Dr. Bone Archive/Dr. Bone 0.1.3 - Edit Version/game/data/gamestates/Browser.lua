-------------
--Browser
-------------
Browser={}
Browser.camera={x=0,y=0,z=4}
Browser.ID="Browser"
Browser.FILE="temp.txt"

Browser.Start=function() 
  Browser.getList()
  --dumpit.table("list",Browser.list)
  gamestate=Browser
  Browser.hud=Browser.mainhud
end

Browser.getList=function()
  os.execute("dir game\\maps /b > "..Browser.FILE)
  local f=io.open(Browser.FILE, "r")
  if f then
    Browser.list={}
    for line in f:lines() do  --go through each file in the maps/ directory
	  if string.find(line, ".lvl") then  --if the file has the right extension
	    local g=io.open("game/maps/"..line) --then open the file and look for the guid
		table.insert(Browser.list, {path="game/maps/"..line})
	    for entry in g:lines() do
		  --find the guid and save it
		  local x,y=string.find(entry, "guid=")
		  if x==1 and y==5 then
		    local g
			g = string.sub(entry, 7, -2) --includes guid+" unless no comma at end of line
			if string.find(g,'"') then 
			  g = string.sub(g,1,-2) --get rid of trailing "s
			end
			Browser.list[#Browser.list].guid=g
	      end
		  --find the title and save it
		  local x,y=string.find(entry, "title=")
		  if x==1 and y==6 then
		    local t
			t = string.sub(entry, 8, -2) --includesd title+" unless no comma at end of line
		    if string.find(t,'"') then  
			  t = string.sub(t,1,-2)  --get rid of trailing "s
			end
			Browser.list[#Browser.list].title=t
		  end
		end
		
		--make sure we got a title and a guid, remove entry if we didn't
		local l = Browser.list[#Browser.list]
		if not (l and l.guid and l.title) then
		  table.remove(Browser.list) --chops off last entry
		end
		g:close()
	  end    
	end
  end
  f:close()
  os.execute("del "..Browser.FILE)
end

Browser.render=function()
  RenderSolidBackground(BKGDCOLOR)
  drawhud(Browser.hud,TEXTSIZE)
  FlipScreen()
end

Browser.OnTimer=function()
  collectgarbage("collect")
end

Browser.mainhud={
{{},{},{}},
{{},{},{}},
{{},{},{}},
}