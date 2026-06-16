this.Render= function (this,h)	
  glPushMatrix()             -- save the matrix because we are going to modify it
  glColor3f(h,h,h)
  glCallList(this.glist)
  glRotatef(tick*10,0,0,1)
  glCallList(this.glist+1)
  glPopMatrix()                             -- restore the matrix
end

this.Load=function(this)  

  this.Resource=LoadTexture(this.path.."teleport.bmp")
  local h = 1/128 --offset by 1 pixel to prevent other elements from showing at seams
  
  this.glist=glGenLists(2)
  
  glNewList(this.glist,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(0.5,0.5,-0.48,0+h,0,1/2-h,1)
  glEndList()
  
  glNewList(this.glist+1,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
  	glBegin(GL_TRIANGLES)
  	local x,y
  	for theta=0,359 do
  	  x1=math.cos(math.rad(theta))*.5
  	  x2=math.cos(math.rad(theta+1))*.5
  	  y1=math.sin(math.rad(theta))*.5
  	  y2=math.sin(math.rad(theta+1))*.5
  	  glTexCoord2f((x1+.5)*.5+.5,y1+.5) glVertex3f(x1,y1,-.48)
  	  glTexCoord2f((x2+.5)*.5+.5,y2+.5) glVertex3f(x2,y2,-.48)
  	  glTexCoord2f(3/4,1/2) glVertex3f(0,0,-.48)
    end
  	glEnd()
  glEndList()      
end


