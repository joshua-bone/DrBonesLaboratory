--init the openGL graphics
glShadeModel(GL_SMOOTH)
glClearColor(0.5,0.5,0.5,0)
glClearDepth(1)
glEnable(GL_DEPTH_TEST)
glDepthFunc(GL_LEQUAL)
glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
--glLightfv(GL_LIGHT1, GL_AMBIENT,  1/2, 1/2, 1/2, 1.0)
--glLightfv(GL_LIGHT1, GL_DIFFUSE,  1, 1, 1, 1.0)
--glLightfv(GL_LIGHT1, GL_POSITION,  -1.0, 1.0, 1.0, 0) 
--glEnable(GL_LIGHT1)
glEnable(GL_COLOR_MATERIAL)
glColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE)

--graphics library
grL={}

-----------------------------------------------------
--datastructs in alphabetical order with descriptions
-----------------------------------------------------

grL.colors={
--dictionary mapping color names to their rgb values
  black={0,0,0},
  white={1,1,1}, 
  red={1,0,0},
  green={0,1,0},
  blue={0,0,1},
  yellow={1,1,0},
  magenta={1,0,1},
  cyan={0,1,1},
}

--add darkened colors to grL.colors----------------------------------
local tempcolors={}
for key, val in pairs(grL.colors) do
  if key~="black" then
    local i
    for i=1,9 do
      tempcolors[key..i*10] = {val[1]*i*0.1, val[2]*i*0.1, val[3]*i*0.1}
    end
  end
end
for key,val in pairs(tempcolors) do
  grL.colors[key]=val
end
--end add darkened colors----------------------------------------------

-----------------------------------------------------
--functions in alphabetical order with descriptions
-----------------------------------------------------

--this function returns the width and height of
--a hud entry of arbitary type
grL.GetHudEntrySize=function(entry)
  local width, height=0,0

  --if entry is a function, replace it with its return value
  if type(entry)=="function" then
    entry=entry()
  end
  
  if type(entry)=="number" then
    entry=string.format("%d", entry)
  end
  
  --if entry is a string, use the glMeasureText() function
  --to return the width and height
  if type(entry)=="string" then
    width, height=glMeasureText(entry)
  end
  
  if entry.Measure then 
    local s=entry.Measure(entry) 
	width, height=s[1],s[2]
  end
  
  return {width, height}
end

--This function loads a background image from a given path
--and builds a glist sized according to the passed arguments.
--It then returns the number of the glist.
grL.LoadBackgroundImage=function(path,x,y,z)
  local tex=LoadTexture(path)
  local list=glGenLists(1)
  glNewList(list,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D, tex)
  grL.RenderPlaneUV(x/2,y/2,z,0,0,1,1)  
  glEndList()
  return list
end

grL.MeasureEditPart=function(s)
  if s then return {3,3}
  else return {0,0}
  end
end

grL.RenderCursor=function()
  glDisable(GL_TEXTURE_2D)
  --glDisable(GL_LIGHTING)
  glLoadIdentity()
  local c=grL.colors[TCOLOR]
  glColor3f(c[1],c[2],c[3])
  glLineWidth(5)
  if not gs.Ctrl then --if we are in paint mode
	glTranslatef(inL.mouse.map.x-gs.Cam.x,
	             -inL.mouse.map.y+gs.Cam.y,
				 -gs.Cam.z-1.3) -- -1)
	glBegin(GL_LINES)  --draw a square
	  glVertex3f(-.5,-.5,.01) glVertex3f(.5,-.5,.01)
	  glVertex3f(.5,-.5,.01)  glVertex3f(.5,.5,.01)
	  glVertex3f(-.5,-.5,.01) glVertex3f(-.5,.5,.01)
	  glVertex3f(-.5,.5,.01)  glVertex3f(.5,.5,.01)
	glEnd()
  else --if we are in cursor mode
    glTranslatef(-inL.mouse.screen.x,
	             -inL.mouse.screen.y,
				 -gs.Cam.z-1)
	glBegin(GL_LINES) --draw a crosshair
	  glVertex3f(-.5,0,.01) glVertex3f(.5,0,.01)
	  glVertex3f(0,-.5,.01) glVertex3f(0,.5,.01)
	glEnd()
  end
  glColor3f(1,1,1)
  glEnable(GL_TEXTURE_2D)
  --glEnable(GL_LIGHTING)
end

grL.RenderEditPart=function(s)
  s=s.Item
  if s then
	glDisable(GL_TEXTURE_2D)
	--glDisable(GL_LIGHTING)
	glTranslatef(1.5,1.5,.01)
	glScalef(3.5,3.5,0)
	--glEnable(GL_LIGHTING)
	glEnable(GL_TEXTURE_2D)
	glColor3f(1,1,1)
	s.Render(s,1)
  end
