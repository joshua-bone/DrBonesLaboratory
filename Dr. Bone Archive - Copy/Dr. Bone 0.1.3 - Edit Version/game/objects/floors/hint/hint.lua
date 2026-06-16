---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="f913ff37-d021-431a-baf6-f583aeb57e95"
this.version="2010/12/17-15:16:00"
this.author="Joshua Bone"
this.name="Hint"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return{T}
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="C"          --occupies center
this.removes="C"
this.clone=recursiveClone
this.transparent=3 --center transparency
this.message={""}

this.Write=function(this,T)
  return {T, this.message}
end

this.Read=function(this, params)
  this.message=params[2]
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------
this.FinishEnter=function(this,obj)
  if obj.name=="Player" then
    this.savehud=PlayHud[2][2]
	PlayHud[2][2]=this.message
  end
end

this.FinishExit=function(this,obj)
  if obj.name=="Player" then
    PlayHud[2][2]=this.savehud
  end
end
