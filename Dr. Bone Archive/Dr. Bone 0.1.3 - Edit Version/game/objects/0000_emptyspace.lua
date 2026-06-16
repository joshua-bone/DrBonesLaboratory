---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, name)
---------------------------------------------------------------------------------------------------

this.guid="8006ef05-0bdb-4d6a-bb8c-f7533439e091"
this.name="Empty Space"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return {T}  --in the item select screen, returns just itself
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
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------
this.FinishEnter=function(this,obj)
  obj.MoveSpeed=0 --stop the object here
  if not obj.a.flies then  --if the object doesn't fly, make it fall
    if obj.z == 1 then --if we are on the lowest deck
      death.start(obj,"shrink",30) --object falls and is destroyed
    else						  --otherwise,
      VerticalMove(obj,-1,1/12,1) --move it downwards
    end
  end
end

-- if an object is not moving but here
this.Hover=function(this,obj,speed,force)
  if not obj.a.flies then --if the object doesn't fly, make it fall
    VerticalMove(obj,-1,1/12,1) --fall through empty space
  end
end

---------------------------------------------------------------------------------------------------
--RENDERING
---------------------------------------------------------------------------------------------------
this.Render=function(this) return end
this.Load=function(this) return end