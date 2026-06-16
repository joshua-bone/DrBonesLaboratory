---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="12423c7a-00c4-4c73-a032-0c5227feee11"
this.name="Thin Wall West"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  --{{this, this.d}}      
  return{{T,F}}
end  

--rotate direction in editor
--this.EditorRotate=EditorRotate

--[[this.occupies & this.removes change when rotated
this.EditorInit=function(this)
  this.occupies=dirs[this.d]
  this.removes=this.occupies
end]]

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------
this.occupies="W"
this.removes="W"

this.Write=function(this,T)
    return T
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestExit=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz) --get true traveling direction of object
  if d==dirs["W"] then
    return 0, 0 --cannot exit if going west
  else
    return speed,force
  end
end

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz) --get true traveling direction of object
  if d==dirs["E"] then 
    return 0, 0 --cannot enter if going east
  else
    return speed,force
  end
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  glColor3f(h,h,h) --darken with depth
  glPushMatrix()
  
  --quick and dirty workaround to avoid drawing new graphics for each rotation
  --just use the same code as for the thinwall north and rotate by direction.
  this.d=dirs["W"]
  RotateObjD(this)
  this.d=nil
  
  glCallList(this.glist)
  glPopMatrix() 
end

this.Load=function(this)
    this.Resource=LoadTexture(this.path.."graphics/0007_thinwall.bmp")
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






