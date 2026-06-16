this.Render=function(this,h)
  glColor3f(h,h,h)
  glCallList(this.glist) 
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."stone.bmp")
  this.glist=glGenLists(1)
  glNewList(this.glist,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  RenderPlaneUV(.5,.5,FLOORLEVEL,0,0,1,1)
  glEndList()
end

