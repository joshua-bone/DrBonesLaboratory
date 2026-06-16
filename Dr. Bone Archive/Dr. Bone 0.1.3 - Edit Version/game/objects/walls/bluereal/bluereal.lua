--1 wall
--2 temp inv
--3 perm inv
--4 cracked
--5 popup
--6 blue fake
--7 blue real
--8 green fake
--9 green real

---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="d47bbabe-059b-4201-87c9-c78227ec3193"
this.version="2008/04/20-22:08:00"
this.author="Joshua Bone"
this.name="Real Blue Wall"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------
this.occupies="TBNSEWCF"
this.removes="TBNSEWCF"

this.examples=function(T,F)
  return {T}
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.Write=function(this,T)
  return {T}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter2=function(this,obj,speed,force,newx,newy,newz)
  if obj.a.player then
    local wall="f52413b1-9bf7-463e-9e60-84794fafef1a"
    local newwall=library[wall]
    AddObject(newwall,newx,newy,newz)
    ListRemove(map[newx][newy][newz],this)
  end
  return 0,0
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  glColor3f(h,h,h)
  glCallList(this.glist) 
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."graphics/0018_fakebluewall.bmp")
  this.glist=glGenLists(1)
  glNewList(this.glist,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  RenderCube(.5,.5,.5)
  glEndList()
end