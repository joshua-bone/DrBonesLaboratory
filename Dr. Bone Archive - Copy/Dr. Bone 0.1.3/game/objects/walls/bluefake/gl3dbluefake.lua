this.Render=function(this,h)
  glColor3f(h,h,h)
  if gamestate~=PlayLevel then
    glCallList(this.glist)
  else
    glCallList(this.glist+1)  
  end
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."blue.bmp")
  this.glist=glGenLists(2)
  glNewList(this.glist,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,FLOORLEVEL,0,0,1,1)
  glEndList()
  glNewList(this.glist+1,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderCube(.5,.5,.5)
  glEndList()
end