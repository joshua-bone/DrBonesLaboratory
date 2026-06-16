---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="02ce05f5-1194-4bc6-8ac1-8570a1e3dc69"
this.name="Permanent Invisible Wall"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------
this.occupies="T"
this.removes="T"

this.clone=Clone --[[individual instances since we want the wall to appear temporarily
				     when pressed]]

this.examples=function(T,F)
  return {T}
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.Write=function(this,T)
  return {T}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter2=function(this,obj,speed,force,newx,newy,newz)
  this.lasttick=tick
  return 0,0
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  if gamestate.ID=="Editor" or gamestate.ID=="Parts" then --render in editor
    glColor3f(h,h,h)
    glCallList(this.glist)  
  elseif this.lasttick and (tick-this.lasttick)<20 then --render as wall for a little when pressed
    glColor3f(h,h,h)
	glCallList(this.glist+1) 
	this.lasttick=this.lasttick+1
  else
	this.lasttick=nil
  end
end

this.Load=function(this)
  this.Resource1=LoadTexture(this.path.."graphics/0011_perminvwall.bmp")
  this.Resource2=LoadTexture(this.path.."graphics/0002_wall.bmp") 
  this.glist=glGenLists(2)
  glNewList(this.glist,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource1)
  RenderCube(.5,.5,.5)
  glEndList()
  glNewList(this.glist+1,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource2)
  RenderCube(.5,.5,.5)
  glEndList()
end