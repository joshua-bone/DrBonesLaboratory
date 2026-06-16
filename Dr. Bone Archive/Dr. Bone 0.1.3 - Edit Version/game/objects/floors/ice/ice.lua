---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------
this.guid="8210bcba-7b80-490e-8248-78ec28684fe8"
this.version="2008/05/12-08:43:46"
this.name="Ice"
this.author="Joshua Bone"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------
this.examples=function(T,F)
  return {{{T,1,0}},{{T,2,0}}} --{{this, this.rule, this.d}}  (ice floor, ice corner,)
end

--rotates direction in editor
this.EditorRotate=EditorRotate

this.paramupdate=function(this)
  if this.rule==1 then  --ice floor
    this.occupies, this.removes="F","F"
  else                      --ice corner
    this.EditorInit(this) 
  end
end

--switches between ice floor and ice corner in editor
this.EditorShuffle=function(this,dir)
  this.rule=3-this.rule
  this.paramupdate(this)
end  

--changes this.occupies and this.removes based on rotation in Editor
this.EditorInit=function(this)
  local dir1=GetTrueDirection(this.d,0)
  local dir2=GetTrueDirection(this.d,90)
  --occupies floor and the walls that make up the corner
  this.occupies="F"..dirs[dir1]..dirs[dir2] 
  this.removes=this.occupies
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------
this.clone=Clone  --allow individual instances

this.Read=function(this,params)
  this.d=params[3]   --pass on direction 
  this.rule=params[2]
  this.paramupdate(this)
end

this.Write=function(this,T)
    return {T,this.rule,this.d}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.rules={} --ice corner NW        
this.rules[0]=270   -- N -> E                      
this.rules[90]=180  -- W -> S                     

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz)
  if d==1 then return 0,0 end --can't enter from below unless empty space
  if d==-1 then return speed, force end --can always enter from above
  if this.rule==2 then  --ice corner
    d=GetRelativeDirection(this.d,d) --the relative direction based on this rotation
    if not this.rules[d] then  --if no rule exists for the intended direction, and obj is not falling
      return 0,0          --obj may not enter
    end 
  end
	return speed, force   
end

this.TestExit=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz) --the true direction the obj is travelling
  if this.rule==2 then  --ice corner
    d=GetRelativeDirection(this.d,d) --the relative direction based on this rotation
    if not this.rules[d-180] then  --if no rule exists for entering from the intended exit direction,
      return 0,0              --obj may not exit
    end
  else --ice floor
    if obj.a.auto and this.EnterDir and this.EnterDir~=d and this.EnterDir~=(d+180)%360 then
      return 0,0
    end
  end
  return speed, force
end

this.StartEnter=function(this,obj,speed,force,newx,newy,newz)
  this.EnterSpeed=obj.MoveSpeed
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz) --the true direction the obj is travelling
  if d==-1 then 
    return speed, force
  else
    this.EnterDir=d
    return 1/6, force
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
  
  obj.MoveSpeed=this.EnterSpeed           -- restore the object's entering speed
  local d=GetDirection(obj.fromx,obj.fromy,obj.fromz,obj.x,obj.y,obj.z) --the true direction the obj is travelling
  local oldD=d --save the true direction so we can properly rotate the object later
  if this.rule==2 then  --if this is an ice corner
    d=GetRelativeDirection(this.d,d) --the relative direction based on this rotation
    d=this.rules[d]      --the new relative direction to move in, according to ice corner rules
    d=GetTrueDirection(this.d,d)  --the new true direction to move in
  end
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

  if this.EnterDir and not (obj.i[boot] and obj.i[boot][4]>0) then 
    local d=(this.EnterDir+180)%360
    if TryMove(obj,this.EnterDir,1/6,obj.MoveForce)==0 then
      if TryMove(obj,d,1/6,obj.MoveForce)==0 then
        obj.MoveSpeed=0 --still stopped
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  glColor3f(h,h,h) --darken with depth
  if this.rule==1 then
    glCallList(this.glist)
  else --ice corner
    glPushMatrix() --save the matrix because we are going to modify it
    glCallList(this.glist) --call ice floor first,
    RotateObjD(this)       --rotate according to this.d
    glCallList(this.glist+1) --then call ice corner
    glPopMatrix() --restore the matrix
  end
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."ice.bmp")
  this.glist=glGenLists(2)
  local g=1/256
  
  glNewList(this.glist,GL_COMPILE)			--ice floor
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,FLOORLEVEL,0+g,0,1/2-g,1)
  glEndList()

  glNewList(this.glist+1,GL_COMPILE)
  	glBindTexture(GL_TEXTURE_2D,this.Resource)
    glBegin(GL_QUADS)
      --West Face
    	glNormal3f(-1,0,0)
      glTexCoord2f(1/2+g,0) glVertex3f(-.5,-.4,-.5)
      glTexCoord2f(1/2+g,1) glVertex3f(-.5,-.4,.5)
    	glTexCoord2f(1-g,1) glVertex3f(-.5,.5,.5)
    	glTexCoord2f(1-g,0) glVertex3f(-.5,.5,-.5)
    	--North Face
    	glNormal3f(0,1,0)
      glTexCoord2f(1/2+g,0) glVertex3f(-.5,.5,-.5)
      glTexCoord2f(1/2+g,1) glVertex3f(-.5,.5,.5)
    	glTexCoord2f(1-g,1) glVertex3f( .4,.5,.5)
    	glTexCoord2f(1-g,0) glVertex3f( .4,.5,-.5)
      
      --Curve
      local theta,x1,x2,y1,y2
      for theta=90,170 do
    	  x1=math.cos(math.rad(theta))*.9
    	  x2=math.cos(math.rad(theta+10))*.9
    	  y1=math.sin(math.rad(theta))*.9
    	  y2=math.sin(math.rad(theta+10))*.9

        local denom=math.sqrt((x2-x1)^2+(y1-y2)^2)
    	  glNormal3f((y1-y2)/denom,(x2-x1)/denom,0)
        glTexCoord2f(theta/180+g,0) glVertex3f(x1+.4,y1-.4,-.5)
        glTexCoord2f(theta/180+g,1) glVertex3f(x1+.4,y1-.4,.5)
    	  glTexCoord2f((theta+10)/180-g,1) glVertex3f(x2+.4,y2-.4,.5)
    	  glTexCoord2f((theta+10)/180-g,0) glVertex3f(x2+.4,y2-.4,-.5)
        
        --Top Face
    	  glNormal3f(0,0,1)	
        glTexCoord2f((x1+.9)*10/36+1/2+g,y2*10/12) glVertex3f(x1+.4,y1-.4,.5)
        glTexCoord2f((x1+.9)*10/36+1/2+g,3/4) glVertex3f(x1+.4,.5,.5)
    	  glTexCoord2f((x2+.9)*10/36+1/2+g,3/4) glVertex3f(x2+.4,.5,.5)
    	  glTexCoord2f((x2+.9)*10/36+1/2+g,y1*10/12) glVertex3f(x2+.4,y2-.4,.5)
      end
    glEnd()
  glEndList()
end
