---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="8aed190b-e432-4221-9766-d4f4854ead86"
this.version="2008/05/15-09:29:00"
this.author="Joshua Bone"
this.name="Thief"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  --boot thief, key thief
  return {{{T,1}},{{T,2}}}
end

this.EditorRotate=function(this)
  this.rule=3-this.rule
end

this.EditorShuffle=this.EditorRotate

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="B"
this.removes="B"
this.clone=Clone

this.Read=function(this,params)
  this.rule=params[2]
end

this.Write=function(this,T)
  return {T,this.rule}
end

this.TestEnter=function(this,obj,speed,force)
  local laser="0b2de6b9-8290-431e-9aad-fc474ae8d302"
  if obj.a.player then return speed,force   
  elseif obj.guid==laser then return speed,force
  else return 0,0
  end
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)

  --elements referenced by this function
  local key="71c3697c-1348-4f5e-a07f-8ce68d45a351"
  local boot="e0159bb2-2559-44df-b9d0-5d836c6f0a14"
 
  if this.rule==2 then   --boot thief
    obj.i[boot]=nil
  else  --key thief
    obj.i[key]=nil
  end
end



