---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------
this.guid="b4bce2a0-3ec5-11dd-ae16-0800200c9a66"
this.name="Bomb"

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------
this.occupies="C"
this.removes="C"
this.transparent=3 --center transparency
this.sound=LoadSound(WD.."game/sounds/bomb.wav")

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  ListRemove(map[obj.x][obj.y][obj.z],this)
  DistanceSound(this.sound,5,obj.x,obj.y,obj.z)
  local fcn=obj.Interactions
  if fcn and fcn[this.guid] then  --if the object has defined interactions with this element
    fcn[this.guid](obj,this)      --then do those
  else
    death.start(obj,"explode",30,"Don't Touch The Bombs!") --default is to destroy the object
  end
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

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
  this.Resource=LoadTexture(this.path.."graphics/0025_bomb.bmp")
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