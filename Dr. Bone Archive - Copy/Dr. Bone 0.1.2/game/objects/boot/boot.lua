---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="e0159bb2-2559-44df-b9d0-5d836c6f0a14"
this.version="2008/04/20-22:08:00"
this.author="Joshua Bone"
this.name="Boot"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return{
  --{{this, this.rule, this.d}, floor}  
  {{T,1,0},F},  --suction boots
  {{T,2,0},F},  --fire boots
  {{T,3,0},F},  --flippers
  {{T,4,0},F},  --ice skates
  }
end

--rotates bot type
this.EditorShuffle=function(this,dir)
  this.rule=this.rule+dir
  if this.rule>4 then this.rule=1
  elseif this.rule<1 then this.rule=4
  end
end

this.EditorRotate=EditorRotate

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="C"      --occupies top
this.removes="C"       --removes top
this.clone=Clone       -- allow individual instances
this.transparent=3 --center transparency (1=floor, 2=bottom, 3=center, 4=top)  --uses a graphics mask
this.sound=LoadSound(WD.."game/sounds/pickup.wav")

this.init=function(this,x,y,z) 
--ATTRIBUTES
  this.a.pickup=true
  this.a.power=1
  this.MoveSpeed,this.MoveForce=0,0
  this.x,this.y,this.z=x,y,z
  this.offset=0
  this.fromx,this.fromy,this.fromz=x,y,z
  MoveToList(this,Pending)
end

this.Read=function(this,params)
  this.rule=params[2]
end

this.Write=function(this,T)
  return {T,this.rule}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  local block="79d1a60f-0145-4e2b-8e61-c35b49aa3192"
  if obj.a.player then  --player can enter
	  return speed,force 
  elseif obj.guid==block and obj.rule==3 then --glass block
    return speed, force
  else 
	  return 0,0  --nothing else can enter
  end
end

---------------------------------------------------------------------------------------------------
--MOVE COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  local block="79d1a60f-0145-4e2b-8e61-c35b49aa3192"
  if obj.guid==block and obj.rule==3 then
    obj.a.cargo=this
  else
    if not obj.i[this.guid] then
      obj.i[this.guid]={0,0,0,0}
    end
    obj.i[this.guid][this.rule]=obj.i[this.guid][this.rule]+1
    ListRemove(map[obj.x][obj.y][obj.z],this) 
    PlaySound(this.sound)
  end
end

this.logic=BlockLogic
