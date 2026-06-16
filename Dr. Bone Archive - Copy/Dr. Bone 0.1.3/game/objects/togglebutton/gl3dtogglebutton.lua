--colors: 1 red   2 green    3 yellow   4 blue    5 magenta    6 cyan     7 orange  8 brown

this.Render=function(this,h)
  local r,g,b=color(this.colors[this.color])
  glColor3f(r*h,g*h,b*h)
  glPushMatrix()
  glRotatef(tick,0,0,-1)
  glCallList(this.glist)
  glPopMatrix()
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."togglebutton.bmp")
  this.glist=glGenLists(1)
  glNewList(this.glist,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  RenderCube(1/8,1/8,1/8)
  glEndList()
end



