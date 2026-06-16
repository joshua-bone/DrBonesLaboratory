this.Render=function(this,h)
  glPushMatrix()  -- save the matrix because we are going to modify it
  glTranslatef((this.fromx-this.x)*this.offset,(this.y-this.fromy)*this.offset,(this.fromz-this.z)*this.offset)  -- offset from middle of square

  local frame = 0
  if event~=0 or this.offset~=0 then frame=math.floor(1+(tick/4)%8) end
  if this.a.floatingIn then 
    glTranslatef(0,-1/4,-1/10)
    glRotatef(15,1,0,0) 
  end

  glEnable(GL_BLEND)
  glBlendFunc(GL_DST_COLOR,GL_ZERO)  
	glCallList(this.glist+(this.d/90)+frame*8+4)                     -- render the mask  
  glBlendFunc(GL_ONE, GL_ONE) 
  glColor3f(h,h,h)  
  glCallList(this.glist+(this.d/90)+frame*8)  
  glDisable(GL_BLEND)
  glPopMatrix()                             -- restore the matrix
end

this.Load=function(this,params)
  this.Resource=LoadTexture(this.path.."player.bmp")   -- load resources
  this.glist=glGenLists(72)    -- create the render list
  local g,h=28/2048,28/1024
  local i, j
  for i=0,8 do
    for j=0,7 do
      glNewList(this.glist+i*8+j,GL_COMPILE)
      glBindTexture(GL_TEXTURE_2D,this.Resource) 
      RenderPlaneUV(.5,.5,TOPLEVEL,i/16+g,(7-j)/8+h,(i+1)/16-g,(8-j)/8-h)   
      glEndList()
    end
  end
end


