---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="b0138afc-3357-4dba-b3e8-2cea2d6db89d"
this.version="2008/06/20-09:04:08"
this.author="Joshua Bone"
this.name="Fire"

---------------------------------------------------------------------------------------------------
--EDITOR
---------------------------------------------------------------------------------------------------
this.examples=function(T,F)
  return{{{T,1}}}
end
---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------
this.occupies="F"
this.removes="F"

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force,newx,newy,newz) 
  local d=GetDirection(obj.fromx,obj.fromy,obj.fromz,newx,newy,newz)
  if d==1 then return 0,0 end --can't enter from below unless empty space
  if d==-1 then return speed, force end --can always enter from above
  --element referenced in this function
  local bot="88f59a96-c802-43fe-81c8-780ad2fccf91"
  if obj.guid==bot and obj.rule==1 then return 0,0 end		--lhr bots (aka tarantula) cannot enter
  return speed,force
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  local boot = "e0159bb2-2559-44df-b9d0-5d836c6f0a14"
  obj.MoveSpeed=0
  if not (obj.i[boot] and obj.i[boot][2]>0) then --if object does not have fire boots
    local fcn=obj.Interactions
    if fcn and fcn[this.guid] then  --if the object has defined interactions with this element
      fcn[this.guid](obj,this)      --then do those
    else
      death.start(obj,"explode",30,"Don't Step In Fire Without Fire Boots!") --default is to destroy the object
    end
  end
end
