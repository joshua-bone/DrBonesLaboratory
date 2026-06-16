---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="f52413b1-9bf7-463e-9e60-84794fafef1a"
this.name="Wall"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return {T}   --in the item select screen, returns just this
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------
this.occupies="TBNSEWCF"  --occupies everything
this.removes=this.occupies  --removes everything

this.Write=function(this,T)
  return T
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj)
  return 0,0     --nothing can enter
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  glColor3f(h,h,h)
  glCallList(this.glist)
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."graphics/0002_wall.bmp") 
  this.glist=glGenLists(1)
  glNewList(this.glist,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  RenderCube(.5,.5,.5)
  glEndList()
end




