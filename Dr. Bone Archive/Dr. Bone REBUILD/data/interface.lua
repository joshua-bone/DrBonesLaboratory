--interface library

--------------------------------
--GLOBALS called by main program
--------------------------------

--OnTimer() and Render() are both called from the same timer
--in the main program. The intent is that OnTimer() handles
--game logic while Render() handles all graphics calls.
--We will pass all calls to the current gamestate.
OnTimer=function() if gs.OnTimer then gs.OnTimer() end end
Render=function() if gs.Render then gs.Render() end end

--KeyDown() and KeyUp() are both called from the main program
--when a keyboard key is pressed or released, respectively.
--We will pass all calls with the keycode to the current gamestate.
KeyUp=function(key) SendKeyToGS(key, "KeyUp") end
KeyDown=function(key) SendKeyToGS(key, "KeyDown") end
SendKeyToGS=function(key,mode)
  local name=inL.keynames[key]  --get the name of the key
  if gs[mode] then --if the gamestate has a KeyDown/KeyUp table
    local fx=gs[mode][name]
	if fx then fx(key) return end  --if a function corresponds to this key, call it
	fx=gs[mode]["DEFAULT"]         --otherwise try to call the default function
	if fx then fx(key) return end  --if it exists.
  end
end


--called when game window is closed from Windows
--return value of 1 allows program to close
--return value of 0 prevents program from closing
function CloseProgram()
  return 1
end

OnMouseWheel=function(w,x,y) if x>10000 then 
                               if gs.KeyDown.MWheelUp then gs.KeyDown.MWheelUp() end
                             else 
							   if gs.KeyDown.MWheelDown then gs.KeyDown.MWheelDown() end
							 end 
			 end
OnMouseMove=function(w,x,y) inL.SetMouse(x,y) end
OnMouseLeave=function(w,x,y) end
OnMButtonUp=function(w,x,y) inL.SetMouse(x,y) end
OnMButtonDown=function(w,x,y) inL.SetMouse(x,y) end
OnRButtonUp=function(w,x,y) inL.mouse.RDown=false inL.SetMouse(x,y) end
OnRButtonDown=function(w,x,y) inL.mouse.RDown=true inL.SetMouse(x,y) end
OnLButtonUp=function(w,x,y) inL.mouse.LDown=false inL.SetMouse(x,y) end
OnLButtonDown=function(w,x,y) inL.mouse.LDown=true inL.SetMouse(x,y) end
ResizeScreen=function(width, height) end

--interface library
inL={}

-----------------------------------------------------
--datastructs in alphabetical order with descriptions
-----------------------------------------------------

--this structure matches keyboard keycodes to names
--for convenience in writing gamestate functions.
inL.keynames={}
inL.keynames[8]="BACKSPACE"
inL.keynames[9]="TAB"
inL.keynames[13]="ENTER"
inL.keynames[16]="SHIFT"
inL.keynames[17]="CTRL"
inL.keynames[20]="CAPSLOCK"
inL.keynames[27]="ESC"
inL.keynames[32]="SPACE"
inL.keynames[33]="PAGEUP"
inL.keynames[34]="PAGEDOWN"
inL.keynames[35]="END"
inL.keynames[36]="HOME"
inL.keynames[37]="LEFT"
inL.keynames[38]="UP"
inL.keynames[39]="RIGHT"
inL.keynames[40]="DOWN"
inL.keynames[45]="INSERT"
inL.keynames[46]="DELETE"
inL.keynames[187]="PLUS"
inL.keynames[189]="MINUS"
inL.keynames[112]="F1"
inL.keynames[113]="F2"
inL.keynames[114]="F3"
inL.keynames[115]="F4"
inL.keynames[116]="F5"
inL.keynames[117]="F6"
inL.keynames[118]="F7"
inL.keynames[119]="F8"
inL.keynames[120]="F9"
inL.keynames[122]="F11"
inL.keynames[123]="F12"
inL.keynames[188]="LPOINTYBRACKET"
inL.keynames[190]="RPOINTYBRACKET"

local i
for i=65,90 do  --A-Z
  inL.keynames[i]=string.char(i)
