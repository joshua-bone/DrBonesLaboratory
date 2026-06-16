this.Render=function(this,h)
  glPushMatrix()
  if this.offset then
    glTranslatef((this.fromx-this.x)*this.offset,(this.y-this.fromy)*this.offset,(this.fromz-this.z)*this.offset)
  end
  local rule=(this.rule-1)*2
  if rule==0 then
    glEnable(GL_BLEND)
    glBlendFunc(GL_DST_COLOR,GL_ZERO)
    glCallList(this.glist+rule*2+1) --render the mask
    glBlendFunc(GL_ONE,GL_ONE)
  else
    if (Globals[this.guid] and Globals[this.guid]~=0) then h=h/2 end --darker when there are floppy disks remaining
  end
  glColor3f(h,h,h) --darken with depth
	glCallList(this.glist+rule)                     -- render the player
  glDisable(GL_BLEND)
  glPopMatrix()
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."floppydisk.bmp")
  -- create the render list
  this.glist=glGenLists(3)
  local h=1/256
  local j
  for j=0,1 do
    glNewList(this.glist+j,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.4,.4,CENTERLEVEL,0+h,(1-j)/2+h,1/2-h,(2-j)/2-h)
    glEndList()
  end
  glNewList(this.glist+2,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  RenderCubeUV(.5,.5,.5,1/2+h,1/2+h,1-h,1-h)
  glEndList()
end
