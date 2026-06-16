this.Render=function(this,h)
  glPushMatrix()
  glRotatef(os.time()*24,0,0,1)
  glEnable(GL_BLEND)
  glBlendFunc(GL_DST_COLOR,GL_ZERO)
  glCallList(this.glist+1)                     -- render the mask
  glBlendFunc(GL_ONE, GL_ONE)
  glCallList(this.glist) --render the connector
  glDisable(GL_BLEND)
  glPopMatrix()
end

this.Load=function(this,params)
  this.Resource=LoadTexture(this.path.."connector.bmp")   -- load resources
  this.glist=glGenLists(2)
  local h=1/256
  local j
  for j=0,1 do
    glNewList(this.glist+j,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,0,0,(1-j)/2+h,1,(2-j)/2-h)
    glEndList()
  end
end