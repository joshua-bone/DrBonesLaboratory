---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------
this.guid="b4bce2a0-3ec5-11dd-ae16-0800200c9a66"
this.version="2008/06/20-08:38:00"
this.author="Joshua Bone"
this.name="Bomb"

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------
this.occupies="C"
this.removes="C"
this.transparent=3 --center transparency
this.sound=LoadSound(WD.."game/sounds/bomb.wav")

this.init=function(this)
  this.a.reqFinishEnt=true  --lasers have to FinishEnter
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  local laser="0b2de6b9-8290-431e-9aad-fc474ae8d302"
  
  ListRemove(map[obj.x][obj.y][obj.z],this)
  DistanceSound(this.sound,5,obj.x,obj.y,obj.z)
  if obj.guid~=laser then
    death.start(obj,"explode",30,"Oops! Watch out for bombs!") --RemoveFromGame(obj)
  end
end
