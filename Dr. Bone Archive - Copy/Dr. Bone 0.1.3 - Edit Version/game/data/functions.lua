--FUNCTIONS--

H=0.8 --affects shading with depth

--MAIN
close=function() if CheckDirty() then return 1 end return 0 end    -- check for OK to close

---------------------------
--INTERFACE (in.fx)
---------------------------

function GenerateGuid()
  local i
  local guid=""
  for i=1,8 do
    if i>=3 and i<=6 then guid=guid.."-" end
    guid = guid..string.format('%04x', math.random(2^16))
  end
  return guid
end

function GenerateLevel(x,y,z)
  if not x then x=10 end
  if not y then y=10 end
  if not z then z=4 end
  local l={}
  l.author=CurrentAccount.name
  l.authorguid=CurrentAccount.guid
  l.date=os.date()
  l.CurrentDeck=1
  l.objects={
   {g='9a41f5ef-e6a2-405d-9416-113b927d0659'}, --floor
  }
  l.guid=GenerateGuid()
  l.title="New Level"
  l.clip={9,9}
  l.time=0
  l.map={}
  local i,j,k
  for k=1,z do
    table.insert(l.map,{})
    for j=1,y do
	  table.insert(l.map[k],{})
	  for i=1,x do
	    table.insert(l.map[k][j],1)
	  end
	end
  end
  return l
end

function ResizeScreen(w,h) screen.width=w screen.height=h end
function SetMousePosition(x,y)
  mouse.x,mouse.y=x,y
-- clickable items
  if MouseOver then
    if LeftDown and MouseOver.left then
      LeftDown=false
      MouseOver.left()
      return
    end
    if RightDown and MouseOver.right then
      RightDown=false
      MouseOver.right()
      return
    end
  end

-- find the editor crosshair
  glLoadIdentity()
  crosshair.x,crosshair.y=GetPlanePoint(mouse.x,mouse.y,-gamestate.camera.z)
-- handle map dragging in the editor
  if LeftDown and CtrlDown then
    if CrossHairDragPoint then
      gamestate.camera.x=CameraDragPoint.x+(crosshair.x-CrossHairDragPoint.x)
      gamestate.camera.y=CameraDragPoint.y-(crosshair.y-CrossHairDragPoint.y)
    else
      CrossHairDragPoint={}
      CrossHairDragPoint.x=crosshair.x
      CrossHairDragPoint.y=crosshair.y
      CameraDragPoint={}
      CameraDragPoint.x=gamestate.camera.x
      CameraDragPoint.y=gamestate.camera.y
    end
  else
    CrossHairDragPoint=nil
  end
-- position the map edit cursor
  if mousemap then
    mousemap.x=int((gamestate.camera.x-crosshair.x)+10000.5)-10000
    mousemap.y=int((gamestate.camera.y+crosshair.y)+10000.5)-10000
	end
-- do painting
  if not CrossHairDragPoint and LeftDown then
    gamestate.PaintLeft(mousemap.x,mousemap.y)
  end
  if not CrossHairDragPoint and RightDown then
    gamestate.PaintRight(mousemap.x,mousemap.y)
  end
end

function OnMouseMove(w,x,y) 
  SetMousePosition(x,y)
end

function OnLButtonDown(w,x,y) 
  LeftDown=true
  SetMousePosition(x,y)
end
function OnLButtonUp(w,x,y) LeftDown=false SetMousePosition(x,y) end
function OnLButtonDblClk(w,x,y) SetMousePosition(x,y) end

function OnRButtonDown(w,x,y)
  RightDown=true
  SetMousePosition(x,y)
end
function OnRButtonUp(w,x,y) RightDown=false SetMousePosition(x,y) end
function OnRButtonDblClk(w,x,y) SetMousePosition(x,y) end

function OnMButtonDown(w,x,y) SetMousePosition(x,y) end
function OnMButtonUp(w,x,y) SetMousePosition(x,y) end
function OnMButtonDblClk(w,x,y) SetMousePosition(x,y) end

function OnMouseLeave() end

function KeyDown(key)
  local name=keynames[key]
  if name==nil then name="DEFAULT" end
  if gamestate.KeyDown then
    local fnc=gamestate.KeyDown[name]
    if fnc==nil then fnc=gamestate.KeyDown.DEFAULT end
    if fnc then fnc(key) return end
  end
end

function KeyUp(key)
  local name=keynames[key]
  if name==nil then name="DEFAULT" end
  if gamestate.KeyUp then
    local fnc=gamestate.KeyUp[name]
    if fnc==nil then fnc=gamestate.KeyUp.DEFAULT end
    if fnc then fnc(key) return end
  end
end

