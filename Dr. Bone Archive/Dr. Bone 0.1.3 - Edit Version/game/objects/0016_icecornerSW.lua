---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------
this.guid="b3afcf89-a4a3-47b2-8347-a0c9a5d5c700"
this.name="Ice Corner SW"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------
this.examples=function(T,F)
  return {T} 
end

this.occupies="FSW"
this.removes="FSW"

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.Write=function(this,T)
    return T
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.rules={} --ice corner SW        
this.rules[dirs["S"]]=dirs["E"]   -- S -> E                      
this.rules[dirs["W"]]=dirs["N"]   -- W -> N                     

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)

  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz)
  if d==1 or not this.rules[d] then 
    return 0,0 
  end --can't enter from below or from S or E
  return speed, force   
end

this.TestExit=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz) --the true direction the obj is travelling
  if this.rules[d] then
    return 0,0
  else
    return speed, force
  end
end

this.StartEnter=function(this,obj,speed,force,newx,newy,newz)
  local boot = "e0159bb2-2559-44df-b9d0-5d836c6f0a14"
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz) --the true direction the obj is travelling
  this.EnterSpeed=obj.MoveSpeed
  
  if d==-1 or (obj.i[boot] and obj.i[boot][4]>0) then 
    return speed, force --enter at normal speed if falling or has ice boot
  else
    obj.EnterSpeed=obj.MoveSpeed --save the object's entering speed
    obj.SlideDir=d --tag the object as sliding in the current direction
    return 1/6, force --objects on ice travel at 1/6 instead of 1/12
  end
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

-- when an object finishes entering, it should continue in the new direction, or bounce back
this.FinishEnter=function(this,obj)
  local boot = "e0159bb2-2559-44df-b9d0-5d836c6f0a14"

  --if object has ice skates in its inventory, or came from above, then stop its motion and return
  if (obj.i[boot] and obj.i[boot][4]>0)
  or (obj.fromz>obj.z) then
    obj.MoveSpeed=0
    return
  end
  
  obj.MoveSpeed=obj.EnterSpeed           -- restore the object's entering speed
  obj.EnterSpeed=nil  
  
  local d=GetDirection(obj.fromx,obj.fromy,obj.fromz,obj.x,obj.y,obj.z) --the true direction the obj is travelling
  local oldD=d --save the true direction so we can properly rotate the object later
  
  --change the direction for a NW ice corner
  d=this.rules[d]
   
  local vector = vectors[d] --vector in desired direction of movement
  local newx = obj.x+vector.dx  --x-component of desired location
  local newy = obj.y+vector.dy  --y-component of desired location
  local speed = TestMove(obj,1/6,obj.MoveForce,newx,newy,obj.z) --test the new move
  if speed~=0 then                                  -- if the test caused a move
    RotateObjectDirection(obj,d,oldD)      --rotate the object's pointing direction by the amount that its moving direction changed
    StartMove(obj,speed,obj.MoveForce,newx,newy,obj.z)    -- start the move
  else      --we need to bounce back to our old location                  
    local newx=obj.fromx  --x-component of desired location
    local newy=obj.fromy  --y-component of desired location
    local speed=TestMove(obj,1/6,obj.MoveForce,newx,newy,obj.z)  -- see if the move is possible
    if speed~=0 then                                  -- if the test caused a move 
      RotateObjectDirection(obj,180,0)     --reverse obj.d
      StartMove(obj,speed,obj.MoveForce,newx,newy,obj.z)        -- start the move
    end
  end
end

