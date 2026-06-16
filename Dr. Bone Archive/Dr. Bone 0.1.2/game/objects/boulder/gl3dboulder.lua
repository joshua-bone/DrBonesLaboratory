this.Render=function(this,h) 
  glColor3f(h,h,h) --darken with depth
  glPushMatrix()
  glTranslatef((this.fromx-this.x)*this.offset,(this.y-this.fromy)*this.offset,(this.fromz-this.z)*this.offset)
  if this.fromz==this.z then
    local axes={{-1,0},{0,-1},{1,0},{0,1}}
    local axis=axes[this.d/90+1]
    glRotatef((-this.offset)*90,axis[1],axis[2],0)
  end
  glRotatef(-this.thetay,0,1,0) glRotatef(this.thetaz,0,0,1) glRotatef(-this.thetax,1,0,0) 
  glCallList(this.glist)            
  glPopMatrix()
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."boulder.bmp")
  local DEG=45
  local SIZE=1/2
  this.glist=glGenLists(1)
  -- create the render list
  glNewList(this.glist,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    glBegin(GL_QUADS)
    local theta,phi,x11,x12,x21,x22,y11,y12,y21,y22,z1,z2,i,j,k
    for theta=0,360-DEG,DEG do
      for phi=0,180-DEG,DEG do
        x11=math.cos(math.rad(theta))*math.sin(math.rad(phi))*SIZE
        x12=math.cos(math.rad(theta))*math.sin(math.rad(phi+DEG))*SIZE
        x21=math.cos(math.rad(theta+DEG))*math.sin(math.rad(phi))*SIZE
        x22=math.cos(math.rad(theta+DEG))*math.sin(math.rad(phi+DEG))*SIZE
        y11=math.sin(math.rad(theta))*math.sin(math.rad(phi))*SIZE
        y12=math.sin(math.rad(theta))*math.sin(math.rad(phi+DEG))*SIZE
        y21=math.sin(math.rad(theta+DEG))*math.sin(math.rad(phi))*SIZE
        y22=math.sin(math.rad(theta+DEG))*math.sin(math.rad(phi+DEG))*SIZE
        z1=math.cos(math.rad(phi))*SIZE
        z2=math.cos(math.rad(phi+DEG))*SIZE
        local denom=math.sqrt((x22-x11)^2+(y22-y11)^2+(z2-z1)^2)
        i=(y11-y21)*(z2-z1)/denom
        j=(x21-x11)*(z2-z1)/denom
        k=((x11-x21)*(y12-y11)-(y11-y21)*(x12-x11))/denom
        glNormal3f(i,j,k)
        glTexCoord2f(0,0) glVertex3f(x11,y11,z1)
        glTexCoord2f(0,1) glVertex3f(x12,y12,z2)
        glTexCoord2f(1,1) glVertex3f(x22,y22,z2)      
        glTexCoord2f(1,0) glVertex3f(x21,y21,z1)  
      end
    end
    glEnd()
  glEndList()
end