--[[
-- experimental
function BuildDirectory()
	local command='dir "'..WD..'ps/objects" /s'
	local file=io.popen(command)
	local dir
	local directory={}
	for line in file:lines() do
		if string.sub(line,2,13)=="Directory of" then
	 		 dir=string.sub(line,15+string.len(WD)).."/"
		elseif string.match(line,".lua",string.len(line)-3)~=nil then
			if string.match(line,PLATFORM)==nil then
				 name=string.sub(line,40)
				 this={}
				 dofile(dir.."/"..name)
				 local obj={g=this.guid,p=dir,f=name,v=this.version}
				directory[#directory+1]=obj
			end
		end
	end
	return directory
end
]]--

---------------------------
--LIBRARY (li.fx)
---------------------------
-- load an object into the map objects table
function LoadObject(element)
  local guid=element.g
  local i
  local found=nil
  for i=1,#directory do
    local entry=directory[i]
    if entry.g==guid then
      found=entry
      break
    end
  end
  if found then
    local path=WD..found.p
    local file=found.f
    if library[guid] then       -- if not already loaded, then load it
      this=library[guid]
    else
      this={}                        -- empty object
      this.clone=function(a) return a end  -- default clone function
      this.path=path                 -- save where the files are
      this.file=file
      this.guid=guid
      this.paint="normal"
      dofile(path..PLATFORM..file)  -- add platform specific functions
      dofile(path..file)            -- add game specific functions
      this.hash=HashFile(path..file) -- hash the game specific file
      this:Load(params)              -- load the resources
      library[guid]=this             -- put it in the library
    end
    ListAppend(MapObjects,this)  	-- file it into the object library
    return this
  end
end

--Experimental for adding
function AddObject(obj,x,y,z)
  
  obj.a,obj.i={},{}
  local cell=map[x][y][z]
  local w
-- remove conflicting objects
  local removes=obj.removes
  if removes then
    for w=#cell,1,-1 do
      local deleted=false
      local existing=cell[w]
      local occupies=existing.occupies
      if occupies then
        local j
        for j=1,occupies:len() do
          local i
          for i=1,removes:len() do
            if occupies:byte(j)==removes:byte(i) then
            ListRemove(cell,existing)
            deleted=true
            break
            end
          end
          if deleted then break end
        end
      end
    end
  end
-- add in the new object
  local newobj=obj.clone(obj)
	ListAppend(cell,newobj)
--[[make sure there is a floor
  local hasfloor=false
  for w=#cell,1,-1 do
    local existing=cell[w]
    local occupies=existing.occupies
    if occupies then
      local j
      for j=1,occupies:len() do
        if occupies:byte(j)==70 then    --"F"
          hasfloor=true
        end
      end
    end
  end
  if hasfloor==false then
    ListAppend(cell,library["2208f9f4-5e4b-11dc-8314-0800200c9a66"])   -- floor
  end]]
  return newobj
end

function LoadMap(s)
  N,S,E,W="N","S","E","W"   -- to allow reading these in replay file
  level={}
  dofile(s)
  if level.replay then replay=level.replay end -- extract a replay
  map=ParseMap(level)
  return map
end

function Guid2Object(guid)
  local instance=library[guid]
  return instance.clone(instance)
end

-- parse a standard map structure --
function ParseMap(level)
  local x, y, z
  local ReadMap=level.map
-- load the  list for this map
  MapObjects={}
  for x=1,#level.objects do
    LoadObject(level.objects[x])
  end
-- read the map definition
	local instance
	local element
	local WriteMap={}										-- empty destination
	for z=1,#ReadMap do										-- for each plane
		for y=1,#ReadMap[z] do								-- for each row
			for x=1,#ReadMap[z][y] do 						-- for each cell in the row
				local ReadCell=ReadMap[z][y][x]				-- select the cell contents
				local WriteCell={} 							-- create an empty cell list
				if type(ReadCell)=="table" then
					for element=1,#ReadCell do
						local object=ReadCell[element]
						if type(object)=="table" then
							instance=MapObjects[object[1]]
							instance=instance.clone(instance)
							if instance.Read then
								instance:Read(object)
							end
						else                                  	-- else we need to pass parameters
							instance=MapObjects[object]
							instance=instance.clone(instance)
						end
						ListAppend(WriteCell,instance)
					end
				else
					instance=MapObjects[ReadCell]
					instance=instance.clone(instance)
					ListAppend(WriteCell,instance)
				end
				if x>#WriteMap then WriteMap[x]={} end
				if y>#WriteMap[x] then WriteMap[x][y]={} end
				WriteMap[x][y][z]=WriteCell
			end
		end
	end
	InitMap(WriteMap)
	return WriteMap
end

function recursiveClone(source) --same as Clone, but clones tables within the table, too. 
  local destination             --will result in stack overflow if source is large.
  if type(source)=="table" then
    destination={}
   local key,value
   for key,value in pairs(source) do
      if type(value)=="table" then
        destination[key]=recursiveClone(value)
      else
        destination[key]=value
      end
    end
  else
    destination=source
  end
  return destination
end

-- deep copy a table structure --
function Clone(source)
  local destination
  if type(source)=="table" then
    destination={}
   local key,value
   for key,value in pairs(source) do
      destination[key]=value
    end
  else
    destination=source
  end
  return destination
end

function InitMap(thismap)
  local holdmap=map     -- save because init functions use map directly
  map=thismap
  local w,x,y,z
  Pending={}  -- objects that still need to be processed this gameframe
  Complete={} -- objects that have been processed, and will become pending next frame
  Inactive={} -- objects that have been put to sleep, and will not become pending next frame
  for x=1,#level.objects do       -- preinit all the objects
    local obj=library[level.objects[x].g]
    if obj.PreInit~=nil then obj:PreInit() end
  end
  for x=1,#map do
    for y=1,#map[x] do
	  for z=1,#map[x][y] do
		for w=1,#map[x][y][z] do
			local obj=map[x][y][z][w]
			obj.a={}    --initialize attributes  (constant boolean values)
			obj.i={}    --initialize inventory
			if obj.init then
				obj:init(x,y,z)
			end
		end
	  end
    end
  end
  map=holdmap
end

function ListAppend(list,obj)
  list[#list+1]=obj
end

function ListRemove(list,obj)
  local z,l
  l=#list
  for z=1,l do
    if list[z]==obj then
      for z=z+1,l do
        list[z-1]=list[z]
      end
      list[l]=nil
      return
    end
  end
end

function MoveToList(obj,NewList)
  if obj.CurrentList then ListRemove(obj.CurrentList,obj) end   -- remove from curren tlist
  ListAppend(NewList,obj)                                       -- put in new list
  obj.CurrentList=NewList                                       -- bookkeeping
end

CheckDirty=function()
  if level~=nil then
    if level.modified==true then
      local text="File '"..FileName.."' is modified. Save changes?"
      local result=MessageBox(text,"Warning",MB_YESNOCANCEL+MB_DEFBUTTON1+MB_ICONEXCLAMATION)
      if result==IDYES then return AskSave() end
      if result==IDNO then return true end
      return false
    end
  end
  return true
end

AskLoadMap=function()
  if CheckDirty() then
    local name=GetOpenFileName("Open Map","DBL level *.lvl\0*.lvl\0")
    if name~=nil then 
      LoadMap(name)
      SetTitle(name.." | Dr. Bone")
      FileName=name
      return true
    end
  end
  return false
end

SaveMap=function(name)
  if name~=nil then
    level.modified=nil -- mark savaed
    level.date=os.date()
    WriteMap(name,level,map);
    SetTitle(name.." | Dr. Bone");
    FileName=name
    return true
  end
  return false
end

AskSave=function()
  if level~=nil then
    --local name=GetSaveFileName("Save map","DBL level *.lvl\0*.lvl\0All *.*\0*.*\0")
	local name=GetSaveFileName("Save level", "DBL level *.lvl\0*.lvl\0")
	if name and (not string.find(name, ".lvl")) then
		name=name..".lvl"
	end
    return SaveMap(name)
  end
  return true
end



--GRAPHICS (gr.fx)
function RenderSolidBackground(color)
  glClear(GL_COLOR_BUFFER_BIT + GL_DEPTH_BUFFER_BIT)	-- Clear The Screen And The Depth Buffer
	glDisable(GL_TEXTURE_2D)		-- Enable Texture Mapping ( NEW )
	glDisable(GL_LIGHTING)
	color=colors[color]
  glLoadIdentity()				-- Reset The View
	glColor3f(color[1],color[2],color[3])
	glBegin(GL_QUADS)
		-- Front Face
		glVertex3f(-50, -50,  -10)
		glVertex3f(50, -50, -10)
		glVertex3f(50, 50,  -10)
		glVertex3f(-50, 50, -10)
	glEnd()
end

-- rendering functions
function MapRender(map)
  transparents={{{},{},{},{}}}--1=floor, 2=bottom, 3=center, 4=top
  tx,ty,tz={{{},{},{},{}}},{{{},{},{},{}}},{{{},{},{},{}}}
  local w,x,y,z
	glEnable(GL_LIGHTING)
	glColor3f(1,1,1)
  glClear(GL_COLOR_BUFFER_BIT + GL_DEPTH_BUFFER_BIT)	-- Clear The Screen And The Depth Buffer
	glEnable(GL_TEXTURE_2D)		-- Enable Texture Mapping ( NEW )
  glLoadIdentity()				-- Reset The View
  

--  level.clip[1],level.clip[2]=9,9
--EXPERIMENTAL FOR GAMEPLAY--

  if level~=nil then level.clip={9,9} end
  local sizex=#map
  local sizey=#map[1]
  local showx,showy=gamestate.camera.x,gamestate.camera.y
  ClipMap=false
  local clipx, clipy=20,20
  --[[if level~=nil then 
    clipx,clipy=level.clip[1],level.clip[2]
  else
    clipx, clipy=11,11    --for menu background
  end]]
  local minx=(clipx+1)/2
  local miny=(clipy+1)/2
  local maxx=1+sizex-minx
  local maxy=1+sizey-miny
  local px,py
  if ClipMap==true then
    px,py=(clipx+3)/2,(clipy+3)/2
   --[[
    if showx<minx then showx=minx end
    if showy<miny then showy=miny end
    if showx>maxx then showx=maxx end
    if showy>maxy then showy=maxy end 
    ]]
  else
    px,py=GetPlanePoint(0,0,-gamestate.camera.z)
    px,py=px+20,20-py                                                    --changed 2's to 20's
  end

-----------------------------
  --local startz=math.max(gamestate.CurrentDeck-9,1)
  local startz=1
 

  glTranslatef(1-showx,showy-1,-gamestate.camera.z-gamestate.CurrentDeck)
  for z=startz,gamestate.CurrentDeck do
    local dz=GetDZ(z)
    --local h=((8-dz*2)/8)^2
    --local h= (0.5^(dz*1.5))
	--local h = (0.5^(dz*0.9))
	local h
	if dz==0 then h=1
	else h=math.max(0, H-0.05*dz)
	end
    
    for x=1,#map do
      local dx=x-showx
      if dx>=px then break end
      if dx>-px then
        glPushMatrix()
        for y=1,#map[x] do
          local dy=y-showy
          if dy >=py then break end
          if dy>-py then
              local cell=map[x][y][z]
              for w=1,#cell do 
              
                if not transparents[z] then 
                  transparents[z]={{},{},{},{}} 
                  tx[z],ty[z],tz[z]={{},{},{},{}},{{},{},{},{}},{{},{},{},{}}
                end
                local tr=cell[w].transparent
                if tr then

                  ListAppend(transparents[z][tr],cell[w])
                  ListAppend(tx[z][tr],x) ListAppend(ty[z][tr],y) ListAppend(tz[z][tr],z)
                else
                  cell[w]:Render(h) 
                  glColor3f(1,1,1)
                end
              end
          end
          glTranslatef(0,-1,0)
        end
        glPopMatrix()
      end
      glTranslatef(1,0,0)
    end
    glLoadIdentity()
    glTranslatef(1-showx,showy-1,-gamestate.camera.z-gamestate.CurrentDeck+z)
  end

  local f,k
  for k=startz,gamestate.CurrentDeck do
    local dz=GetDZ(k)
	--local h=((8-dz*2)/8)^2
    --local h=(0.5^(dz*0.9))
	local h
	if dz==0 then h=1
	else h=math.max(0, H-0.05*dz)
	end
    for f=1,#transparents[k] do
      for w=1,#transparents[k][f] do
        local obj=transparents[k][f][w]
        local x,y,z=tx[k][f][w],ty[k][f][w],tz[k][f][w]
        glPushMatrix()
        glLoadIdentity()
        glTranslatef(1-showx,showy-1,-gamestate.camera.z-gamestate.CurrentDeck)
        glTranslatef(x-1,1-y,z-1)
        obj:Render(h)
        glColor3f(1,1,1)
        glPopMatrix()
      end
    end
  end
  glDisable(GL_LIGHTING)
  if ClipMap==true then
    RenderMask(-gamestate.camera.z)
  end
end 

function RotateObjD(obj)
  if obj.d then glRotatef(obj.d,0,0,1) end
end

function shadowtext(s,f,b)
	glDisable(GL_TEXTURE_2D)		-- Enable Texture Mapping ( NEW )
	glDisable(GL_LIGHTING)
  local w,h,p=glMeasureText(s)
  local d=.04   -- shadow offset
  local v={{-d,-d},{-d,0},{-d,d},{d,-d},{d,0},{d,d},{0,-d},{0,d}}
  --[[
          glColor3f(1,0,1)
        	glBegin(GL_QUADS)
        		-- debug quad
        		glVertex3f(0, 0,  0)
        		glVertex3f(w, 0, 0)
        		glVertex3f(w, h,  0)
        		glVertex3f(0, h, 0)
        	glEnd()
        	--]]
  glTranslatef(0,0.2,0)   -- fudge factor
  glColor3f(b[1],b[2],b[3])
  local i
  for i=1,8 do
    glPushMatrix()
    glTranslatef(v[i][1],v[i][2],0)
    glDrawText(s)
    glPopMatrix()
  end
  glColor3f(f[1],f[2],f[3])
  glDrawText(s)
	glEnable(GL_LIGHTING)
	glEnable(GL_TEXTURE_2D)		-- Enable Texture Mapping ( NEW )
end

function RenderEditPart(s)
  s=s.item
  if s==nil then return end
	glDisable(GL_TEXTURE_2D)		-- Enable Texture Mapping ( NEW )
	glDisable(GL_LIGHTING)
	glColor3f(.25,.25,.25)
	glBegin(GL_QUADS)
		-- Front Face
		glVertex3f(0, 0,  0)
		glVertex3f(3, 0, 0)
		glVertex3f(3, 3,  0)
		glVertex3f(0, 3, 0)
	glEnd()
	glTranslatef(1.5,1.5,.51)
	glEnable(GL_LIGHTING)
	glEnable(GL_TEXTURE_2D)		-- Enable Texture Mapping ( NEW )
	glColor3f(1,1,1)
	s.Render(s,1)
end

function MeasureEditPart(s)
  if s==nil then return {0,0} end
  return {3,3}
end

function vdump(k,s,i)
  local j,t,j
  v=""
  for j=1,i do v=v.."." end
  if type(s)=="string" then print(v..k.."="..s) return end
  if type(s)=="table" then 
    print(v..k.."=table")
    for j,t in pairs(s) do vdump(j,t,i+1) end
    return 
  end
  if type(s)=="number" then print(v..k.."="..s) return end
  if type(s)=="function" then print(v..k.."()") return end
  print(type(s))
  return
end

function MeasureInventory(s)
  local obj=gamestate.camera.focus
  local count=0
  local k,v
  for k,v in pairs(obj.i) do
    local item=library[k]
    if item.MeasureInventory then
      count=count+item.MeasureInventory(obj)
    end
  end
  return {count,2}
end

function InventoryHelper(item,count)
  if count>0 then
    item.Render(item,1)
    glColor3f(1,1,1)
    if count>1 then
      glPushMatrix()
      glDisable(GL_DEPTH_TEST)
      glTranslatef(-.5,0,0)
      glScalef(.5,.5,.5)
      shadowtext(""..count,{1,1,1},{0,0,0})
      glEnable(GL_DEPTH_TEST)
      glPopMatrix()
    end
    glTranslatef(1,0,0)
  end
end

function RenderInventory(s)
	glTranslatef(0,0.5,0)
	glEnable(GL_LIGHTING)
	glEnable(GL_TEXTURE_2D)		-- Enable Texture Mapping ( NEW )
	glColor3f(1,1,1)
  local obj=gamestate.camera.focus
--  vdump("obj",obj.i,0)
  local k,v
  for k,v in pairs(obj.i) do
    local item=library[k]
    if item.RenderInventory then
      item.RenderInventory(obj)
    end
  end
end

function getsize(s)
  if type(s)=="function" then s=s() end
  if type(s)=="string" then
   local w,h=glMeasureText(s)
   h=h*1.1
   return {w,h}
  end
  if s.Measure~=nil then return s.Measure(s) end
  return {0,0}
end


function drawhud(hud,d)
  MouseOver="nil"
  glLoadIdentity()				-- Reset The View
  local cx,cy=GetPlanePoint(mouse.x,mouse.y,-d)
  cx=0-cx
  cy=0-cy
  local x,y,z,n,w,h,s,p,t
  glClear(GL_DEPTH_BUFFER_BIT)	-- Clear The Screen And The Depth Buffer
  local px,py=GetPlanePoint(0,0,-d)
  py=-py
  for y=1,#hud do
    local row=hud[y] if type(row)=="function" then row=row() end
    for x=1,#row do
    local cell=hud[y][x] if type(cell)=="function" then cell=cell() end
      local sizes={}
      t=0 z=1 for key,s in pairs(cell) do 
        if type(s)=="function" then s=s() end
        sizes[z]=getsize(s)
        t=t+sizes[z][2] sizes[z][3]=t
        z=z+1
      end
      z=1
      for key,s in pairs(cell) do --for z=1,n do
        if type(s)=="function" then s=s() end
        w,h,p=sizes[z][1],sizes[z][2],sizes[z][3]
   	    glLoadIdentity()
   	    local ix=({-px,0,px})[x]+(w*(({0,-0.5,-1})[x]))
   	    local iy=(({py,0,-py})[y])-p+(t*(({0,.5,1})[y]))
        --local color=colors[TCOLOR]
   	    -- tell editor what the mouse is over
        if cy>=iy and cy<=(iy+h) and cx>=ix and cx<=(ix+w) then
          MouseOver=s
        end

	      glTranslatef(ix,iy,-d)
        if type(s)=="string" then
		  local color=colors[TCOLOR]
		  local dcolor={0.1*color[1], 0.1*color[2], 0.1*color[3]}
          shadowtext(s,color,dcolor)
        end
        if s.Render then
          s.Render(s,1)
          glColor3f(1,1,1)
	      end
	      z=z+1
      end
    end
  end
end

function RenderPlaneUV(x,y,z,u1,v1,u2,v2)
	glBegin(GL_QUADS)
		-- Front Face
		glNormal3f(0,0,1);
		glTexCoord2f(u1, v1) glVertex3f(-x, -y,  z)
		glTexCoord2f(u2, v1) glVertex3f( x, -y,  z)
		glTexCoord2f(u2, v2) glVertex3f( x,  y,  z)
		glTexCoord2f(u1, v2) glVertex3f(-x,  y,  z)
	glEnd()
end

function RenderCubeUV(x,y,z,u1,v1,u2,v2)
	glBegin(GL_QUADS)
		-- Top Face
		glNormal3f(0,0,1);
		glTexCoord2f(u1, v1) glVertex3f(-x, -y,  z)
		glTexCoord2f(u2, v1) glVertex3f( x, -y,  z)
		glTexCoord2f(u2, v2) glVertex3f( x,  y,  z)
		glTexCoord2f(u1, v2) glVertex3f(-x,  y,  z)
		-- Bottom Face
		glNormal3f(0,0,-1)
		glTexCoord2f(u1, v1) glVertex3f(-x, -y, -z)
		glTexCoord2f(u2, v1) glVertex3f( x, -y, -z)
		glTexCoord2f(u2, v2) glVertex3f( x,  y, -z)
		glTexCoord2f(u1, v2) glVertex3f(-x,  y, -z)
		-- North Face
		glNormal3f(0,1,0);
		glTexCoord2f(u1, v2) glVertex3f(-x,  y, -z)
		glTexCoord2f(u1, v1) glVertex3f(-x,  y,  z)
		glTexCoord2f(u2, v1) glVertex3f( x,  y,  z)
		glTexCoord2f(u2, v2) glVertex3f( x,  y, -z)
		-- South face
		glNormal3f(0,-1,0);
		glTexCoord2f(u2, v2) glVertex3f(-x, -y, -z)
		glTexCoord2f(u1, v2) glVertex3f( x, -y, -z)
		glTexCoord2f(u1, v1) glVertex3f( x, -y,  z)
		glTexCoord2f(u2, v1) glVertex3f(-x, -y,  z)
		-- East face
		glNormal3f(1,0,0);
		glTexCoord2f(u2, v1) glVertex3f( x, -y, -z)
		glTexCoord2f(u2, v2) glVertex3f( x,  y, -z)
		glTexCoord2f(u1, v2) glVertex3f( x,  y,  z)
		glTexCoord2f(u1, v1) glVertex3f( x, -y,  z)
		-- West Face
		glNormal3f(-1,0,0);
		glTexCoord2f(u1, v1) glVertex3f(-x, -y, -z)
		glTexCoord2f(u2, v1) glVertex3f(-x, -y,  z)
		glTexCoord2f(u2, v2) glVertex3f(-x,  y,  z)
		glTexCoord2f(u1, v2) glVertex3f(-x,  y, -z)
	glEnd()
end

function RenderCube(x,y,z)
  RenderCubeUV(z,y,x,0,0,1,1)
end

function RenderCursor()
 	glDisable(GL_TEXTURE_2D)		-- Disable Texture Mapping 
	if mousemap then
    glColor3f(0,1,0)
  	glLoadIdentity()
    glTranslatef(mousemap.x-gamestate.camera.x,gamestate.camera.y-mousemap.y,-gamestate.camera.z-1)
    RenderCube(.5,.5,.5)
 	else
    glColor3f(1,1,0)
    glLoadIdentity()
    glTranslatef(-crosshair.x,-crosshair.y,-gamestate.camera.z-1)
    glLineWidth(5)
  	glBegin(GL_LINES)
  	glVertex3f(-.5,0,.501)  glVertex3f(.5,0,.501)
  	glVertex3f(0,-.5,.501)  glVertex3f(0,.5,.501)
  	glEnd()
 	end

end

function RenderMask(cameraz)
  glLoadIdentity()				-- Reset The View
  glTranslatef(0,0,cameraz)
    glColor3f(0,0,0)
  local x1,y1,z1,z2=(level.clip[1]/2)-.001,(level.clip[2]/2)-.001,-1.0,50.0
-- draw a visual blocking frame that hides objects outside the visible map
-- z-buffering is still turned on, so these planes clip map objects
-- as they pass into and out of the play area  
	glBegin(GL_QUADS)
		glVertex3f(-x1,-y1,z1)
		glVertex3f(x1,-y1,z1)
		glVertex3f(x1,-y1,z2)
		glVertex3f(-x1,-y1,z2)

		glVertex3f(-x1,y1,z1)
		glVertex3f(x1,y1,z1)
		glVertex3f(x1,y1,z2)
		glVertex3f(-x1,y1,z2)

		glVertex3f(-x1,-y1,z1)
		glVertex3f(-x1,y1,z1)
		glVertex3f(-x1,y1,z2)
		glVertex3f(-x1,-y1,z2)

		glVertex3f(x1,-y1,z1)
		glVertex3f(x1,y1,z1)
		glVertex3f(x1,y1,z2)
		glVertex3f(x1,-y1,z2)

	glEnd()

end

function ClickableTextMeasure(s)
  if type(s)=="function" then s=s() end
  return getsize(s.s)
end

ClickableTextRender=function(this)
  local s=this.s
  if type(s)=="function" then s=s() end
  local f
  if this==MouseOver then
    f=this.h
  else
    f=this.n
  end
  local shadow={0.1*f[1],0.1*f[2],0.1*f[3]}
  shadowtext(s,f,shadow)
end

MakeClickableText=function(s,n,h,left,right)
  local result={}
  result.Measure=ClickableTextMeasure
  result.left=left
  result.right=right
  result.s=s
  result.Render=ClickableTextRender
  result.h=colors[h]
  result.n=colors[n]
  return result
end

-----------------------
--EDITOR (ed.fx)
-----------------------
function dump(a)
  local s=""
  if type(a)=="table" then
    s=s..'{'
    local i
    for i=1,#a do
      if i~=1 then s=s..',' end
      s=s..dump(a[i])
    end
    s=s..'}'
  else
    s=s..a
  end
  return s
end

-- dynamically builds parts page from directory
BuildParts=function(page)
  local savelevel=level
  level={}
  level.title='Parts '..page
  level.author=''
  level.date=''
  level.notes=''
  level.objects={}
 -- build linear list
  local list={}
  local i=1
  local j=1
  local floor=1
  for i=1,#directory do
    if directory[i].g=="9a41f5ef-e6a2-405d-9416-113b927d0659" then floor=i end
  end
  for i=1,#directory do
    level.objects[i]={}
    level.objects[i].g=directory[i].g
    local obj=LoadObject(level.objects[i])
    if obj.examples then
      local examples=obj.examples(i,{floor,1})
      local x
      for x=1,#examples do
        list[j]=examples[x]
        j=j+1
        end
    else
      list[j]=i
      j=j+1
    end
  end
-- build the map
  level.map={{}}
  local x,y=1,1
  for i=1,#list do
    if level.map[1][y]==nil then level.map[1][y]={} end
    level.map[1][y][x]=list[i]
    x=x+1
    if x>16 then
      x=1
      y=y+1
    end
  end
  map=ParseMap(level)
  level=savelevel
  return map
end

function GrabLeft(x,y)                         -- left mouse button pressed
	Parts.left.item=map[x][y][1][1]
  Editor.Start()
end

function GrabRight(x,y)                         -- right mouse button pressed
	Parts.right.item=map[x][y][1][1]
  Editor.Start()
end

function StartParts(n)
  Editor.savemap()
  Parts.Start(n)                           -- show parts page
end

function dectop() 
	if #map[1]>1 then 
		level.modified=true 
		local x 
		for x=1,#map do table.remove(map[x],1) end 
		Editor.camera.y=Editor.camera.y-1 
	end
end

function decleft() 
	if #map>1 then 
		level.modified=true 
		table.remove(map,1) 
		Editor.camera.x=Editor.camera.x-1 
	end 
end

function decright() 
	if #map>1 then 
		level.modified=true 
		table.remove(map) 
	end 
end

function decbottom() 
	if #map[1]>1 then 
		level.modified=true 
		local x 
		for x=1,#map do 
			table.remove(map[x]) 
		end 
	end 
end

function decabove()
  if #map[1][1]>1 then
    level.modified=true
	if Editor.CurrentDeck==#map[1][1] then
	  Editor.CurrentDeck=Editor.CurrentDeck-1
	end
	local x
	for x=1,#map do
	  local y
	  for y=1,#map[1] do
	    table.remove(map[x][y])
	  end
	end
  end
end

function decbelow()
  if #map[1][1]>1 then
    level.modified=true
	local x
	for x=1,#map do
	  local y
	  for y=1,#map[1] do
	    table.remove(map[x][y],1)
	  end
	end
	if Editor.CurrentDeck~=1 then
	  Editor.CurrentDeck=Editor.CurrentDeck-1
	end
  end
end

function inctop()
  if #map*(#map[1]+1)*#map[1][1]>MAXVOLUME then return end
  local x,z
  for x=1,#map do table.insert(map[x],1,{})
    for z=1,#map[1][2] do 
	  table.insert(map[x][1],{})
      PaintWith(Parts.right.item,x,1,z) 
    end
  end
  Editor.camera.y=Editor.camera.y+1
end

function incleft()
  if (#map+1)*#map[1]*#map[1][1]>MAXVOLUME then return end
  local y,z
  table.insert(map,1,{})
  for y=1,#map[2] do 
    table.insert(map[1],{})
	for z=1,#map[2][1] do
	  table.insert(map[1][y],{})
      PaintWith(Parts.right.item,1,y,z) 
	end
  end
  Editor.camera.x=Editor.camera.x+1
end

function incright()
  if (#map+1)*#map[1]*#map[1][1]>MAXVOLUME then return end
  local y,z
  table.insert(map,{})
  for y=1,#map[1] do
	table.insert(map[#map],{})
	for z=1,#map[1][1] do
	  table.insert(map[#map][y],{})
	  PaintWith(Parts.right.item,#map,y,z)
	end
  end
end

function incbottom()
  if #map*(#map[1]+1)*#map[1][1]>MAXVOLUME then return end
  local x,z
  for x=1,#map do 
    table.insert(map[x],{})
	for z=1,#map[1][1] do
	  table.insert(map[x][#map[1]],{})
	  PaintWith(Parts.right.item,x,#map[1],z) 
	end
  end
end

function incabove()
  if #map*#map[1]*(1+#map[1][1])>MAXVOLUME then return end
  local x,y
  for x=1,#map do
	for y=1,#map[1] do
	  table.insert(map[x][y],{})
	  PaintWith(Parts.right.item,x,y,#map[x][y])
	end
  end
end

function incbelow()
  if #map*#map[1]*(1+#map[1][1])>MAXVOLUME then return end
  local x,y
  for x=1,#map do 
	for y=1,#map[1] do
	  table.insert(map[x][y],1,{})
	  PaintWith(Parts.right.item,x,y,1) 
	end
  end
  Editor.CurrentDeck=Editor.CurrentDeck+1
end


function PaintWith(obj,x,y,z)
  if obj.PaintWith~=nil then
    obj.PaintWith(obj,x,y,z)
  else
  AddObject(obj,x,y,z)
  end
  level.modified=true -- flag the the map has been modified so it asks to be saved
end

function PaintLeft(x,y)                         -- left mouse button pressed
  z=Editor.CurrentDeck
  PaintWith(Parts.left.item,x,y,z)
end

function PaintRight(x,y)                         -- right mouse button pressed
  z=Editor.CurrentDeck
  PaintWith(Parts.right.item,x,y,z)
end

EncodeLevel=function(level,map)

  --experimental:
  level.CurrentDeck=gamestate.CurrentDeck
  level.lastcamera=gamestate.camera
  --end experimental

  local w,x,y,z
  local found={}
  local tempg=Globals   -- we need to save these
  Globals={}      -- clear out globals
  level.objects={}
  level.map={}
  local n=1
  for z=1,#map[1][1] do --scan the map
	level.map[z]={}
	for y=1,#map[1] do -- scan the map
		level.map[z][y]={}
		for x=1,#map do
			level.map[z][y][x]={}
			for w=1,#map[x][y][z] do
				local obj=map[x][y][z][w]  -- got an object
				if found[obj.guid]==nil then  -- add it to the object list
					level.objects[n]={g=obj.guid} found[obj.guid]=n n=n+1
				end
				if obj.Write then   -- add it to the new map
					level.map[z][y][x][w]=obj.Write(obj,found[obj.guid]) -- if it has a Write function
				else
					level.map[z][y][x][w]=found[obj.guid]     -- default is just the type number
				end
			end
		end
    end
  end
  Globals=tempg   -- restore the globals
end

-- write the map to the a file
function WriteMap(filename,level,map)
  EncodeLevel(level,map)
  local file=io.open(filename,"w")
  file:write("level=")
  writers.table(file,level,1)
  file:close()
end

function EditorRotate(obj,rotateD)
  local d
  if obj.d then
  
	  if rotateD==-1 then
      d=obj.d+90
    else
  	  d=obj.d-90
    end
    
    if d<0 then d=d+360
    elseif d>270 then d=d-360
    end
    
    obj.d=d
    
    local fcn=obj.EditorInit
    if fcn then fcn(obj) end
    
	end
end 

--GAMEPLAY (gm.fx)

function render()
  gamestate.render()
  collectgarbage("collect")
end

function OnTimer()
  if gamestate.OnTimer then
    gamestate.OnTimer(event)
  end
  collectgarbage("collect")
end





StartReplay=function()
  if replay~=nil and level~=nil then
    replay_speed=1
    ReplayLevel.Start()
  end
end
-----------------------------------------------------------------------
function Hover(obj,speed,force)
  local here=map[obj.x][obj.y][obj.z]
  local fnc,w
  for w=#here,1,-1 do          -- test all the objects
    local objhere=here[w]
    if objhere~=obj then
      fnc=objhere.Hover
      if fnc then fnc(objhere,obj,speed,force) end
    end
  end
end

-- check the move snd start if move is legal
function TestMove(obj,speed,force,newx,newy,newz)
  local w
  if newx<1 then return 0 end                 -- check map boundries
  if newy<1 then return 0 end
  if newz<1 then return 0 end
  if newx>#map then return 0 end
  if newy>#map[newx] then return 0 end
  if newz>#map[newx][newy] then return 0 end
  local there=map[newx][newy][newz]
  local original_speed,original_force=speed,force
  local here=map[obj.x][obj.y][obj.z]
  local fnc
  for w=#here,1,-1 do          -- test all exits
    local objhere=here[w]
    if objhere~=obj then
      fnc=objhere.TestExit
      if fnc then
        speed,force=fnc(objhere,obj,speed,force,newx,newy,newz)
        if speed==0 or force==0 then return 0,0 end
      end
    end
  end
  for w=#there,1,-1 do            -- test all entries
    local objthere=there[w]
    fnc=objthere.TestEnter
    if fnc then
      speed,force=fnc(objthere,obj,speed,force,newx,newy,newz)
      if speed==0 or force==0 then return 0,0 end
    end
  end
  for w=#here,1,-1 do          -- test all exits again (needed for pushblock, elevator, etc...)
    local objhere=here[w]
    if objhere~=obj then
      fnc=objhere.TestExit2
      if fnc then
        speed,force=fnc(objhere,obj,speed,force,newx,newy,newz)
        if speed==0 or force==0 then return 0,0 end
      end
    end
  end
  for w=#there,1,-1 do            -- test all entries again (needed for pushblock, elevator, etc...)
    local objthere=there[w]
    fnc=objthere.TestEnter2
    if fnc then
      speed,force=fnc(objthere,obj,speed,force,newx,newy,newz)
      if speed==0 or force==0 then return 0,0 end 
    end
  end
  local speed,force=original_speed,original_force
--[[
  for w=1,#here do          -- do all exits
    local objhere=here[w]
    if objhere~=obj then
      fnc=objhere.StartExit
      if fnc then
        speed,force=fnc(objhere,obj,speed,force,newx,newy,newz)
        if speed==0 or force==0 then return 0,0 end --this should NEVER happen
      end
    end
  end
  for w=1,#there do            -- do all entries
    local objthere=there[w]
    fnc=objthere.StartEnter
    if fnc then
      speed,force=fnc(objthere,obj,speed,force,newx,newy,newz)
      if speed==0 or force==0 then return 0,0 end  --this should NEVER happen
    end
  end]]
  return speed,force
end

-- try a move based on a vector direction
-- start the move no matter what
function StartMove(obj,speed,force,newx,newy,newz)
  local here=map[obj.x][obj.y][obj.z]
  local there=map[newx][newy][newz]
  local w
  for w=1,#here do          -- do all exits
    local objhere=here[w]
    if objhere~=obj then
      fnc=objhere.StartExit
      if fnc then
        speed,force=fnc(objhere,obj,speed,force,newx,newy,newz)
      end
    end
  end
  for w=1,#there do            -- do all entries
    local objthere=there[w]
    fnc=objthere.StartEnter
    if fnc then
      speed,force=fnc(objthere,obj,speed,force,newx,newy,newz)
    end
  end
  ListAppend(map[newx][newy][newz],obj)        -- put this object in the new location
  ListRemove(map[obj.x][obj.y][obj.z],obj)               -- remove it from the current location
  obj.fromx,obj.fromy,obj.fromz=obj.x,obj.y,obj.z                -- save previous location
  obj.x,obj.y,obj.z=newx,newy,newz                          -- set the new map position
  obj.offset=1                                    -- set state to moving
  if speed~=0 then
    obj.MoveForce=force
    obj.MoveSpeed=speed
  end
  return speed,force                                    -- and the initial speed
end

function TryMove(obj,direction,speed,force)
  local vector=vectors[direction]
  if vector then             -- if the event is a legal move
    local newx=obj.x+vector.dx          -- get the new position
    local newy=obj.y+vector.dy
    local newz=obj.z --only allow horizontal moves
    obj.d=direction
    if TestMove(obj,speed,force,newx,newy,newz)~=0 then  -- if the test caused a move
      StartMove(obj,speed,force,newx,newy,newz)  -- start the move
      return speed,force
    end
  else                                                -- if the move is not legal
    if obj[stop]~=nil then obj:stop() end
  end
  return 0,0
end

function VerticalMove(obj,dir,speed,force)
  local newz=obj.z+dir
  if TestMove(obj,speed,force,obj.x,obj.y,newz)~=0 then
    StartMove(obj,speed,force,obj.x,obj.y,newz)
    return speed, force
  end
  return 0,0
end

-- move the object and return true if it is still moving
function ContinueMove(obj)
  local fnc
  if obj.offset>0 then          -- if we are not there yet
    obj.offset=obj.offset-obj.MoveSpeed                  -- step closer by speed
    if obj.offset<=0.001 then                         -- when we arrive
      obj.offset=0                                    -- recenter
      local from=map[obj.fromx][obj.fromy][obj.fromz]
      local to=map[obj.x][obj.y][obj.z]
      local w
      for w=#from,1,-1 do          -- do all exits
        local objfrom=from[w]
        fnc=objfrom.FinishExit
        if fnc then
          fnc(objfrom,obj)
        end
      end
      for w=#to,1,-1 do             -- do all enters
        local objto=to[w]
        if objto~=obj then
          fnc=objto.FinishEnter
          if fnc then
            fnc(objto,obj)
          end
        end
      end
      if obj.MoveSpeed==0 then
        return true                --stopped, but don't call logic till next frame
      end
    end
    return true                   -- is still moving
  end
  return false                    -- was already stopped
end

--given a rotated direction d1 and a true direction d2,
--returns the relative direction from the rotated perspective
function GetRelativeDirection(d1,d2)
  local newd=d2-d1
  if newd<0 then newd=newd+360 end
  return newd
end

--given a rotated direction d1 and a relative direction d2,
--returns the true direction
function GetTrueDirection(d1,d2)
  local newd=d2+d1
  if newd>270 then newd=newd-360 end
  return newd
end

--given an object *pointing* in a direction obj.d, which was
--moving in direction oldd and is now moving in direction newd,
--rotates the pointing direction by the same amount that the
--direction of movement was rotated
function RotateObjectDirection(obj,newd,oldd)
  if not obj.d then return end  --if the object has no direction, do nothing
  newd=newd+obj.d-oldd
  if newd>=360 then newd=newd-360 end
  if newd<0 then newd=newd+360 end
  obj.d=newd
end

function GetDirection(oldx,oldy,oldz,newx,newy,newz)
  if newx>oldx then return 270 end
  if newx<oldx then return 90 end
  if newy>oldy then return 180 end
  if newy<oldy then return 0 end
  if newz>oldz then return 1 end --up
  if newz<oldz then return -1 end  --down
  return "~"
end

function GetDZ(z)
	if z then return math.min(gamestate.CurrentDeck-z,3) end
  return 0
end

function RemoveFromGame(obj)
  local fcn=obj.delete
  if fcn then
    fcn(obj)
  end
  obj.delete=nil
  ListRemove(map[obj.x][obj.y][obj.z],obj) 
  MoveToList(obj,{})
  obj.logic=RemoveFromGame
  if obj.a.player==true then gamestate.SetLose(obj.deathmessage) end
end

function DistanceSound(snd,dist,x,y,z,vertDist)
  if not vertDist then vertDist=2 end --default is to hear things on the current deck and one below
  local camera=gamestate.camera
  if math.abs(x-camera.x) <= dist
    and math.abs(y-camera.y) <= dist
    and math.floor(gamestate.CurrentDeck-z) <= vertDist
    and gamestate.CurrentDeck-z >= 0 then
      PlaySound(snd)
  end
end
    

--standard logic for pushblocks which keeps them out of the active list when not moving
BlockLogic=function(this)
  this.awake=nil
  if ContinueMove(this) then 
    MoveToList(this,Complete)
  else

	if this.fromz>this.z and this.drop then 
	  if this:drop()==1 then return end
    end
    if this.stop then this:stop() end
    local here=map[this.x][this.y][this.z]
    local w
    for w=#here,1,-1 do
      local fcn=here[w].Hover
      if fcn then this.awake=true end
    end
    if this.awake then
      Hover(this,1/12,1)
      MoveToList(this,Complete)
    else
      MoveToList(this,{})
    end
  end
end

function color(col)  --returns tuple
  if colors[col] then
    return colors[col][1], colors[col][2], colors[col][3]
  else
    return 1,1,1 --white
  end
end

function round(n, precision)
  local m = 10^(precision or 0)
  return math.floor(m*n + 0.5)/m
end
