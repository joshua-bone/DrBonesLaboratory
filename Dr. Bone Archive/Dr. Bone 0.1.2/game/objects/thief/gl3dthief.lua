
this.Render=function(this,h)
  glColor3f(h,h,h)
  glCallList(this.glist+this.rule-1)                     -- render the player
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."thief.bmp")
  -- create the render list
  this.glist=glGenLists(2)
  for i=0,.5,.5 do
    glNewList(this.glist+(i*2),GL_COMPILE)
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(0.5,0.5,-0.48,0,0+i,1,65/128+i)
    glEndList();
  end
end

