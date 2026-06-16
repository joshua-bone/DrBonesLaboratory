----------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="555e0e07-e5fb-434d-aa48-50bf45c0848c"
this.version="2008/04/20-22:08:00"
this.author="Joshua Bone"
this.name="Cracked Wall"

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
  if force>1 then
    local floor="9a41f5ef-e6a2-405d-9416-113b927d0659"
    local newfloor=library[floor]
    AddObject(newfloor,newx,newy,newz)
    ListRemove(map[newx][newy][newz],this)
  end
  return 0,0
end