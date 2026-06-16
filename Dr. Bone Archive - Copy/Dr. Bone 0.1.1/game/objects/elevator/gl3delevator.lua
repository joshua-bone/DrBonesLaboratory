this.Render=function (this,h)
  local r,g,b=color(this.colors[this.color])
  glColor3f(r*h,g*h,b*h)
  local rule=this.rule
  glPushMatrix()
  if this.color==9 and this.rule==2 and this.a.moving then
    local m = this.a.moving-32
    glTranslatef(0,0,-math.abs(m/32))
  end
  
  if this.color<9 and this.a.moving and this.a.moving~=0 then
    local m = this.a.moving
    if rule==1 then --traveling downward
      rule=2 --make it look like a solid wall while it moves
      glTranslatef(0,0,-1+m/32)
    else
      glTranslatef(0,0,-m/32)
    end 
  end
  glCallList(this.glist+rule-1)
  glPopMatrix()
end

this.Load=function(this)
  local h = 1/128 --horiz. offset by 1 pixel to prevent other elements from showing at seams
  this.Resource=LoadTexture(this.path.."elevator.bmp")
  this.glist=glGenLists(2)
  
  glNewList(this.glist+1,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  RenderCubeUV(.5,.5,.5,h,0,1/2-h,1)
  glEndList()

  glNewList(this.glist,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  RenderPlaneUV(.5,.5,-.49,1/2+h,0,1-h,1)
  glEndList()
end