end
for i=48,57 do  --0-9
  inL.keynames[i]=string.char(i)
end

inL.mouse={x=0,
           y=0,
		   LDown=false,
		   RDown=false, 
		   DblClick=false, 
		   obj=nil,
		   map={x=0,y=0}, --mouse coordinates to map coordinates
		   screen={x=0,y=0}, --mouse coordinates to GL screen coordinates
		   }

inL.writers={}
inL.writers.boolean=function(file,value,level) if value then file:write("true") else file:write("false") end end
inL.writers.string=function(file,value,level) file:write('"'..value..'"') end  -- assume no double quotes in strings
inL.writers.number=function(file,value,level) file:write(tostring(value)) end
inL.writers.table=function(file,value,level)
  if level==3 then file:write("\n") end   -- formats the map
  file:write("{")
  local first=true
  for key,item in pairs(value) do
    if first then first=false else file:write(",") end
    local fnc=writers[type(item)]
    if fnc~=nil then
      if level==1 and type(key)~="number" then file:write("\n") end  -- format the highest level
      if type(key)~="number" then file:write(key.."=") end
      if writers[key]==nil then key=type(item) end -- custom writers
      writers[key](file,item,level+1)
    end
  end
  c=true
  file:write("}")
end

-----------------------------------------------------
--functions in alphabetical order with descriptions
-----------------------------------------------------

--[[
list = {
{"Option 1", fnc1},
{...}
{"Option n", fncn},
}
]]
inL.MakeClickableText=function(text, col1, col2, fnc)
  local result={}
  result.text=text
  result.Measure=function(this) return grL.GetHudEntrySize(this.text) end
  result.LMouseClick=fnc
  result.col1=col1
  result.col2=col2
  result.Render=function(this)
    local col
    if this==inL.mouse.obj then col=this.col2
	else col=this.col1 end
	grL.RenderSolidText(this.text, col)
  end
  return result
end

inL.MakeMenu=function(list, col1, col2, stPos)
  if not stPos then stPos=1 end --the starting position in the menu
  local result = {list={}}
  local i
  for i=1,#list do
    table.insert(result.list, inL.MakeMenuOption(i,list[i][1], list[i][2],col1,col2, result))
  end
  if list.header then result.header=list.header end --transfer over menu header if applicable
  result.pos=stPos
  result.top=stPos
  result.col1=col1
  result.col2=col2
  result.Scroll=inL.MenuScroll
  result.Select=inL.MenuSelect --give the menu self-selecting capability
  result.Select(result, result.pos) --select the default entry
  result.GetList=inL.MenuGetList --return a list with scroll up/down capabilities
  return result
end

inL.MakeMenuOption=function(pos, text, fx, col1, col2, parent)
  local opt={}
  opt.parent=parent --pointer back to the menu
  opt.text=text
  opt.pos=pos --store it's place in the menu
  opt.Choose=fx
  opt.LMouseClick=function(this)
                    if not this.selected then
					  this.parent.Select(this.parent, this.pos)
					else
					  this.Choose(this)
					end
                  end
  opt.SelectedColor=col2
  opt.NotSelectedColor=col1
  opt.Measure=function(this)
				return grL.GetHudEntrySize(this.text)
              end
  opt.Render=function(this)
               local text=this.text
               if type(text)=="function" then text=text() end --if text is a function, call it
			   local color
			   if this.selected then
			     color=this.SelectedColor
			   else
			     color=this.NotSelectedColor
			   end
			   grL.RenderSolidText(text, color) --render the string
			 end
   return opt
end