end

--This function simply renders the glist supplied as an argument.
--Useful for backgrounds.
grL.RenderGLList=function(glist)
  glLoadIdentity()
  glTranslatef(1-gs.Cam.x,gs.Cam.y-1,-gs.Cam.z-gs.atZ)
  glColor3f(1,1,1)
  glColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE)
  glCallList(glist)
end

--this function displays a hud on the screen. z should be <0.
--the larger the |z| value, the smaller the text will appear
--hud should be a 3x3 table, entries can be text, functions
--which return tables or text, or any table with an obj.Render().
grL.RenderHud=function(hud, z)
  inL.mouse.obj=nil --reset the object the mouse is over to nothing

  if not z then z=HUDZVAL end --default z value for huds
  if z>0 then z=-z end --turn positive values into negative ones.
  glLoadIdentity() --reset the view
  glClear(GL_DEPTH_BUFFER_BIT) --Clear the Screen & Depth Buffer
  
  --get the openGL coordinates for the center point of our screen
  local planex, planey = GetPlanePoint(0,0,z)
  planey=-planey --since GetPlanePoint returns a negative y-value
  
  local i,j,k
  for j=1,#hud do --for each row
    --if the row is a function, call it. It should replace
    --itself with a table row.															   -----------------
    local row=hud[j]                                                                       --grL.RenderHud()
    if type(row)=="function" then row=row() end											   -----------------
	
	for i=1,#row do --for each cell in row
	  --if the cell is a function, call it. It should replace
	  --itself with a table cell.
	  local cell=row[i]
	  if type(cell)=="function" then cell=cell() end
	  
	  local totHeight=0 --store the total height of the cell
	  local totWidth=0 --store the max width of the entries in the cell
	  local sizes={} --store the width, height, and cumulative height for each entry
	  
	  for k=1,#cell do --for each entry in cell, get & store sizes
	    --if the entry is a function, call it. It should replace
		--itself with a string or other renderable object
	    local entry=cell[k]
		if type(entry)=="function" then entry=entry() end											   -----------------
		sizes[k]=grL.GetHudEntrySize(entry) --returns {width, height}                                  --grL.RenderHud()
		totHeight=totHeight+sizes[k][2] --add the height of this cell to the total					   -----------------
		totWidth=math.max(totWidth, sizes[k][1]) --store if largest width so far
		sizes[k][3]=totHeight --the third entry is the cell's cumulative y-position
		                      --as measured from the top of the list
	  end
	  
	  --RENDER THE HUD CELL BACKGROUND IF APPLICABLE
	  local bk = cell.background
	  if bk then
	    local color1=bk.color
		local color2=bk.border
		local size=bk.size
		if size=="fit" then size={totWidth, totHeight} end
		local dx=TEXTBOXBORDERSIZE
	    glLoadIdentity()
	    local transx=(
		   ({-planex, 0, planex})[i]
		   -({0,totWidth/2,totWidth})[i]
		   +({1,0,-1})[i]*SCREENMARGIN
		   )
		local transy=(
		   ({planey,0,-planey})[j]  --Up or Down
		   -({1,0,-1})[j]*SCREENMARGIN  --offset from edge of screen
		   -sizes[#cell][3]  --down to bottom entry
		   +totHeight*({0,0.5,1})[j] --compensate for total height
		   )
		glTranslatef(transx, transy, z)
		grL.RenderSolidBox(color2, -2*dx, size[1]+2*dx, -2*dx, size[2]+2*dx, -0.002)
		grL.RenderSolidBox(color1, -dx, size[1]+dx, -dx, size[2]+dx, -0.001)
	  end
	  
	  for k=1,#cell do --render each entry in cell 
	  	--if the entry is a function, call it. It should replace
		--itself with a string or other renderable object
	    local entry=cell[k]
		local width, height, cumheight=sizes[k][1],sizes[k][2],sizes[k][3]
		glLoadIdentity() --reset the view
		local transx=(  --how far to translate L/R from the center of the screen
		  ({-planex,0,planex})[i]  --translate left, center, or translate right
		  -({0,totWidth/2,width})[i] --compensate for width of the entry
		  +({1,0,-1})[i]*SCREENMARGIN --offset from edge of screen
		  )
		local transy=(   --how far to translate U/D from center of the screen
		  ({planey,0,-planey})[j]  --translate up, center, or translate down
		  -cumheight --translate down to entry's cumulative y-position										-----------------
		  +totHeight*({0,0.5,1})[j] --compensate for total height of the cell                               --grL.RenderHud()
		  -({1,0,-1})[j]*SCREENMARGIN --offset from edge of screen											-----------------
		  )
		local mousex, mousey=GetPlanePoint(inL.mouse.x, inL.mouse.y,z) --find where the mouse is
		mousex, mousey=-mousex,-mousey
		if mousey>=transy and mousey<=transy+height  --if mouse is within the height range of this entry
		   and mousex>=transx and mousex<=transx+width then  --and within the width range of this entry
		     inL.mouse.obj=entry             --then store the entry as the object the mouse is now over
	    end
		glTranslatef(transx, transy, z) 
		if type(entry)=="function" then entry=entry() end
		
		if type(entry)=="number" then entry=string.format("%d", entry) end
		
		if type(entry)=="string" then --if the entry is a string
		  local color=grL.colors[TCOLOR] --the default text color
		  grL.RenderSolidText(entry, color) --render the string
		end
		
		if entry.Render then --if the entry is an object 
		                     --with a render function, call it
		  entry.Render(entry)
		end
		
	  end
	  
	end
	
  end
end

grL.RenderMap=function(map)
  --sort the transparent objects for rendering back to front
  local transparents={{{},{},{},{}}}--1=floor, 2=bottom, 3=center, 4=top
  local tx={{{},{},{},{}}}   --x coords of cells w/ transparent objects
  local ty={{{},{},{},{}}}   --y coords of cells w/ transparent objects
  local tz={{{},{},{},{}}}   --z coords of cells w/ transparent objects
  local w,x,y,z
  
  --glEnable(GL_LIGHTING)
  glColor3f(1,1,1)
  --glClear(GL_DEPTH_BUFFER_BIT)
  glClear(GL_COLOR_BUFFER_BIT + GL_DEPTH_BUFFER_BIT) -- clear screen/depth buffer
  glEnable(GL_TEXTURE_2D)		-- enable texture mapping
  glLoadIdentity()				-- reset view

  local planex,planey
  planex,planey=GetPlanePoint(0,0,-gs.Cam.z)
  planey=-planey  --since GetPlanePoint returns +x, -y
  --planex,planey=planex+2,2-planey

  local startz=1 --start rendering at bottom floor of level
                 --may want to change this if working with very tall levels
 
  glTranslatef(1-gs.Cam.x,gs.Cam.y-1,-gs.Cam.z-gs.atZ)
  
  ------------------------------------------
  --RENDER ALL THE NON-TRANSPARENT OBJECTS--
  --SAVE TRANSPARENTS TO RENDER LATER-------
  ------------------------------------------
  
  for z=startz,gs.atZ do
    local dz=gs.atZ-z --height difference between the floor we're rendering
	                  --and the floor the gamestate is focused on
					  
	--SHADING: h determines how bright to render the objects----------
	--h==1 means full brightness, h==0 means black
	--dependent on dz (see above)
	local h=grL.ShadeWithDepth(dz)
    
    for x=1,#Map do
	  --horizontal offset from center of screen to the column we're rendering
      local dx=x-gs.Cam.x 
      --if dx>=planex then break end     --uncomment lines to prevent rendering
      --if dx>-planex then               --outside of game window (buggy b/c of dz)
        glPushMatrix()
        for y=1,#Map[x] do
		  --vertical offset from center of screen to the cell we're rendering
          local dy=y-gs.Cam.y
          --if dy >=py then break end    --uncomment lines to prevent rendering
          --if dy>-py then               --outside of game window (buggy b/c of dz) 
              local cell=Map[x][y][z]
              for w=1,#cell do 
                if not transparents[z] then 
                  transparents[z]={{},{},{},{}} --1=floor, 2=bottom, 3=center, 4=top
				  --x,y,z coords of cells w/ transparent objects
                  tx[z],ty[z],tz[z]={{},{},{},{}},{{},{},{},{}},{{},{},{},{}}
                end
                local tr=cell[w].transparent --1=floor, 2=bottom, 3=center, 4=top
                if tr then --if the object is transparent, add it to the transparents list for rendering later
                  table.insert(transparents[z][tr],cell[w])
                  table.insert(tx[z][tr],x) table.insert(ty[z][tr],y) table.insert(tz[z][tr],z)
                else --if object is not transparent, render it now
                  cell[w]:Render(h) 
                  glColor3f(1,1,1)
                end
              end
          --end
          glTranslatef(0,-1,0)
        end
        glPopMatrix()
      --end
      glTranslatef(1,0,0)
    end
    glLoadIdentity()
    glTranslatef(1-gs.Cam.x,gs.Cam.y-1,-gs.Cam.z-gs.atZ+z)
  end

  -----------------------------------
  --RENDER ALL THE TRANSPARENTS NOW--
  -----------------------------------
  local f,k
  for k=startz,gs.atZ do
    local dz=gs.atZ-k --height difference between the floor we're rendering
	                  --and the floor the gamestate is focused on
					  
	--SHADING: h determines how bright to render the objects----------
	--h==1 means full brightness, h==0 means black
	--dependent on dz (see above)
	local h=grL.ShadeWithDepth(dz)

    for f=1,#transparents[k] do --go through all cells with
                              	--transparent objects on this z-level
      for w=1,#transparents[k][f] do --go through each cell in order:
	                                 --1=floor, 2=bottom, 3=center, 4=top
        local obj=transparents[k][f][w]
        local x,y,z=tx[k][f][w],ty[k][f][w],tz[k][f][w]
        glPushMatrix()
        glLoadIdentity()
        glTranslatef(1-gs.Cam.x,gs.Cam.y-1,-gs.Cam.z-gs.atZ)
        glTranslatef(x-1,1-y,z-1)
        obj:Render(h)
        glColor3f(1,1,1)
        glPopMatrix()
      end
    end
  end
  --glDisable(GL_LIGHTING)
end

--This function renders a flat plane from a texture. It
--should be called after a call to glBindTexture. 
--u1,v1 should correspond to the x & y of the lower left 
--point of the rectangle we want to cut out from the texture.
--u2,v2 should correspond to the x & y of the upper right
--point of the rectangle we want to cut out from the texture.
grL.RenderPlaneUV=function(x,y,z,u1,v1,u2,v2)
  glBegin(GL_QUADS)
	glNormal3f(0,0,1)
	glTexCoord2f(u1, v1) glVertex3f(-x, -y,  z)
	glTexCoord2f(u2, v1) glVertex3f( x, -y,  z)
	glTexCoord2f(u2, v2) glVertex3f( x,  y,  z)
	glTexCoord2f(u1, v2) glVertex3f(-x,  y,  z)
  glEnd()
end

--purpose: render a solid background of a given color
grL.RenderSolidBackground=function(color)

  --if argument is a color name then get the rgb values
  --from the gr.colors structure
  if type(color)=="string" then
    color=grL.colors[color]
	--if the color isn't in the library then
	--use the default background color
	if not color then color=grL.colors[BCOL] end 
  end
  glClear(GL_COLOR_BUFFER_BIT + GL_DEPTH_BUFFER_BIT)
  glDisable(GL_TEXTURE_2D)
  --glDisable(GL_LIGHTING)
  glLoadIdentity()
  glColor3f(color[1],color[2],color[3])
  glBegin(GL_QUADS)
	glVertex3f(-50, -50,  -10)
	glVertex3f(50, -50, -10)
	glVertex3f(50, 50,  -10)
	glVertex3f(-50, 50, -10)
  glEnd()
end

grL.RenderSolidBox=function(color, x1, x2, y1, y2, z)
  --if argument is a color name then get the rgb values
  --from the gr.colors structure
  if not z then z=-.001 end --DEBUG THIS
  if type(color)=="string" then
    color=grL.colors[color]
	--if the color isn't in the library then
	--use the default background color
	if not color then color=grL.colors[BCOL] end 
  end
  --glClear(GL_COLOR_BUFFER_BIT)
  glDisable(GL_TEXTURE_2D)
  --glDisable(GL_LIGHTING)
  --glLoadIdentity()
  glColor3f(color[1],color[2],color[3])
  glBegin(GL_QUADS)
	glVertex3f(x1, y1,  z)
	glVertex3f(x2, y1, z)
	glVertex3f(x2, y2,  z)
	glVertex3f(x1, y2, z)
  glEnd()
  --glEnable(GL_LIGHTING)
  glEnable(GL_TEXTURE_2D)
  glColor3f(1,1,1)
end

grL.RenderSolidText=function(text, color)
  --if we passed in the name of a color, get the rgb values
  if type(color)=="string" then
    color=grL.colors[color]
  end
  if color then
    glDisable(GL_TEXTURE_2D)
   -- glDisable(GL_LIGHTING)
    glColor3f(color[1], color[2], color[3])
	glDrawText(text)
    glEnable(GL_TEXTURE_2D)
    --glEnable(GL_LIGHTING)
  end
end

grL.ShadeWithDepth=function(dz)
  local h
  if dz==0 then h=1
  else h=math.max(0, 0.6-0.05*dz)
  end
  return h
end


