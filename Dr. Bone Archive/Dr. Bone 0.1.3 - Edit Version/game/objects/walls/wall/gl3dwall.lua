this.Render=function(this,h)
  glColor3f(h,h,h)
  glCallList(this.glist)
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."graphics/0000_wall.bmp") 
  this.glist=glGenLists(1)
  glNewList(this.glist,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  RenderCube(.5,.5,.5)
	glEndList()
end

