this.Render=function(this,h)
  if this.rule==1 then --key
    glPushMatrix()
    if this.offset then
      glTranslatef((this.fromx-this.x)*this.offset,(this.y-this.fromy)*this.offset,(this.fromz-this.z)*this.offset)
    end
    local c=this.color-7
    if c<0 then c=0 end
    glEnable(GL_BLEND)
    glBlendFunc(GL_DST_COLOR,GL_ZERO)
    glCallList(this.glist+c*2+1) --render the mask
    glBlendFunc(GL_ONE,GL_ONE)
    glColor3f(h,h,h) --darken with depth
    if c==0 then 
      local r,g,b=color(this.colors[this.color])
      glColor3f(r*h,g*h,b*h)
    end
    glCallList(this.glist+c*2) --render the key
    glDisable(GL_BLEND)
    glPopMatrix()
  else
    local r,g,b=color(this.colors[this.color])
    glColor3f(r*h,g*h,b*h)
    glCallList(this.glist+6)
  end
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."keys.bmp")
  -- create the render list
  this.glist=glGenLists(7)
  local g,h=1/512,1/256
  local i,j
  for i=0,2 do
    for j=0,1 do
      glNewList(this.glist+i*2+j,GL_COMPILE)
      glBindTexture(GL_TEXTURE_2D,this.Resource)
      RenderPlaneUV(.5,.5,CENTERLEVEL,i/4+g,(1-j)/2+h,(i+1)/4-g,(2-j)/2-h)
      glEndList()
    end
  end
  glNewList(this.glist+6,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  RenderCubeUV(.5,.5,.5,3/4+g,1/2+h,1-g,1-h)
  glEndList()
end

this.MeasureInventory=function(obj)
  local guid="71c3697c-1348-4f5e-a07f-8ce68d45a351"
  local count=0
  local n
  if obj.i[guid] then
    for n=1,9 do
      if obj.i[guid][n]~=0 then count=count+1 end
    end
  end
  return count
end

this.RenderInventory=function(obj)
  local guid="71c3697c-1348-4f5e-a07f-8ce68d45a351"
  local n
  if obj.i[guid] then
    for n=1,9 do
      local item=library[guid]
      item.rule=1
      item.color=n
      InventoryHelper(item,obj.i[guid][n])
    end
  end
end

