this.Render=function(this,h)
  glEnable(GL_BLEND)
  glBlendFunc(GL_DST_COLOR,GL_ZERO)
  glCallList(this.glist+1)                     -- render the mask
  glBlendFunc(GL_ONE, GL_ONE)
  glColor3f(h,h,h) --darken with depth
  glCallList(this.glist) --render the grating
  glDisable(GL_BLEND) 
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."grating.bmp")
  this.glist=glGenLists(2)
  local j
  local h=1/256
  for j=0,1 do
    glNewList(this.glist+j,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,FLOORLEVEL,0,(j+1)/2+h,1,(2+j)/2-h)
    glEndList()
  end
end