inL.MenuGetList=function(menu)
  local result={}
  if #menu.list<=MENULISTSIZE then  --if the whole list will fit on the
    return menu.list                --screen, then just return it
  else                              --otherwise:
    local result={}
	
	--ADD A SCROLL UP BUTTON IF NEEDED
	if menu.top>1 then table.insert(result,
	                     inL.MakeClickableText("SCROLL UP",
												menu.col2, menu.col2,
												function() menu.Scroll(menu, "UP") end))
    else
	  table.insert(result, inL.MakeClickableText("", menu.col1, menu.col1,nil))
	end
	
	--ADD IN ALL THE MENU ENTRIES IN RANGE
	local i
	for i=menu.top,menu.top+MENULISTSIZE-1 do
	  if menu.list[i] then
	    table.insert(result, menu.list[i])
	  else
	  table.insert(result, inL.MakeClickableText("", menu.col1, menu.col1,nil))
	  end
	end
	
	--ADD A SCROLL DOWN BUTTON IF NEEDED
	if menu.top+MENULISTSIZE<=#menu.list then
	  table.insert(result,
				   inL.MakeClickableText("SCROLL DOWN",
		                                 menu.col2, menu.col2,
										 function() menu.Scroll(menu, "DOWN") end))
	else
	  table.insert(result, inL.MakeClickableText("", menu.col1, menu.col1,nil))
	end
    return result
  end
end

inL.MenuReset=function(menu)
  menu.Select(menu,1) --select the first position
  menu.string=nil --erase the input string if any
  menu.error=nil --erase the error message if any
  return menu
end

inL.MenuScroll=function(menu, dir)
  if dir=="UP" then
    menu.top=menu.top-1
	if menu.pos-menu.top>=MENULISTSIZE then
	  menu.Select(menu, menu.pos-1)
	end
  elseif dir=="DOWN" then
    menu.top=menu.top+1
	if menu.top>menu.pos then
	  menu.Select(menu, menu.pos+1)
	end
  end
end

inL.MenuSelect=function(menu, newPos)
  if newPos<1 then 
    newPos=#menu.list 
	menu.top=newPos-MENULISTSIZE+1
  end
  if newPos>#menu.list then 
    newPos=1 
	menu.top=1 
  end
  
  while newPos<menu.top do
    menu.top=menu.top-1 
  end
  
  while newPos>menu.top+MENULISTSIZE-1 do
    menu.top=menu.top+1
  end
  
  menu.list[menu.pos].selected = false --deselect the currently selected entry
  menu.list[newPos].selected = true
  menu.pos=newPos
end

inL.SetMouse=function(x,y)
  inL.mouse.x=x
  inL.mouse.y=y
  
  --if mouse is over a clickable object
  if inL.mouse.obj then
    if inL.mouse.RDown and inL.mouse.obj.RMouseClick then
	  inL.mouse.RDown=false
	  inL.mouse.obj.RMouseClick(inL.mouse.obj)
	elseif inL.mouse.LDown and inL.mouse.obj.LMouseClick then
	  inL.mouse.LDown=false
	  inL.mouse.obj.LMouseClick(inL.mouse.obj)
	end
  end
  
  --find the mouse GL screen point
  glLoadIdentity()
  local sc=inL.mouse.screen
  sc.x, sc.y=GetPlanePoint(inL.mouse.x, inL.mouse.y, -gs.Cam.z)
  
  --handle map dragging
  if gs.ID=="gsEditor" and gs.Ctrl and inL.mouse.LDown then
    if inL.mouse.DragPoint then 
	
	  --if we are already dragging in the editor,
	  --then update the gamestate camera
	  local dragPt=inL.mouse.DragPoint
	  gs.Cam.x=dragPt.camx+sc.x-dragPt.x
	  gs.Cam.y=dragPt.camy-sc.y+dragPt.y
	  
	else --if we are just beginning to drag in the editor,
	     --then set the drag point to the current mouse screen position
	     --and set the camera drag point to the current camera position
	  inL.mouse.DragPoint={x=sc.x, 
	                       y=sc.y,
						   camx=gs.Cam.x,
						   camy=gs.Cam.y} 
	end
	  
  else
    inL.mouse.DragPoint=nil
  end
  
  --relate the cursor position to the map position
  if inL.mouse.map then
    inL.mouse.map.x=int(gs.Cam.x-sc.x+10000.5)-10000
	inL.mouse.map.y=int(gs.Cam.y+sc.y+10000.5)-10000
  end
  
  --do painting in editor
  if not inL.mouse.DragPoint then
    if inL.mouse.LDown then
      gs.PaintLeft(inL.mouse.map.x, inL.mouse.map.y)
    elseif inL.mouse.RDown then
	  gs.PaintRight(inL.mouse.map.x, inL.mouse.map.y)
	end 
  end
end
