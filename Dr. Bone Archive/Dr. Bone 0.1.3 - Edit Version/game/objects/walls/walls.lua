--1 wall
--2 temp inv
--3 perm inv
--4 cracked
--5 popup
--6 blue fake
--7 blue real
--8 green fake
--9 green real

---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="7964625b-92e0-42df-b23d-7d806f372bbb"
this.version="2008/04/20-22:08:00"
this.author="Chuck Sommerville"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
 --{{this, this.rule}}   (wall, temp inv, perm inv, cracked, popup, blue fake, blue real, green fake, green real)
  return {{{T,1}},{{T,2}},{{T,3}},{{T,4}},{{T,5}},{{T,6}},{{T,7}},{{T,8}},{{T,9}}} 
end

this.EditorRotate=function(this,d)
  this.rule=this.rule+d
  if this.rule>9 then this.rule=1
  elseif this.rule<1 then this.rule=9
  end
  this:EditorInit()
end

this.EditorShuffle=this.EditorRotate

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.sound=LoadSound(WD.."game/sounds/bomb.wav")
this.clone=Clone

this.Read=function(this,params)
  this.rule=params[2]
  this:EditorInit()
end

this.Write=function(this,T)
  return {T,this.rule}
end

this.EditorInit=function(this)
  this.name=({"Wall","Temp Invisible","Perm Invisible","Cracked Wall",
              "Pop-up Wall","Fake Blue Wall","Real Blue Wall",
              "Fake Green Wall","Real Green Wall"})[this.rule]
  if this.rule==5 then --popup wall
    this.occupies="F"
    this.removes="F"
  elseif this.rule==2 or this.rule==3 then --inv wall
    this.occupies="TBNSEWC"
    this.removes="TBNSEWC"  
  else
    this.occupies="TBNSEWCF"
    this.removes="TBNSEWCF"
  end
end

this.init=function(this,x,y,z)
  this.x,this.y,this.z=x,y,z
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  --player can enter for now, will check further in StartEnter
  if obj.a.player then
    return speed, force
  elseif this.rule==4 and force>1 then
    return speed, force
  elseif this.rule==8 then
    return speed, force   --can enter fake green wall
  else
    return 0,0
  end
end

this.StartEnter=function(this,obj,speed,force,newx,newy,newz)

  if this.rule==5 then
    return speed, force      --can enter pop-up wall if player
  
  elseif (this.rule==6) or (this.rule==4 and force>1) then    --fake blue or cracked with enough force
    --elements referenced by this function
    local Floor="2208f9f4-5e4b-11dc-8314-0800200c9a66"
    
    local newFloor=library[Floor]  --access floor element
    newFloor.Read(newFloor,{newFloor,1}) --read params for floor
    AddObject(newFloor,newx,newy,newz)     --add new floor to this location
    death.start(this,"explode",30) --RemoveFromGame(obj)
    DistanceSound(this.sound,5,this.x,this.y,this.z)
    if this.rule==4 then  --cracked
      return 0,0 --can't enter this turn for cracked wall
    else
      return speed, force 
    end
    
  elseif this.rule==8 then  --green fake wall
    this.a.depressed=true 
    return speed, force
    
  else
    if this.rule==3 then  --perm invisible
      this.rule=1
    elseif this.rule==2 then  --temp invisible
      this.temprule=1
      this.lasttick=tick
    elseif this.rule==7 then  --blue real
      this.rule=1
    end
    return 0,0
  end
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------
this.FinishEnter=function(this,obj)
  obj.MoveSpeed=0
end

this.FinishExit=function(this,obj)
  if this.rule==5 then 
    this.rule=1      --pop-up wall --> wall
  elseif this.rule==8 then
    this.a.depressed=nil  --green fake wall
  end
end





