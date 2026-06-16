---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="9ee6c44d-8b32-4a4d-a29a-7a131e6b3707"
this.version="2008/04/20-22:08:00"
this.author="Joshua Bone"
this.name="Fake Blue Wall"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return {T}
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------
this.occupies="TBNSEWCF"
this.removes="TBNSEWCF"

this.Write=function(this,T)
  return T
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter2=function(this,obj,speed,force,newx,newy,newz)
  if obj.a.player then
    local floor="9a41f5ef-e6a2-405d-9416-113b927d0659"
    local newfloor=library[floor]
    AddObject(newfloor,newx,newy,newz)
    ListRemove(map[newx][newy][newz],this)
    return speed, force
  end
end