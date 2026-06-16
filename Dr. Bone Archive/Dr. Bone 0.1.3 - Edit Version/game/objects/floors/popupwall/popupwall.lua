---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="c3af8665-3553-4d3e-aab3-662d3e608523"
this.name="Pop-Up Wall"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return{T}
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="F"          --occupies floor
this.removes="F"

this.Write=function(this,T)
  return T
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)

  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz)
  if d==1 then return 0,0 end --can't enter from below unless empty space
  if d==-1 then return speed, force end --can always enter from above

  if obj.a.auto then return 0,0 end --monsters can't enter but everything else can
  return speed, force
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------
this.FinishExit=function(this,obj)
  obj.MoveSpeed=0
  local wall="f52413b1-9bf7-463e-9e60-84794fafef1a"
  local newwall=library[wall]
  AddObject(newwall,obj.fromx,obj.fromy,obj.fromz)    --add the wall
  ListRemove(map[obj.fromx][obj.fromy][obj.fromz],this) --remove the popup wall
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  glColor3f(h,h,h)
  glCallList(this.glist)  
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."graphics/0024_popupwall.bmp")
  this.glist=glGenLists(1)
  glNewList(this.glist,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  RenderPlaneUV(.5,.5,FLOORLEVEL,0,0,1,1)
  glEndList()
end