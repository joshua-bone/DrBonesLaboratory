---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="10aba34b-4b24-410a-87b8-e6253f354c37"
this.version="2008/04/20-22:08:00"
this.author="Joshua Bone"
this.name="Tile Floor"

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
  
  if not obj.a.auto then return speed, force 
  else return 0,0 end
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  obj.MoveSpeed=0
end
