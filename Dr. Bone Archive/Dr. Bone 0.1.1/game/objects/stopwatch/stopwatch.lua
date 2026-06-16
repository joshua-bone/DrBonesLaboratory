---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="32393cd0-3cbb-442a-b6a5-59c9f33e7116"
this.version="2008/04/23-21:03:00"
this.name="Stopwatch"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------
this.examples=function(T,F)
  return {T}
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="B"
this.removes="B"

this.Write=function(this,T)
  return T
end

this.init=function(this)
  this.oldmonsterspeed=nil
  monsterspeed=1/12
  this.lasttick=nil
end

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  if obj.a.player then return speed, force
  else return 0,0
  end
end

-- when an object finishes entering, it should continue to the next teleport, or slide across
this.FinishEnter=function(this,obj)
  if not this.oldmonsterspeed then
    this.oldmonsterspeed=monsterspeed
    monsterspeed=1/60
    this.lasttick=tick
    MoveToList(this,Pending)
  end
end

this.logic=function(this)
  local dt=tick-this.lasttick
  if dt>500 then
    this.lasttick=nil
    monsterspeed=this.oldmonsterspeed
    this.oldmonsterspeed=nil
    MoveToList(this,{})
  else
    MoveToList(this,Complete)
  end
end
