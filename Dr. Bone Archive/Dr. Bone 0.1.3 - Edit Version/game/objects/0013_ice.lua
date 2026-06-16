---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="8210bcba-7b80-490e-8248-78ec28684fe8"
this.name="Ice"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------
this.examples=function(T,F)
  return {T}
end

this.occupies="F"
this.removes="F"

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.Write=function(this,T)
    return T
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------                    

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz)
  if d==1 then return 0,0 end --can't enter from below unless empty space
  return speed, force   
end

this.TestExit=function(this,obj,speed,force,newx,newy,newz)
  --dirty fix: monsters trapped on ice cannot exit of their own accord. See this.Hover()
  if obj.a.auto and obj.SlideDir then
    return 0,0
  end
  
  return speed, force
end

this.StartEnter=function(this,obj,speed,force,newx,newy,newz)
  local boot = "e0159bb2-2559-44df-b9d0-5d836c6f0a14"

  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz) --the true direction the obj is travelling
  if d==-1 or (obj.i[boot] and obj.i[boot][4]>0) then 
    return speed, force --enter at normal speed if falling or has ice boot
  else
    obj.EnterSpeed=obj.MoveSpeed --save the object's entering speed
    obj.SlideDir=d --tag the object as sliding in the current direction
    return 1/6, force --objects on ice travel at 1/6 instead of 1/12 speed
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
  local vector = vectors[d] --vector in desired direction of movement
  local newx = obj.x+vector.dx  --x-component of desired location
  local newy = obj.y+vector.dy  --y-component of desired location
  local speed = TestMove(obj,1/6,obj.MoveForce,newx,newy,obj.z) --test the new move
  if speed~=0 then                                  -- if the test caused a move
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
    local d1=obj.SlideDir
    local d2=(obj.SlideDir+180)%360
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
  glColor3f(h,h,h) --darken with depth
  glCallList(this.glist)
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."graphics/0013_ice.bmp")
  this.glist=glGenLists(1)
  glNewList(this.glist,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,FLOORLEVEL,0,0,1,1)
  glEndList()
end
