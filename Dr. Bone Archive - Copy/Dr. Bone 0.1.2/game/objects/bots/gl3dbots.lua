this.Render=function(this,h)
  glPushMatrix()                            -- save the matrix because we are going to modify it
  glTranslatef((this.fromx-this.x)*this.offset,(this.y-this.fromy)*this.offset,(this.fromz-this.z)*this.offset)  -- offset from middle of square
  RotateObjD(this)
  
  glEnable(GL_BLEND)
  --glDisable(GL_DEPTH_TEST)
  glBlendFunc(GL_DST_COLOR,GL_ZERO)
  glCallList(this.glist+(this.rule-1)*2+1)                     -- render the mask
  glBlendFunc(GL_ONE, GL_ONE)
  
  glColor3f(h,h,h) --darken with depth
  glCallList(this.glist+(this.rule-1)*2) --render the bot
    --glEnable(GL_DEPTH_TEST)
  glDisable(GL_BLEND)
  glPopMatrix()                             -- restore the matrix
end

this.Load=function(this,params)
  this.Resource=LoadTexture(this.path.."bots.bmp")   -- load resources
  this.glist=glGenLists(18)
  local g,h=1/2048,1/256
  local i,j
  for i=0,8 do
    for j=0,1 do
      glNewList(this.glist+i*2+j,GL_COMPILE)
      glBindTexture(GL_TEXTURE_2D,this.Resource)
      RenderPlaneUV(.5,.5,TOPLEVEL,i/16+g,(1-j)/2+h,(i+1)/16-g,(2-j)/2-h)
      glEndList()
    end
  end
end
