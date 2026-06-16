---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="41d5cab5-a7e2-4457-aa13-b0726244ec1b"
this.version="2008/04/20-22:08:00"
this.author="Joshua Bone"
this.name="Glass"

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
this.sound=LoadSound(WD.."game/sounds/glassbreak.wav")

this.Write=function(this,T)
  return T
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------
this.FinishEnter=function(this,obj)
  obj.MoveSpeed=0
  if obj.fromz~=obj.z or obj.a.push then
    local space="8006ef05-0bdb-4d6a-bb8c-f7533439e091"
    local newspace=library[space]
	ListRemove(map[obj.x][obj.y][obj.z],obj)
    AddObject(newspace,obj.x,obj.y,obj.z)    --add the space
    ListRemove(map[obj.x][obj.y][obj.z],this) --remove the grating
	ListAppend(map[obj.x][obj.y][obj.z],obj)
	newspace:FinishEnter(obj)
    PlaySound(this.sound)
  end
end
