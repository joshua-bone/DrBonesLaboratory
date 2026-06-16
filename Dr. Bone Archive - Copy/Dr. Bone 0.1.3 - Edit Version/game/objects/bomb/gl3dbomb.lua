this.Render=function(this,h)
  glEnable(GL_BLEND)
  glBlendFunc(GL_DST_COLOR,GL_ZERO)
  glCallList(this.glist)                     -- render the mask
  glBlendFunc(GL_ONE, GL_ONE)
  glColor3f(h,h,h) --darken with depth
  glCallList(this.glist+1) --render the bomb
  glDisable(GL_BLEND)
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."bomb.bmp")
  this.glist=glGenLists(2)
  local h=1/256
  glNewList(this.glist,GL_COMPILE)
	  glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(0.5,0.5,CENTERLEVEL,0,0+h,1,1/2-h) --mask
  glEndList()
  glNewList(this.glist+1,GL_COMPILE)
	  glBindTexture(GL_TEXTURE_2D,this.Resource)
    RenderPlaneUV(0.5,0.5,CENTERLEVEL,0,1/2+h,1,1-h) --bomb
  glEndList()
end

