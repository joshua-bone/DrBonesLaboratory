---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="e6f08228-36ca-4334-aee9-5269955b51d9"
this.version="2008/04/20-22:08:00"
this.author="Chuck Sommerville"
this.name="Player"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return {{{T,180},F}}   --{{this, this.d},floor}
end

--rotates direction in editor
this.EditorRotate=EditorRotate

this.PaintWith=function(this,x,y,z)
  local i,j,k,w
  for i=1,#map do
    for j=1,#map[1] do
      for k=1,#map[1][1] do
        for w=1,#map[i][j][k] do
          if map[i][j][k][w].guid==this.guid then
            ListRemove(map[i][j][k],map[i][j][k][w])
          end
        end
      end
    end
  end
  AddObject(this,x,y,z)
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="T"      --occupies top
this.removes="T"       --removes top
this.clone=Clone
this.transparent=4 --top transparency (1=floor, 2=bottom, 3=center, 4=top)
this.sound=LoadSound(WD.."game/sounds/player.wav")

this.PreInit=function(this)
  --Globals[this.guid]={}   -- set initial count to zero
  gamestate.camera.focus=nil
end

this.init=function(this,x,y,z)
  local camera=gamestate.camera
  --ListAppend(Globals[this.guid],this)

--ATTRIBUTES
  this.a.player=true      -- attribute player

--STATS
  this.a.power=1
  
--SPEED,  FORCE,  LOCATION
  this.MoveSpeed,this.MoveForce=0,0
  this.x,this.y,this.z=x,y,z
  this:stop()
  this.lasttick=0 --the last time at which this tried to move
  MoveToList(this,Pending)      -- add object to active list
  if gamestate~=Editor then
    camera.focus=this
    camera.x=this.x+(this.fromx-this.x)*this.offset   -- track the camera
    camera.y=this.y+(this.fromy-this.y)*this.offset
    gamestate.CurrentDeck=this.z
  end
end

this.Read=function(this,params)
  this.d=params[2]              -- read direction
end

this.Write=function(this,T)
  return {T,this.d}      -- write the direction
end

--stops the object's motion
this.stop=function(this)
  this.offset=0
  this.MoveSpeed=0
  this.fromx,this.fromy,this.fromz=this.x,this.y,this.z
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  if obj.a.power<=this.a.power then 
    return 0,0               -- can't enter if equal or less power
  else
    return speed,force       --can enter if more powerful
  end
end

this.TestEnter2=function(this,obj,speed,force,newx,newy,newz)
  death.start(this,"explode",30); -- remove player
  return speed, force
end  

---------------------------------------------------------------------------------------------------
--GAME LOGIC
---------------------------------------------------------------------------------------------------

this.logic=function(this)       -- game logic call per game frame
  local camera=gamestate.camera
  if not ContinueMove(this) then      -- if we have reached the center
    local dur=tick-this.lasttick
    if event~=0 and dur>5 then         -- if a keypress, and less than 8 ticks since we tried to move last
      this.lasttick=tick              --reset time of last move attempt
      if (TryMove(this,dirs[event],1/12,1))==0 then  --try to move
	        if event2~=0 then 
				if(TryMove(this,dirs[event2],1/12,1))==0 then
					PlaySound(this.sound) 
					Hover(this,1/12,1) 			    -- hover if move fails
				else
					event,event2=event2,event
				end
			else
				PlaySound(this.sound) 
				Hover(this,1/12,1) 			    -- hover if move fails
			end
	  else
	    if event2 ~= 0 then
		    local oldvector=vectors[dirs[event]] --since we've already updated position w/ move
			local vector=vectors[dirs[event2]]
			if vector then             -- if the event is a legal move
			    this.x=this.x-oldvector.dx
				this.y=this.y-oldvector.dy
				local newx=this.x+vector.dx          -- get the new position
				local newy=this.y+vector.dy
				local newz=this.z --only allow horizontal moves
				TestMove(this,1/12,1,newx,newy,newz)
				this.x=this.x+oldvector.dx
				this.y=this.y+oldvector.dy
			end
		end
      end
    else
      Hover(this,1/12,1)              --hover if no keypress
    end
  end
  --if camera.focus==this then
    camera.x=this.x+(this.fromx-this.x)*this.offset   -- track the camera
    camera.y=this.y+(this.fromy-this.y)*this.offset
	gamestate.CurrentDeck=this.z
  --end
  gamestate.hud[3][2]["inventory"]=HudInventory       -- draw inventory
  MoveToList(this,Complete)                         -- we are done
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  glPushMatrix()  -- save the matrix because we are going to modify it
  glTranslatef((this.fromx-this.x)*this.offset,(this.y-this.fromy)*this.offset,(this.fromz-this.z)*this.offset)  -- offset from middle of square

  local frame = 0
  if event~=0 or this.offset~=0 then frame=math.floor(1+(tick/4)%8) end
  if this.a.floatingIn then 
    glTranslatef(0,-1/4,-1/10)
    glRotatef(15,1,0,0) 
  end

  glEnable(GL_BLEND)
  glBlendFunc(GL_DST_COLOR,GL_ZERO)  
	glCallList(this.glist+(this.d/90)+frame*8+4)                     -- render the mask  
  glBlendFunc(GL_ONE, GL_ONE) 
  glColor3f(h,h,h)  
  glCallList(this.glist+(this.d/90)+frame*8)  
  glDisable(GL_BLEND)
  glPopMatrix()                             -- restore the matrix
end

this.Load=function(this,params)
  this.Resource=LoadTexture(this.path.."graphics/0003_player.bmp")   -- load resources
  this.glist=glGenLists(72)    -- create the render list
  local g,h=28/2048,28/1024
  local i, j
  for i=0,8 do
    for j=0,7 do
      glNewList(this.glist+i*8+j,GL_COMPILE)
      glBindTexture(GL_TEXTURE_2D,this.Resource) 
      RenderPlaneUV(.5,.5,TOPLEVEL,i/16+g,(7-j)/8+h,(i+1)/16-g,(8-j)/8-h)   
      glEndList()
    end
  end
end