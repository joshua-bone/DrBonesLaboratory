this.Render=function(this,h)
  glPushMatrix()
  if this.offset then
    glTranslatef((this.fromx-this.x)*this.offset,(this.y-this.fromy)*this.offset,(this.fromz-this.z)*this.offset)
  end
  glEnable(GL_BLEND)
  glBlendFunc(GL_DST_COLOR,GL_ZERO)
  glCallList(this.glist+(this.rule-1)*2+1)                     -- render the mask
  glBlendFunc(GL_ONE, GL_ONE)
  glColor3f(h,h,h) --darken with depth
  glCallList(this.glist+(this.rule-1)*2) --render the bo0t
    --glEnable(GL_DEPTH_TEST)
  glDisable(GL_BLEND)
  glPopMatrix()
end

this.Load=function(this,params)
  this.Resource=LoadTexture(this.path.."boot.bmp")   -- load resources
  this.glist=glGenLists(8)
  local g,h=1/512,1/256
  local i,j
  for i=0,3 do
    for j=0,1 do
      glNewList(this.glist+i*2+j,GL_COMPILE)
      glBindTexture(GL_TEXTURE_2D,this.Resource)
      RenderPlaneUV(.5,.5,CENTERLEVEL,i/4+g,(1-j)/2+h,(i+1)/4-g,(2-j)/2-h)
      glEndList()
    end
  end
end

this.MeasureInventory=function(obj)
  local guid="e0159bb2-2559-44df-b9d0-5d836c6f0a14"
  local count=0
  local n
  if obj.i[guid] then
    for n=1,4 do
      if obj.i[guid][n]~=0 then count=count+1 end
    end
  end
  return count
end

this.RenderInventory=function(obj)
  local guid="e0159bb2-2559-44df-b9d0-5d836c6f0a14"
  local n
  if obj.i[guid] then
    for n=1,4 do
      local item=library[guid]
      item.rule=n
      InventoryHelper(item,obj.i[guid][n])
    end
  end
end