---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="b0138afc-3357-4dba-b3e8-2cea2d6db89d"
this.name="Fire"

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
  --element referenced in this function
  local bot="88f59a96-c802-43fe-81c8-780ad2fccf91"
  if obj.guid==bot and obj.rule==1 then return 0,0 end		--lhr bots (aka tarantula) cannot enter
  return speed,force
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  local boot = "e0159bb2-2559-44df-b9d0-5d836c6f0a14"
  obj.MoveSpeed=0
  if not (obj.i[boot] and obj.i[boot][2]>0) then --if object does not have fire boots
    local fcn=obj.Interactions
    if fcn and fcn[this.guid] then  --if the object has defined interactions with this element
      fcn[this.guid](obj,this)      --then do those
    else
      death.start(obj,"explode",30,"Don't Step In Fire Without Fire Boots!") --default is to destroy the object
    end
  end
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  --glColor3f(h,h,h) --darken with depth
  glCallList(this.glist+(tick/8)%11)
end

this.Load=function(this)
  this.glist=glGenLists(11)
  local h = 1/2048 --offset by 1 pixel to prevent other elements from showing at seams
  this.Resource=LoadTexture(this.path.."graphics/0021_fire.bmp")
  local i
  for i=0,10 do
  glNewList(this.glist+i,GL_COMPILE)  --build fire
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,FLOORLEVEL,i/16+h,0,(1+i)/16-h,1)
  glEndList()
  end
end
