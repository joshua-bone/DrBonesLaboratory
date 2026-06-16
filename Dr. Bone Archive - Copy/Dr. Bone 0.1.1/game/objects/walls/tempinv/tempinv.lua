---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="81ea3327-22ae-45ff-91a6-3f6fd83c7502"
this.version="2008/04/20-22:08:00"
this.author="Joshua Bone"
this.name="Temporary Invisible Wall"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------
this.occupies="TBNSEWCF"
this.removes="TBNSEWC"

this.examples=function(T,F)
  return {T}
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.Write=function(this,T)
  return {T}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter2=function(this,obj,speed,force,newx,newy,newz)
  local wall="f52413b1-9bf7-463e-9e60-84794fafef1a"
  local newwall=library[wall]
  AddObject(newwall,newx,newy,newz)    --add the wall
  ListRemove(map[newx][newy][newz],this) --remove the popup wall
  return 0,0
end