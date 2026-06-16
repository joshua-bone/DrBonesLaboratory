---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="1ab8c531-ecb7-4bb0-a4a8-631ad5240d5a"
this.name="Force Floor North"


---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------
this.colors={"red","green","yellow","blue","magenta","cyan","orange","brown"}

this.examples=function(T,F)
  --{{this,this.rule,this.color,this.d}}  (green force floor ON, same OFF, green random force floor ON, same OFF)
  return {{{T,1,2,0}},{{T,2,2,0}},{{T,3,2,0}},{{T,4,2,0}}}    
end

--rotates direction in editor
this.EditorRotate=EditorRotate

this.EditorShuffle=function(this,dir)
  this.color=(this.color+dir)%8
  if this.color==0 then this.color=8 end
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------
this.occupies="F"
this.removes="F"
this.clone=Clone              -- allow individual instances
 
this.Read=function(this,params)
  this.rule=params[2]
  this.color=params[3] 
  this.d=params[4] 
end

this.Write=function(this,T)
  return {T,this.rule,this.color,this.d}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.toggle={{1,2,3,4},{2,1,4,3}}

--note: objects can enter from below, I think it will be more fun that way

--save the entry condition
this.StartEnter=function(this,obj,speed,force)
  this.EnterSpeed=obj.MoveSpeed --save object's entering speed; will give it back at FinishEnter
  return speed,force
end

this.getCurrent=function(this,rule,color)
  local toggle="be4c179f-9c1c-494a-8af6-fd305f8f7013" --toggle button
  if Globals[toggle] then
	return this.toggle[Globals[toggle][color]][rule]
  else
    return 3   --fix me PLEASE (always ON until we get toggles working)
  end
end

this.TestExit=function(this,obj,speed,force,newx,newy,newz)
  local current=this:getCurrent(this.rule,this.color)
  if (current==1 or current==3) and obj.a.auto then  --force floor ON & obj is automated
    local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz) --the object's true direction of motion
    d=GetRelativeDirection(this.d,d)  --the direction relative to this rotation
    if d~=0 then return 0,0 end --can't exit to rear or to sides
  end
  return speed,force --default is allow exit
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  local boot = "e0159bb2-2559-44df-b9d0-5d836c6f0a14"
  local current=this:getCurrent(this.rule,this.color)
 
  if (current==2 or current==4) or (obj.i[boot] and obj.i[boot][1]>0) then 
    obj.MoveSpeed=0 --acts just like a floor if toggled off or if obj has suction boots
  else  --force floor FinishEnter  
    if current==3 then  --random force floor
      this.d=(math.random(4)-1)*90
    end 
    if obj.a.player then      -- if the player
      -- if previous was forced, and a key was pressed NOT in direction of force
      if this.EnterSpeed~=0 and event~=0 and dirs[event]~=this.d then
  	    obj.MoveSpeed=0
        return
      end
    end
    TryMove(obj,this.d,1/6,2)        -- otherwise set speed to 1/6, force to 2
  end
  this.EnterSpeed=0 
end

-- if an object is not moving but here
this.Hover=function(this,obj,speed,force)
  local boot = "e0159bb2-2559-44df-b9d0-5d836c6f0a14"
  local current=this:getCurrent(this.rule,this.color)
  --if this is an active force floor, and obj does not have suction boots
  if (current==1 or current==3) and not (obj.i[boot] and obj.i[boot][1]>0) then 
    if current==3 then  --random force floor
      this.d=(math.random(4)-1)*90
    end
    obj.MoveSpeed=speed
    if TryMove(obj,this.d,1/6,2)==0 then
      obj.MoveSpeed=0 --still stopped
      if obj.a.player then PlaySound(obj.sound) end
    end
  end
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  local current=this:getCurrent(this.rule,this.color)
  local r,g,b=color(this.colors[this.color])
  if current<3 then
    glColor3f(r*h,g*h,b*h)
    local thistick=tick
    --if current==1 and gamestate~=PlayLevel then thistick=os.time()*24
    if current==2 then thistick=0 end --force floor OFF
    glPushMatrix()
    RotateObjD(this)
    glCallList(this.glist+(thistick)%16)
    glPopMatrix()
  else --random force floor
    glColor3f(r*h,g*h,b*h)
    local thistick=tick
    --if current==3 and gamestate~=PlayLevel then thistick=os.time()*7
    if current==4 then thistick=0 end --force floor OFF
    glPushMatrix()
    glScalef(.5,.5,1)
    glTranslatef(-1/2,1/2,0)
    glCallList(this.glist+(thistick)%16)
    glTranslatef(1,0,0)
    glRotatef(-90,0,0,1)
    glCallList(this.glist+(thistick)%16)
    glTranslatef(1,0,0)
    glRotatef(-90,0,0,1)
    glCallList(this.glist+(thistick)%16)
    glTranslatef(1,0,0)
    glRotatef(-90,0,0,1)
    glCallList(this.glist+(thistick)%16)
    glPopMatrix()
  end
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."graphics/0022_forcefloor.bmp")
  this.glist=glGenLists(16) --16 frames
  for i=0,15 do
    glNewList(this.glist+i,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(0.5,0.5,FLOORLEVEL,0,(16-i)/16,1,(16-i)/16+1)
    glEndList()
  end  
end
