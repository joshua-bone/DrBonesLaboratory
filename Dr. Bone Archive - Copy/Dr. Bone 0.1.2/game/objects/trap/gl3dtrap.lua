
this.Render=function(this,h)
  glColor3f(h,h,h)
  glCallList(this.glist+this.rule-1)
end

this.Load=function(this)
  this.glist=glGenLists(3)
  local h = 1/256 --offset by 1 pixel to prevent other elements from showing at seams
  this.Resource=LoadTexture(this.path.."trap.bmp")
  glNewList(this.glist,GL_COMPILE)  --build trap (open)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,-.48,0+h,0,1/4-h,1)
  glEndList()
  glNewList(this.glist+1,GL_COMPILE)  --build trap (shut)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,-.48,1/4+h,0,1/2-h,1)
  glEndList() 
  glNewList(this.glist+2,GL_COMPILE)  --build trap button
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,-.48,1/2+h,0,3/4-h,1)
  glEndList()
end

