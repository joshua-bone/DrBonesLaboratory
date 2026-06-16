---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="8006ef05-0bdb-4d6a-bb8c-f7533439e091"
this.version="2009/06/04-22:08:00"
this.author="Joshua Bone"
this.name="Empty Space"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return {T}
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="F"          --occupies floor
this.removes="TBNSEWCF"

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------
this.FinishEnter=function(this,obj)
  obj.MoveSpeed=0
  if not obj.a.flies then
    if obj.z == 1 then --if we are on the lowest deck
      death.start(obj,"shrink",30) --object falls away
    else
      VerticalMove(obj,-1,1/12,1) --fall through empty space
    end
  end
end

-- if an object is not moving but here
this.Hover=function(this,obj,speed,force)
  if not obj.a.flies then
    VerticalMove(obj,-1,1/12,1) --fall through empty space
  end
end
