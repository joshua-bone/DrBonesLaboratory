this.Render=function(this,h)
  if not this.connection then h=h/2 end --darken if not connected
  if this.rule==2 then --clone button
    glEnable(GL_BLEND)
    glBlendFunc(GL_DST_COLOR,GL_ZERO)
    glCallList(this.glist)                     -- render the mask
    glBlendFunc(GL_ONE, GL_ONE)
    glColor3f(h,h,h) --darken with depth
    glCallList(this.glist+1) --render the button
    glDisable(GL_BLEND)
  else
    glColor3f(h,h,h) --darken with depth
    glCallList(this.glist+2)
  end
end

this.Load=function(this)
  this.glist=glGenLists(3)
  local h = 1/256 --offset by 1 pixel to prevent other elements from showing at seams
  this.Resource=LoadTexture(this.path.."clone.bmp")
  glNewList(this.glist,GL_COMPILE)  --build mask
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,-.48,0+h,0+h,1/2-h,1/2-h)
  glEndList() 
  glNewList(this.glist+1,GL_COMPILE)  --build button
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,-.48,0+h,1/2+h,1/2-h,1-h)
  glEndList() 
  glNewList(this.glist+2,GL_COMPILE)  --build machine
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,-.48,1/2+h,1/2+h,1-h,1-h)
  glEndList()
end

