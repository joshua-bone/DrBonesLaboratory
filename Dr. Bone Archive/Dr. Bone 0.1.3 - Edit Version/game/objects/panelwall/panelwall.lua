---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="1eade089-0099-4001-9966-716f053e0bd2"
this.version="2008/05/13-09:07:00"
this.name="Panel Wall"
this.author="Joshua Bone"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  --{{this, this.d}}      
  return{{{T,0},F}}
end  

--rotate direction in editor
this.EditorRotate=EditorRotate

--this.occupies & this.removes change when rotated
this.EditorInit=function(this)
  this.occupies=dirs[this.d]
  this.removes=this.occupies
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.clone=Clone       -- allow individual instances

this.Read=function(this,params)
  this.d=params[2]
  this.EditorInit(this) --get this.removes & this.occupies
end

this.Write=function(this,T)
    return {T,this.d}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestExit=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz) --get true traveling direction of object
  if math.abs(d)==1 then 
    return speed, force --allow if object is traveling vertically
  else
    d=GetRelativeDirection(this.d,d)  --get direction relative to this rotation
    if d==0 then return 0,0 end   --can't exit if not allowed
    return speed,force
  end
end

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz) --get true traveling direction of object
  if math.abs(d)==1 then 
    return speed, force --allow if object is traveling vertically
  else
    d=GetRelativeDirection(this.d,d)            --get direction relative to this rotation
    if d==180 then return 0,0 end   --can't enter if not allowed
    return speed,force
  end
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

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






