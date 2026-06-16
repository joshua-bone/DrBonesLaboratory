this.Render=function(this,h)
  glColor3f(h,h,h) --darken with depth
  glCallList(this.glist+(tick/8)%11)
end

this.Load=function(this)
  this.glist=glGenLists(11)
  local h = 1/2048 --offset by 1 pixel to prevent other elements from showing at seams
  this.Resource=LoadTexture(this.path.."fire.bmp")
  local i
  for i=0,10 do
  glNewList(this.glist+i,GL_COMPILE)  --build fire
    glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(.5,.5,FLOORLEVEL,i/16+h,0,(1+i)/16-h,1)
  glEndList()
  end
end

