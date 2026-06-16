this.Render= function(this,h)
  glColor3f(h,h,h)
  glCallList(this.glist+(tick/2)%8)
end

this.Load=function(this)
    this.Resource=LoadTexture(this.path.."goal.bmp")
    this.glist=glGenLists(8)
    local j
    for j = 0,7 do
      glNewList(this.glist+j,GL_COMPILE)
        glBindTexture(GL_TEXTURE_2D,this.Resource)
        RenderPlaneUV(.4,.4,-.48,0,(7-j)/8,1,(8-j)/8)
      glEndList()
    end
end


