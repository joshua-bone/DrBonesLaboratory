this.Render=function(this,h)
  glPushMatrix() 
  RotateObjD(this)
  local current=this:getCurrent(this.rule,this.color)
  local r,g,b=color(this.colors[this.color])
  glColor3f(r*h,g*h,b*h)
  if current<3 then glCallList(this.glist) end
  if current>1 then glCallList(this.glist+1) end
  if this.parent then 
    local d=GetRelativeDirection(this.d,this.parent.d)
    glRotatef(d+180,0,0,1)
    glCallList(this.glist+1)
    glRotatef(-d-180,0,0,1)
  end
  glPopMatrix()
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."laser.bmp")
 	this.glist=glGenLists(2)
	
  glNewList(this.glist,GL_COMPILE)
	glBindTexture(GL_TEXTURE_2D,this.Resource)	
	local theta,x1,x2,z1,z2
  local SIZE=.18
	for theta=22.5,337.5,45 do
     
	  x1=math.sin(math.rad(theta))*SIZE
    x2=math.sin(math.rad(theta+45))*SIZE
  	z1=math.cos(math.rad(theta))*SIZE
	  z2=math.cos(math.rad(theta+45))*SIZE

	  glBegin(GL_QUADS)
	  
          local denom=math.sqrt((x2-x1)^2+(z1-z2)^2)
	  glNormal3f((z1-z2)/denom,0,(x2-x1)/denom)
   	  z1,z2=z1-.3,z2-.3
	  glTexCoord2f(9/16,0) glVertex3f(x1,-.1,z1)
	  glTexCoord2f(9/16,1) glVertex3f(x1,.4,z1)
	  glTexCoord2f(1,1) glVertex3f(x2,.4,z2)
	  glTexCoord2f(1,0) glVertex3f(x2,-.1,z2)
         
	  x1,x2,z1,z2=x1*2,x2*2,(z1+.3)*2,(z2+.3)*2
	  glNormal3f((z1-z2)/denom,(x2-x1)/denom,0)
	  glTexCoord2f(9/16,0) glVertex3f(x1,z1,-.5)
	  glTexCoord2f(9/16,1) glVertex3f(x1,z1,0)
	  glTexCoord2f(1,1) glVertex3f(x2,z2,0)
	  glTexCoord2f(1,0) glVertex3f(x2,z2,-.5)
          glEnd()


	  glBegin(GL_TRIANGLES)
          glNormal3f(0,0,1)
	  glTexCoord2f(3/4,1) glVertex3f(x1,z1,0)
	  glTexCoord2f(1,9/16) glVertex3f(x2,z2,0)
	  glTexCoord2f(9/16,0) glVertex3f(0,0,0)
	  glEnd()


        end	
    	glEndList()

	glNewList(this.glist+1,GL_COMPILE)
	glBindTexture(GL_TEXTURE_2D,this.Resource)
	glBegin(GL_QUADS)
	glNormal3f(0,0,1)
	glTexCoord2f(0,0) glVertex3f(-.05,0,-.3)
	glTexCoord2f(0,1) glVertex3f(-.05,.5,-.3)
	glTexCoord2f(.5,1) glVertex3f(.05,.5,-.3)
	glTexCoord2f(.5,0) glVertex3f(.05,0,-.3)
	glEnd()
	glEndList()

	
end

