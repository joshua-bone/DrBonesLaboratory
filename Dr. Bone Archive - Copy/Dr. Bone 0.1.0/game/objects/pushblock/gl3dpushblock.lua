this.Render=function(this,h) 
  glPushMatrix()
  glTranslatef((this.fromx-this.x)*this.offset,(this.y-this.fromy)*this.offset,(this.fromz-this.z)*this.offset)
  if this.rule==3 then --glass block
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  end
  glColor4f(h,h,h,1/2)
  glCallList(this.glist+this.rule-1)     
  glDisable(GL_BLEND)  
  glPopMatrix()
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."pushblock.bmp")
  this.glist=glGenLists(3)
  -- create the render list
  local i
  local h = 1/512
  for i=0,2 do
    glNewList(this.glist+i,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderCubeUV(.5,.5,.5,i/4+h,0,(i+1)/4-h,1)
    glEndList()
  end
end

