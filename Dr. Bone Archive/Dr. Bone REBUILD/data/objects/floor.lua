this.name="Floor"

---------------------------------------------------------------------------------------------------
--GRAPHICS
---------------------------------------------------------------------------------------------------
this.Render=function(this,h)
  glColor3f(h,h,h) --shade with depth
  glColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE)
  glCallList(this.glist)  
end

this.Load=function(this)
  this.Resource=LoadTexture("data/objects/bmp/floor.bmp")
  this.glist=glGenLists(1)
  glNewList(this.glist,GL_COMPILE)
  glBindTexture(GL_TEXTURE_2D,this.Resource)
  grL.RenderPlaneUV(.5,.5,FLOORLEVEL,0,0,1,1)
  glEndList()
end

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return{T}
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="F"          --occupies floor
this.removes="TBNSEWCF"    --removes everything

this.Write=function(this,T)
  return T
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT CONDITIONS
---------------------------------------------------------------------------------------------------
this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz)
  if d==1 then return 0,0  --can't enter from below unless empty space
  else return speed, force end
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------
this.FinishEnter=function(this,obj)
  obj.MoveSpeed=0
end

