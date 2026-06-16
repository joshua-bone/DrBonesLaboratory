
this.Render=function(this,h)
  glPushMatrix()
  glTranslatef((this.fromx-this.x)*this.offset,(this.y-this.fromy)*this.offset,0)
  RotateObjD(this)
  glColor3f(h,h,h)  --darken with depth
  glCallList(this.glist+this.rule)                     -- render the player
  glPopMatrix()
end

this.Load=function(this)
  this.Resource1=LoadTexture(this.path.."lasermirror.bmp")
  this.Resource2=LoadTexture(this.path.."lasermirror2.bmp")
  -- create the render list
  this.glist=glGenLists(2)
  glNewList(this.glist+1,GL_COMPILE)
	glBindTexture(GL_TEXTURE_2D,this.Resource1)
	RenderPlaneUV(.5,.5,TOPLEVEL,0,0,1,1)
        glBindTexture(GL_TEXTURE_2D,this.Resource2)
        glBegin(GL_QUADS)
        glTexCoord2f(0,0) glVertex3f(-.5,-.5,-.5)
        glTexCoord2f(0,1) glVertex3f(-.5,-.5,.5)
	glTexCoord2f(.5,1) glVertex3f( .5,.5,.5)
	glTexCoord2f(.5,0) glVertex3f( .5,.5,-.5)
        glEnd()
  glEndList()
  glNewList(this.glist+2,GL_COMPILE)
	glBindTexture(GL_TEXTURE_2D,this.Resource1)
	RenderPlaneUV(.5,.5,TOPLEVEL,0,0,1,1)
        glBindTexture(GL_TEXTURE_2D,this.Resource2)

        glBegin(GL_QUADS)
        glTexCoord2f(0,0) glVertex3f(-.5,-.5,-.5)
        glTexCoord2f(0,1) glVertex3f(-.5,-.5,.5)
	glTexCoord2f(.5,1) glVertex3f(.5,.5,.5)
	glTexCoord2f(.5,0) glVertex3f(.5,.5,-.5)

	glNormal3f(-1,0,0)
        glTexCoord2f(.5,0) glVertex3f(-.5,-.5,-.5)
        glTexCoord2f(.5,1) glVertex3f(-.5,-.5,.5)
	glTexCoord2f(1,1) glVertex3f(-.5,.5,.5)
	glTexCoord2f(1,0) glVertex3f(-.5,.5,-.5)

	glNormal3f(0,1,0)
        glTexCoord2f(.5,0) glVertex3f(-.5,.5,-.5)
        glTexCoord2f(.5,1) glVertex3f(-.5,.5,.5)
	glTexCoord2f(1,1) glVertex3f( .5,.5,.5)
	glTexCoord2f(1,0) glVertex3f( .5,.5,-.5)

	glNormal3f(0,0,1)
        glTexCoord2f(.5,0) glVertex3f(-.5,-.5,.5)
        glTexCoord2f(.5,1) glVertex3f(-.5,.5,.5)
	glTexCoord2f(1,1) glVertex3f( .5,.5,.5)
	glTexCoord2f(1,0) glVertex3f( 0,0,.5)
  	
        glEnd()

  glEndList()
end

