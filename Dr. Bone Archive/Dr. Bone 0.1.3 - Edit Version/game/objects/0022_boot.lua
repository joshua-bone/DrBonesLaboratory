---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="e0159bb2-2559-44df-b9d0-5d836c6f0a14"
this.name="Boot"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return{
  --{{this, this.rule}, floor}  
  {{T,1},F},  --suction boots
  {{T,2},F},  --fire boots
  {{T,3},F},  --flippers
  {{T,4},F},  --ice skates
  }
end

--rotates bot type
this.EditorShuffle=function(this,dir)
  this.rule=this.rule+dir
  if this.rule>4 then this.rule=1
  elseif this.rule<1 then this.rule=4
  end
end

this.EditorRotate=EditorShuffle

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="C"      --occupies top
this.removes="C"       --removes top
this.clone=Clone       -- allow individual instances
this.transparent=3 --center transparency (1=floor, 2=bottom, 3=center, 4=top)  --uses a graphics mask
this.sound=LoadSound(WD.."game/sounds/pickup.wav")

this.Read=function(this,params)
  this.rule=params[2]
end

this.Write=function(this,T)
  return {T,this.rule}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.fromx,obj.fromy,obj.fromz,newx,newy,newz)
  if d==-1 then return speed, force end --can always enter from above
  
  if obj.a.player then  --player can enter
	  return speed,force 
  else 
	  return 0,0  --nothing else can enter
  end
end

---------------------------------------------------------------------------------------------------
--MOVE COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  if obj.a.player then
    if not obj.i[this.guid] then --if we're not tracking a boot inventory yet
      obj.i[this.guid]={0,0,0,0}  --then start
    end
    obj.i[this.guid][this.rule]=obj.i[this.guid][this.rule]+1 --add to the inventory
    ListRemove(map[obj.x][obj.y][obj.z],this)             --remove from the map
    PlaySound(this.sound)
  end
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------

this.Render=function(this,h)
  glPushMatrix()
  glEnable(GL_BLEND)
  glBlendFunc(GL_DST_COLOR,GL_ZERO)
  glCallList(this.glist+(this.rule-1)*2+1)  -- render the mask
  glBlendFunc(GL_ONE, GL_ONE)
  glColor3f(h,h,h) --darken with depth
  glCallList(this.glist+(this.rule-1)*2) --render the boot
  glDisable(GL_BLEND)
  glPopMatrix()
end

this.Load=function(this,params)
  this.Resource=LoadTexture(this.path.."graphics/0022_boot.bmp")   -- load resources
  this.glist=glGenLists(8)
  local g,h=1/512,1/256
  local i,j
  for i=0,3 do
    for j=0,1 do
      glNewList(this.glist+i*2+j,GL_COMPILE)
      glBindTexture(GL_TEXTURE_2D,this.Resource)
      RenderPlaneUV(.5,.5,CENTERLEVEL,i/4+g,(1-j)/2+h,(i+1)/4-g,(2-j)/2-h)
      glEndList()
    end
  end
end

this.MeasureInventory=function(obj)
  local count=0
  local n
  if obj.i[this.guid] then
    for n=1,4 do
      if obj.i[this.guid][n]~=0 then count=count+1 end
    end
  end
  return count
end

this.RenderInventory=function(obj)
  local n
  if obj.i[this.guid] then
    for n=1,4 do
      local item=library[this.guid]
      item.rule=n
      InventoryHelper(item,obj.i[this.guid][n])
    end
  end
end