-- if an object is not moving but here
this.Hover=function(this,obj,speed,force)
  local boot = "e0159bb2-2559-44df-b9d0-5d836c6f0a14"

  if obj.SlideDir and not (obj.i[boot] and obj.i[boot][4]>0) then 
    local d1=this.rules[obj.SlideDir] --the direction it wants to exit
	local d2=(obj.SlideDir+180)%360 --back the way we came
	obj.SlideDir=nil --remove the tag so that it can exit
	if TryMove(obj,d1,1/6,obj.MoveForce)==0 then
      if TryMove(obj,d2,1/6,obj.MoveForce)==0 then
        obj.MoveSpeed=0 --still stopped
      end
    end
	obj.SlideDir=d1 --restore the tag again so it can't exit on it's own and will be forced to Hover
  end
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  glPushMatrix() --save the matrix because we are going to modify it
  glColor3f(h,h,h) --darken with depth
  glCallList(this.glist) --call ice floor first,
  
  --[[dirty fix to avoid rewriting the openGL code, just uses the NW ice corner code and 
    rotates it.]]
  this.d=dirs["W"]
  RotateObjD(this)       --rotate according to this.d
  this.d=nil
  
  glCallList(this.glist+1) --then call ice corner
  glPopMatrix() --restore the matrix
end

this.Load=function(this)
  this.Resource1=LoadTexture(this.path.."graphics/0013_ice.bmp")
  this.Resource2=LoadTexture(this.path.."graphics/0002_wall.bmp")
  this.glist=glGenLists(2)
  
  glNewList(this.glist,GL_COMPILE)			--ice floor
    glBindTexture(GL_TEXTURE_2D,this.Resource1)
    RenderPlaneUV(.5,.5,FLOORLEVEL,0,0,1,1)
  glEndList()

  glNewList(this.glist+1,GL_COMPILE)
  	glBindTexture(GL_TEXTURE_2D,this.Resource2)
    glBegin(GL_QUADS)
      --West Face
    	glNormal3f(-1,0,0)
      glTexCoord2f(0,0) glVertex3f(-.5,-.4,-.5)
      glTexCoord2f(0,1) glVertex3f(-.5,-.4,.5)
    	glTexCoord2f(1,1) glVertex3f(-.5,.5,.5)
    	glTexCoord2f(1,0) glVertex3f(-.5,.5,-.5)
    	--North Face
    	glNormal3f(0,1,0)
      glTexCoord2f(0,0) glVertex3f(-.5,.5,-.5)
      glTexCoord2f(0,1) glVertex3f(-.5,.5,.5)
    	glTexCoord2f(1,1) glVertex3f( .4,.5,.5)
    	glTexCoord2f(1,0) glVertex3f( .4,.5,-.5)
      
      --Curve
      local theta,x1,x2,y1,y2
      for theta=90,170 do
    	  x1=math.cos(math.rad(theta))*.9
    	  x2=math.cos(math.rad(theta+10))*.9
    	  y1=math.sin(math.rad(theta))*.9
    	  y2=math.sin(math.rad(theta+10))*.9

        local denom=math.sqrt((x2-x1)^2+(y1-y2)^2)
    	glNormal3f((y1-y2)/denom,(x2-x1)/denom,0)
        glTexCoord2f((theta-90)/90,0) glVertex3f(x1+.4,y1-.4,-.5)
        glTexCoord2f((theta-90)/90,1) glVertex3f(x1+.4,y1-.4,.5)
    	glTexCoord2f((theta-80)/90,1) glVertex3f(x2+.4,y2-.4,.5)
    	glTexCoord2f((theta-80)/90,0) glVertex3f(x2+.4,y2-.4,-.5)
        
        --Top Face
    	glNormal3f(0,0,1)	
        glTexCoord2f((x1+.9)*20/36,y2*10/12) glVertex3f(x1+.4,y1-.4,.5)
        glTexCoord2f((x1+.9)*20/36,3/4) glVertex3f(x1+.4,.5,.5)
    	glTexCoord2f((x2+.9)*20/36,3/4) glVertex3f(x2+.4,.5,.5)
    	glTexCoord2f((x2+.9)*20/36,y1*10/12) glVertex3f(x2+.4,y2-.4,.5)
      end
    glEnd()
  glEndList()
end
