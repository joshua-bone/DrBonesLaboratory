
this.Render=function(this,h)
  glColor3f(h,h,h) --darken with depth
  glPushMatrix()
  RotateObjD(this)
  glCallList(this.glist)
  glPopMatrix() 
end

this.Load=function(this)
    this.Resource=LoadTexture(this.path.."panelwall.bmp")
    this.glist=glGenLists(1)
    local u1=0
    local u2=1
    local v1=0
    local v2=1
    glNewList(this.glist,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    glBegin(GL_QUADS)
    --North Face
    glNormal3f(0,1,0)
    glTexCoord2f(u1,v1) glVertex3f(-1/2,1/2,-1/2)
    glTexCoord2f(u1,v2) glVertex3f(-1/2,1/2,1/2)
    glTexCoord2f(u2,v2) glVertex3f(1/2,1/2,1/2)
    glTexCoord2f(u2,v1) glVertex3f(1/2,1/2,-1/2)
    --South Face
    glNormal3f(0,-1,0)
    glTexCoord2f(u1,v1) glVertex3f(-1/2,3/8,-1/2)
    glTexCoord2f(u1,v2) glVertex3f(-1/2,3/8,1/2)
    glTexCoord2f(u2,v2) glVertex3f(1/2,3/8,1/2)
    glTexCoord2f(u2,v1) glVertex3f(1/2,3/8,-1/2)
    --Top Face
    glNormal3f(0,0,1)
    glTexCoord2f(u1,v1) glVertex3f(-1/2,1/2,1/2)
    glTexCoord2f(u1,v2) glVertex3f(1/2,1/2,1/2)
    glTexCoord2f(u2/8,v2) glVertex3f(1/2,3/8,1/2)
    glTexCoord2f(u2/8,v1) glVertex3f(-1/2,3/8,1/2)
    --East Face
    glNormal3f(1,0,0)
    glTexCoord2f(u1,v1) glVertex3f(1/2,3/8,-1/2)
    glTexCoord2f(u1,v2) glVertex3f(1/2,3/8,1/2)
    glTexCoord2f(u2/8,v2) glVertex3f(1/2,1/2,1/2)
    glTexCoord2f(u2/8,v1) glVertex3f(1/2,1/2,-1/2)
    --West Face
    glNormal3f(-1,0,0)
    glTexCoord2f(u1,v1) glVertex3f(-1/2,1/2,-1/2)
    glTexCoord2f(u1,v2) glVertex3f(-1/2,1/2,1/2)
    glTexCoord2f(u2/8,v2) glVertex3f(-1/2,3/8,1/2)
    glTexCoord2f(u2/8,v1) glVertex3f(-1/2,3/8,-1/2)
    glEnd()
    glEndList();
end




