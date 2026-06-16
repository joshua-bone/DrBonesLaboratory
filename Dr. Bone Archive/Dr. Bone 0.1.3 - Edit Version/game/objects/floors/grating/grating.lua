---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="c86f4210-9b8f-471e-95b7-b349e5d193e0"
this.version="2008/04/20-22:08:00"
this.author="Joshua Bone"
this.name="Grating"

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
this.transparent=1 --floor transparency (1=floor, 2=bottom, 3=center, 4=top)

this.Write=function(this,T)
  return T
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT CONDITIONS
---------------------------------------------------------------------------------------------------
this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz)
  if d==1 then return 0,0 --can't enter from below unless empty space
  else return speed, force end --can always enter from above
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------
this.FinishEnter=function(this,obj)
  obj.MoveSpeed=0
end

this.FinishExit=function(this,obj)
  local space="8006ef05-0bdb-4d6a-bb8c-f7533439e091"
  local newspace=library[space]
  AddObject(newspace,obj.fromx,obj.fromy,obj.fromz)    --add the space
  ListRemove(map[obj.fromx][obj.fromy][obj.fromz],this) --remove the grating
end
