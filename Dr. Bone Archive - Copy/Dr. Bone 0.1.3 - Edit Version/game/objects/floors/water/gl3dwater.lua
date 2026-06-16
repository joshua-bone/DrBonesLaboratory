this.Render=function(this,h)
  glColor3f(h,h,h) --darken with depth
  glCallList(this.glist+(math.floor(tick/6)%11))
end

this.Load=function(this)
  this.glist=glGenLists(11)
  local h = 1/1024 --offset by 1 pixel to prevent other elements from showing at seams
  this.Resource=LoadTexture(this.path.."water.bmp")
  for i=0,10 do
      glNewList(this.glist+i,GL_COMPILE)  --build water
      glBindTexture(GL_TEXTURE_2D,this.Resource)
      RenderPlaneUV(.5,.5,FLOORLEVEL,i/16,0,(i+1)/16,1)
      glEndList()
  end
end

