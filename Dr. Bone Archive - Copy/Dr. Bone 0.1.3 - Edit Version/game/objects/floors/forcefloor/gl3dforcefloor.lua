this.Render=function(this,h)
  local current=this:getCurrent(this.rule,this.color)
  local r,g,b=color(this.colors[this.color])
  if current<3 then
    glColor3f(r*h,g*h,b*h)
    local thistick=tick
    --if current==1 and gamestate~=PlayLevel then thistick=os.time()*24
    if current==2 then thistick=0 end --force floor OFF
    glPushMatrix()
    RotateObjD(this)
    glCallList(this.glist+(thistick)%16)
    glPopMatrix()
  else --random force floor
    glColor3f(r*h,g*h,b*h)
    local thistick=tick
    --if current==3 and gamestate~=PlayLevel then thistick=os.time()*7
    if current==4 then thistick=0 end --force floor OFF
    glPushMatrix()
    glScalef(.5,.5,1)
    glTranslatef(-1/2,1/2,0)
    glCallList(this.glist+(thistick)%16)
    glTranslatef(1,0,0)
    glRotatef(-90,0,0,1)
    glCallList(this.glist+(thistick)%16)
    glTranslatef(1,0,0)
    glRotatef(-90,0,0,1)
    glCallList(this.glist+(thistick)%16)
    glTranslatef(1,0,0)
    glRotatef(-90,0,0,1)
    glCallList(this.glist+(thistick)%16)
    glPopMatrix()
  end
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."forcefloor.bmp")
  this.glist=glGenLists(16) --16 frames
  for i=0,15 do
    glNewList(this.glist+i,GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(0.5,0.5,FLOORLEVEL,0,(16-i)/16,1,(16-i)/16+1)
    glEndList()
  end  
end

