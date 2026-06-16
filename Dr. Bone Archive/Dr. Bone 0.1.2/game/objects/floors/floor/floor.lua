---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="9a41f5ef-e6a2-405d-9416-113b927d0659"
this.version="2008/04/20-22:08:00"
this.author="Chuck Sommerville"
this.name="Floor"

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
this.removes="TBNSEWCF"

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

