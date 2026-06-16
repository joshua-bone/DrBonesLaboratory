--[[ 
1 red
2 orange
3 yellow
4 brown
5 blue
6 cyan
7 magenta
8 green
9 lockpick
]]--

---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="71c3697c-1348-4f5e-a07f-8ce68d45a351"
this.version="2008/05/15-09:29:00"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------
this.colors={"red","orange","yellow","brown","blue","cyan","magenta","green"}
this.sound={LoadSound(WD.."game/sounds/pickup.wav"),
            LoadSound(WD.."game/sounds/unlock.wav")}

this.examples=function(T,F)
  --yellow key, yellow door
  return {{{T,1,3},F},{{T,2,3},F},} --{{this,this.rule,this.color}}
end

--rotates through colors, not direction
this.EditorRotate=function(this,dir)
  this.color=this.color+dir
  if this.rule==1 then --9 key types
    if this.color==10 then this.color=1
    elseif this.color==0 then this.color=9
    end
  else --8 door types
    if this.color==9 then this.color=1
    elseif this.color==0 then this.color=8
    end
  end
end

--shuffles between key and door of same color
this.EditorShuffle=function(this)
  if this.color <= 8 then
    this.rule=3-this.rule
  end
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.clone=Clone
this.transparent=3--center transparency (1=floor, 2=bottom, 3=center, 4=top)
  
this.Read=function(this,params)
    this.rule=params[2]
    this.color=params[3]
    this.occupies=({"C","TBNSEWCF"})[this.rule]  -- key,door
    this.removes=({"C","TBNSEWC"})[this.rule]
    this.name=({"Key","Door"})[this.rule]
end

this.Write=function(this,T)
  return {T,this.rule,this.color}
end

this.init=function(this,x,y,z)
  if this.rule==1 then
    this.a.pickup=true
    this.a.power=1
    this.MoveSpeed,this.MoveForce=0,0
    this.x,this.y,this.z=x,y,z
    this.offset=0
    this.fromx,this.fromy,this.fromz=x,y,z
    MoveToList(this,Pending)
  end
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force)
  if this.rule==2 and ((not obj.i[this.guid])
  or (obj.i[this.guid][this.color]<=0 and obj.i[this.guid][9]<=0)) then
    return 0,0 --can't enter a locked door without key or lockpick
  elseif obj.a.pickup then
    return 0,0
  else
    return speed, force
  end
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  if this.rule==1 then            -- keys
    local block="79d1a60f-0145-4e2b-8e61-c35b49aa3192"
  --if player      (bots can pick up red, orange, yellow, brown keys)
    if obj.a.player or
      (this.color<=4 and obj.a.auto) then
      if obj.i[this.guid]==nil then obj.i[this.guid]={0,0,0,0,0,0,0,0,0} end  -- init the array if none exists
      obj.i[this.guid][this.color]=obj.i[this.guid][this.color]+1
      ListRemove(map[obj.x][obj.y][obj.z],this)    -- take the key off the map
      DistanceSound(this.sound[1],5,obj.x,obj.y,obj.z)
    elseif obj.guid==block and obj.rule==3 then --glass block
      obj.a.cargo=this
    end
  else
    obj.MoveSpeed=0
    local floor="9a41f5ef-e6a2-405d-9416-113b927d0659"
    local newfloor=library[floor]
    ListRemove(map[obj.x][obj.y][obj.z],obj) --remove the entering object just for list order purposes
    AddObject(newfloor,obj.x,obj.y,obj.z)    --add the floor
    ListRemove(map[obj.x][obj.y][obj.z],this) --remove the door
    ListAppend(map[obj.x][obj.y][obj.z],obj) --and return the entering object
    DistanceSound(this.sound[2],5,obj.x,obj.y,obj.z)
    if this.color<=7 then
      if obj.i[this.guid][this.color]>0 then --used a key so subtract a key
        obj.i[this.guid][this.color]=obj.i[this.guid][this.color]-1
      else
        obj.i[this.guid][9]=obj.i[this.guid][9]-1 --used a lockpick so subtract a lockpick
      end
    elseif this.color==8 and obj.i[this.guid][8]==0 then --used lockpick on green door
      obj.i[this.guid][9]=obj.i[this.guid][9]-1
    end
  end
end

this.logic=BlockLogic
