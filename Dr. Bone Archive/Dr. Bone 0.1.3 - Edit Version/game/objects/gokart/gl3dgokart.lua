this.Render=function(this,h)
  glPushMatrix()
  glTranslatef((this.fromx-this.x)*this.offset,(this.y-this.fromy)*this.offset,(this.fromz-this.z)*this.offset)  -- offset from middle of square
  RotateObjD(this)
  glEnable(GL_BLEND)
  glBlendFunc(GL_DST_COLOR,GL_ZERO)
  glCallList(this.glist+2) --render the mask
  glBlendFunc(GL_ONE, GL_ONE)
  glColor3f(h,h,h)
  glCallList(this.glist) --render the gokart
  local r,g,b=color(this.colors[this.color])
  glColor3f(h*r,h*g,h*b)
  glCallList(this.glist+1)
  glDisable(GL_BLEND)
  glPopMatrix()
end

this.Load=function(this)
  this.glist=glGenLists(3)
  this.Resource=LoadTexture(this.path.."gokart.bmp")
  local h=1/256
  local j
  for j=0,1 do
    glNewList(this.glist+j,GL_COMPILE)  --build gokart
      glBindTexture(GL_TEXTURE_2D,this.Resource)
      RenderPlaneUV(.5,.5,-.4,h,j/2+h,1/2-h,(1+j)/2-h)
    glEndList()
  end
  glNewList(this.glist+2,GL_COMPILE)  --build mask
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,-.4,1/2+h,1/2+h,1-h,1-h)
  glEndList()
end

