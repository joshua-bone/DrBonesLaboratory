this.Render=function(this,h)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR)
  glColor3f(h,h,h) --darken with depth
  glCallList(this.glist) --render the grating
  glDisable(GL_BLEND) 
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."glass.bmp")
  this.glist=glGenLists(1)
  glNewList(this.glist,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  RenderPlaneUV(.5,.5,FLOORLEVEL,0,0,1,1)
  glEndList()
end

