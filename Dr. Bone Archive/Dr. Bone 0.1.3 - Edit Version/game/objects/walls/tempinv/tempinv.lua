---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="81ea3327-22ae-45ff-91a6-3f6fd83c7502"
this.name="Temporary Invisible Wall"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------
this.occupies="TBNSEWC"
this.removes="TBNSEWC"

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
  local wall="f52413b1-9bf7-463e-9e60-84794fafef1a"
  local newwall=library[wall]
  AddObject(newwall,newx,newy,newz)    --add the wall
  ListRemove(map[newx][newy][newz],this) --remove the popup wall
  return 0,0
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  if not ClipMap then
    glColor3f(h,h,h)
    glCallList(this.glist)  
  end
end

this.Load=function(this)
  this.Resource=LoadTexture(this.path.."tempinv.bmp")
  this.glist=glGenLists(1)
  glNewList(this.glist,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  RenderCube(.5,.5,.5)
  glEndList()
end