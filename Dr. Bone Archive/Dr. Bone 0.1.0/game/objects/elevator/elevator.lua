--colors: 1 red   2 green    3 yellow   4 blue    5 magenta    6 cyan     7 orange  8 brown   9 white
--rules:  1 down    2 up

---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="baaedbb2-65fc-4bc2-bc29-51f971a22c48"
this.version="2008/05/14-18:20:00"
this.name="Toggle Wall"
this.author="Joshua Bone"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.colors={"red","green","yellow","blue","magenta","cyan","orange","brown","white"}

this.examples=function(T,F)
  return {  --{{this, this.rule, this.color}}
  {{T,1,1}},  --lowered green
  {{T,2,1}},  --raised green
  {{T,1,9}},  --lowered white
  }
end

--toggles raised or lowered in editor
this.EditorShuffle=function(this,dir)
  if this.color<9 then this.rule=3-this.rule end
end 

--change color in editor
this.EditorRotate=function(this,dir)
  this.color = (this.color+dir)%9
  if this.color==0 then this.color=9 end
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.clone=Clone       -- allow individual instances
this.sound={LoadSound(WD.."game/sounds/elevator.wav"),
            LoadSound(WD.."game/sounds/elevatorfail.wav")}

this.init=function(this,x,y,z)
  --elevators change enter & exit conditions (for laser purposes)
  this.a.changeAccess=true
  this.a.moving = 0 --not moving
  this.x,this.y,this.z=x,y,z
  if this.color<9 then
    ListAppend(Globals["activetoggles"][this.color],this)
  end
end    

this.Read=function(this,params)
    this.rule=params[2]
    this.color=params[3]
    this.occupies="BF"
    this.removes="BF"
end

this.Write=function(this,T)
    return {T,this.rule,this.color}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz)
  if d==1 then return 0,0 end --can't enter from below
  if this.rule==2 then 
    --for a raised white elevator, stay raised until the object above moves
    if this.color==9 and this.rule==2 and this.a.moving<32
    and GetDirection(obj.x,obj.y,obj.z,newx,newy,newz) == -1 then
      this.a.moving=32 --reset to 32 frames to move downwards
    end
    return 0,0 --can't enter a raised elevator
  else return speed, force --can enter a lowered elevator
  end
end

this.StartEnter=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz)
  if d==-1 and this.rule==1 then obj.a.fallingOntoElevator=true end
  if this.color~=9 then
    this.a.cargo=obj
  end
  return speed, force
end

this.StartExit=function(this,obj,speed,force,newx,newy,newz)
  if this.a.cargo then this.a.cargo=nil end
  return speed, force
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)
  --if obj.stop then obj:stop() end
  obj.a.fallingOntoElevator=nil
  if this.color==9 then  --white elevators lift automatically
    if VerticalMove(obj,1,1/12,1)~=0 then --try to move upwards
      DistanceSound(this.sound[1],5,this.x,this.y,this.z)
      this.a.moving=64 --32 frames up, 32 down
      this.rule=2 --raised
      MoveToList(this,Pending) --add to active list
    else
      if obj.a.player then PlaySound(this.sound[2]) end
    end
  end
end

this.FinishExit=function(this,obj)
  this.a.cargo=nil
  obj.a.fallingOntoElevator=nil
end

---------------------------------------------------------------------------------------------------
-- GAME LOGIC
---------------------------------------------------------------------------------------------------

this.logic=function(this)          -- game logic call per game frame
  if this.color==9 then
    if this.a.moving>0 then
      if this.a.moving==31 then --object has just stepped off, so play the sound
        DistanceSound(this.sound[1],5,this.x,this.y,this.z)
      end
      this.a.moving=this.a.moving-1
      MoveToList(this,Complete)
    else   
      this.rule=1
      MoveToList(this,{})
    end
  else
    if this.a.tryingtomove then
      if this:tryToMove() then
        this.a.tryingtomove=nil
      end
      MoveToList(this,Complete)
    else      
      if this.a.moving>0 then
        this.a.moving=this.a.moving-1
        MoveToList(this,Complete)
      else
        MoveToList(this,{})
      end
    end
  end
end

this.tryToMove=function(this)
  local obj=this.a.cargo
  if obj==nil or (obj and VerticalMove(obj,1,1/12,1)~=0) then
    this.a.tryingtomove=nil
    DistanceSound(this.sound[1],5,this.x,this.y,this.z)
    this.a.moving=32
    this.a.cargo=nil
    this.rule=2
    MoveToList(this,Pending)
    if obj and obj.CurrentList then MoveToList(obj,Pending) end
    return true
  end
  return false
end

this.activeToggle=function(this)
  if this.rule==1 then
    if not this:tryToMove() then
      this.rule=2
      this.a.moving=32
      this.a.tryingtomove=true
      DistanceSound(this.sound[2],5,this.x,this.y,this.z)
      MoveToList(this,Pending)
    end
  else
    if this.a.tryingtomove then
      this.a.tryingtomove=nil
      this.rule=1
      this.a.moving=0
    else
      DistanceSound(this.sound[1],5,this.x,this.y,this.z)
      this.rule=1
      this.a.moving=32
      MoveToList(this,Pending)
    end
  end
end

---------------------------------------------------------------------------------------------------
--[[ GATE LOGIC
---------------------------------------------------------------------------------------------------
this.UnWireElement=function(this)
  if this.rule==5 then this.GateLogic=nil return end    -- the button can't be wired
  this.nodes={}  -- remove all nodes
end

this.WireElement=function(this,side,x,y,wire)
  if this.nodes==nil then this.nodes={} end  -- make sure this exists
  this.inverted=false
  local sides={N=0,E=270,S=180,W=90}
  -- check panel walls
  if this.rule>0 and this.rule<3 and this.d~=sides[side] then return end
  if this.nodes[side]==nil then
    this.nodes[side]=wire
  end
end

this.GateLogic=function(this,output,input)
  local g=Globals["51e70d6f-e499-4055-89e1-c8d8f45a790f"]
  local key,value
  local wasinverted=this.inverted
  this.inverted=false
  local mycolor=({5,7,3,6})[this.color]
  for key,value in pairs(this.nodes) do
    if mycolor==g.AndTable[input(value)][mycolor] then
      this.inverted=true
    end
  end
  if wasinverted~=this.inverted then this.rule=({2,1,4,3})[this.rule] end --toggle 1,2 and 3,4
end
]]

