this.name="Wall"

---------------------------------------------------------------------------------------------------
--GRAPHICS
---------------------------------------------------------------------------------------------------
this.Render=function(this,h)
  glColor3f(h,h,h)  --shade with depth
  glCallList(this.glist)
end

this.Load=function(this)
  this.Resource=LoadTexture("data/objects/bmp/wall.bmp") 
  this.glist=glGenLists(1)
  glNewList(this.glist,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  grL.RenderPlaneUV(.5,.5,FLOORLEVEL,0,0,1,1)
  glEndList()
end

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return {T}
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------
this.occupies="TBNSEWCF"
this.removes=this.occupies

this.Write=function(this,T)
  return T
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj)
  return 0,0
end





