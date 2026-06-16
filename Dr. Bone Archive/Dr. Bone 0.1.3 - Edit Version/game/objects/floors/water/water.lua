---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="1dc832bf-01bb-48d4-a25d-397c70519a98"
this.author="Joshua Bone"
this.version="2008/06/10-08:57:20"
this.name="Water"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return{T}
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="F"
this.removes="F"
this.sound=LoadSound(WD.."game/sounds/water.wav")

this.Write=function(this,T)
  return T
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.fromx,obj.fromy,obj.fromz,newx,newy,newz)
  if d==1 then return 0,0 end --can't enter from below unless empty space
  if d==-1 then return speed, force end --can always enter from above
  
  local bot="88f59a96-c802-43fe-81c8-780ad2fccf91"
  if obj.guid==bot and obj.rule==2 then return 0,0 end --rhr bots (aka paramecium) cannot enter (NEW)
  return speed, force
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  local boot = "e0159bb2-2559-44df-b9d0-5d836c6f0a14"
  obj.MoveSpeed=0   --stop the object
 
  --if object floats naturally or has flippers, tag it as floating
  if (obj.i[boot] and obj.i[boot][3]>0) then --if object has flippers
    obj.a.floatingIn=true
  --else interact normally
  else 
    DistanceSound(this.sound,5,obj.x,obj.y,obj.z)
    local fcn=obj.Interactions
    if fcn and fcn[this.guid] then --if the object has defined interactions with this element
      fcn[this.guid](obj,this)     --then do those
    else
      death.start(obj,"sink",30,"You Can't Swim Without Flippers!") --default is to destroy the object
    end
  end
end

this.FinishExit=function(this,obj)
  obj.a.floatingIn=nil  --object is no longer floating in water
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  glColor3f(h,h,h) --darken with depth
  glCallList(this.glist+(math.floor(tick/6)%11))
end

this.Load=function(this)
  this.glist=glGenLists(11)
  local h = 1/1024 --offset by 1 pixel to prevent other elements from showing at seams
  this.Resource=LoadTexture(this.path.."graphics/0020_water.bmp")
  for i=0,10 do
      glNewList(this.glist+i,GL_COMPILE)  --build water
      glBindTexture(GL_TEXTURE_2D,this.Resource)
      RenderPlaneUV(.5,.5,FLOORLEVEL,i/16,0,(i+1)/16,1)
      glEndList()
  end
end