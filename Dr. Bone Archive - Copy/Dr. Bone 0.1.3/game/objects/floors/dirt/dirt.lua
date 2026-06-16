---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="5e62ea4d-864c-416d-8b37-bd061d3bbdcf"
this.version="2008/04/20-22:08:00"
this.author="Joshua Bone"
this.name="Dirt"

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
this.removes="F"
this.sound=LoadSound(WD.."game/sounds/dirt.wav")

this.Write=function(this,T)
  return T
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)

  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz)
  if d==1 then return 0,0 end --can't enter from below unless empty space
  if d==-1 then return speed, force end --can always enter from above
  
  local laser="0b2de6b9-8290-431e-9aad-fc474ae8d302"
  if obj.guid==laser then
    return speed, force
  end
 
  local block="79d1a60f-0145-4e2b-8e61-c35b49aa3192"
  if not (obj.a.player or (obj.guid==block and obj.rule==2)) then --player and iceblock can enter
    return 0,0
  end
  return speed, force
end

this.StartEnter=function(this,obj,speed,force,newx,newy,newz)
  PlaySound(this.sound)
  return speed, force
end
---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------
this.FinishEnter=function(this,obj)
  obj.MoveSpeed=0
  local floor="9a41f5ef-e6a2-405d-9416-113b927d0659"
  local newfloor=library[floor]
  ListRemove(map[obj.x][obj.y][obj.z],obj) --remove the entering object just for list order purposes
  AddObject(newfloor,obj.x,obj.y,obj.z)    --add the floor
  ListRemove(map[obj.x][obj.y][obj.z],this) --remove the dirt
  ListAppend(map[obj.x][obj.y][obj.z],obj) --and return the entering object
end
