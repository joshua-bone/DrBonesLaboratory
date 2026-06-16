this.Render=function(this,h)
  glColor3f(h,h,h) --darken with depth
  if this.rule==1 then
    glCallList(this.glist)
  else --ice corner
    glPushMatrix() --save the matrix because we are going to modify it
    glCallList(this.glist) --call ice floor first,
    RotateObjD(this)       --rotate according to this.d
    glCallList(this.glist+1) --then call ice corner
    glPopMatrix() --restore the matrix
  end
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."ice.bmp")
  this.glist=glGenLists(2)
  local g=1/256
  
  glNewList(this.glist,GL_COMPILE)			--ice floor
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,FLOORLEVEL,0+g,0,1/2-g,1)
  glEndList()

  glNewList(this.glist+1,GL_COMPILE)
  	glBindTexture(GL_TEXTURE_2D,this.Resource)
    glBegin(GL_QUADS)
      --West Face
    	glNormal3f(-1,0,0)
      glTexCoord2f(1/2+g,0) glVertex3f(-.5,-.4,-.5)
      glTexCoord2f(1/2+g,1) glVertex3f(-.5,-.4,.5)
    	glTexCoord2f(1-g,1) glVertex3f(-.5,.5,.5)
    	glTexCoord2f(1-g,0) glVertex3f(-.5,.5,-.5)
    	--North Face
    	glNormal3f(0,1,0)
      glTexCoord2f(1/2+g,0) glVertex3f(-.5,.5,-.5)
      glTexCoord2f(1/2+g,1) glVertex3f(-.5,.5,.5)
    	glTexCoord2f(1-g,1) glVertex3f( .4,.5,.5)
    	glTexCoord2f(1-g,0) glVertex3f( .4,.5,-.5)
      
      --Curve
      local theta,x1,x2,y1,y2
      for theta=90,170 do
    	  x1=math.cos(math.rad(theta))*.9
    	  x2=math.cos(math.rad(theta+10))*.9
    	  y1=math.sin(math.rad(theta))*.9
    	  y2=math.sin(math.rad(theta+10))*.9

        local denom=math.sqrt((x2-x1)^2+(y1-y2)^2)
    	  glNormal3f((y1-y2)/denom,(x2-x1)/denom,0)
        glTexCoord2f(theta/180+g,0) glVertex3f(x1+.4,y1-.4,-.5)
        glTexCoord2f(theta/180+g,1) glVertex3f(x1+.4,y1-.4,.5)
    	  glTexCoord2f((theta+10)/180-g,1) glVertex3f(x2+.4,y2-.4,.5)
    	  glTexCoord2f((theta+10)/180-g,0) glVertex3f(x2+.4,y2-.4,-.5)
        
        --Top Face
    	  glNormal3f(0,0,1)	
        glTexCoord2f((x1+.9)*10/36+1/2+g,y2*10/12) glVertex3f(x1+.4,y1-.4,.5)
        glTexCoord2f((x1+.9)*10/36+1/2+g,3/4) glVertex3f(x1+.4,.5,.5)
    	  glTexCoord2f((x2+.9)*10/36+1/2+g,3/4) glVertex3f(x2+.4,.5,.5)
    	  glTexCoord2f((x2+.9)*10/36+1/2+g,y1*10/12) glVertex3f(x2+.4,y2-.4,.5)
      end
    glEnd()
  glEndList()
end