---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="79d1a60f-0145-4e2b-8e61-c35b49aa3192"
this.name="Pushblock"                                                                                                     
this.author="Joshua Bone"
this.version="2008/06/10-08:27:57"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  --{{this, this.rule,this.d}}   (dirt block, ice block, glass block)
  return{{{T,1,0}},{{T,2,0}},{{T,3,0}}}
end

this.EditorShuffle=function(this,dir)
  this.rule=(this.rule+dir)%3
  if this.rule==0 then this.rule=3 end
end

this.EditorRotate=EditorRotate

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.sound={LoadSound(WD.."game/sounds/pushblock.wav"),
            LoadSound(WD.."game/sounds/glassbreak.wav")}

this.clone=Clone  --allow individual instances
this.occupies="T" --blocks occupy top
this.removes="T"  

this.init=function(this,x,y,z)
  this.a.push=true  --pushable attribute
  this.a.power=2    --can kill player
  if this.rule==2 then 
    this.a.HP=50 --# of laser hits to destroy ice
  elseif this.rule==3 then 
    this.transparent=3 --top transparency
    this.a.cargo=nil
    local w
    local here=map[x][y][z]
    for w=#here,1,-1 do
      if here[w].a and here[w].a.pickup then
        ListRemove(here,this)
        ListAppend(here,this)
        this.a.cargo=here[w]
      end
    end
  end 
  this.MoveSpeed,this.MoveForce=0,0
  this.x,this.y,this.z=x,y,z
  this:stop()
  MoveToList(this,Pending)
end

--stops the object's motion
this.stop=function(this)
  this.offset=0
  this.MoveSpeed=0
  this.fromx,this.fromy,this.fromz=this.x,this.y,this.z
end

this.Write=function(this,T)
  return {T,this.rule,this.d}
end

this.Read=function(this,params)
  this.rule=params[2]
  this.d=params[3]
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  --player can enter for now, we will check further in StartEnter
  if obj.a.player then 
    return speed, force 
  end
  
  if force>1 and this.rule==3 then return speed, force end
  
  --iceblocks push iceblocks
  if obj.guid==this.guid and this.rule==2
  and obj.rule==2 then
    return speed, force
  end
  
  return 0,0 --default is no entry
end

this.TestEnter2=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz) --the true direction of desired motion
  if this.rule==3 and (force>1 or (d==-1 and obj.fromz>obj.z)) then
    if this.a.cargo then this.a.cargo=nil end
    PlaySound(this.sound[2])
    RemoveFromGame(this)
    return 0,0
  end
  if math.abs(d)~=1 then
    local vector=vectors[d]
    local nx=this.x+vector.dx
    local ny=this.y+vector.dy     
    local newspeed=TestMove(this,1/12,1,nx,ny,this.z) --test push in desired direction
    if newspeed~=0 then   --if push is successful
	  this.d = d
	  PlaySound(this.sound[1])
	  if this.a.cargo then 
		local newspeed=TestMove(this.a.cargo,1/12,1,nx,ny,this.z)
		if newspeed~=0 then
			StartMove(this.a.cargo,newspeed,1,nx,ny,this.z)
			MoveToList(this.a.cargo,Pending)
		end
	  end
	  StartMove(this,newspeed,1,nx,ny,this.z)  --start moving
	  if this.a.HP then this.a.HP=50 end    --reset hit points
	  MoveToList(this,Pending)              --add to active list for move  
      return speed,force     
    else  --if push is unsuccessful
      return 0,0 --can't enter because push failed
    end
  else
    return 0,0
  end
end 

this.StartEnter=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz) --the true direction of desired motion
  this.d=d
  local vector=vectors[d]
  local newx=this.x+vector.dx
  local newy=this.y+vector.dy   
  PlaySound(this.sound[1])
  local newspeed=TestMove(this,1/12,1,newx,newy,obj.z) --test push in desired direction

	if this.a.cargo then 
	  local newspeed=TestMove(this.a.cargo,1/12,1,newx,newy,obj.z)
	  if newspeed~=0 then
		StartMove(this.a.cargo,newspeed,1,newx,newy,newz)
		MoveToList(this.a.cargo,Pending)
	  end
	end
	StartMove(this,newspeed,1,newx,newy,this.z)  --start moving
	if this.a.HP then this.a.HP=50 end    --reset hit points
	MoveToList(this,Pending)              --add to active list for move
	return speed, force
end

---------------------------------------------------------------------------------------------------
--GAME LOGIC
---------------------------------------------------------------------------------------------------

--references standard logic for pushblocks
this.logic=BlockLogic 


this.drop=function(this)
  if this.rule==3 then
    PlaySound(this.sound[2])
    if this.a.cargo then this.a.cargo=nil end
    RemoveFromGame(this)
    return 1
  end
  return 0
end

---------------------------------------------------------------------------------------------------
--INTERACTIONS WITH OTHER ELEMENTS
---------------------------------------------------------------------------------------------------

--experimental

--elements referenced in this section
local Water="1dc832bf-01bb-48d4-a25d-397c70519a98"
local Fire="b0138afc-3357-4dba-b3e8-2cea2d6db89d"

--an empty table to hold functions
this.Interactions={}

--FINISH ENTERING WATER
this.Interactions[Water]=function(this,obj)

  --elements referenced by this function
  local Dirt="5e62ea4d-864c-416d-8b37-bd061d3bbdcf"
  local Ice="8210bcba-7b80-490e-8248-78ec28684fe8"
  if this.rule==1 then   --dirt block turns to dirt in water
    local newDirt=library[Dirt]  --access dirt element
    ListRemove(map[this.x][this.y][this.z],obj)
    AddObject(newDirt,this.x,this.y,this.z)  --add new dirt to this location
    death.start(this,"sink",15)              --destroy the dirt block
    
  elseif this.rule==2 then  --ice block turns to ice in water
   
    local newIce=Guid2Object(Ice) --access ice element
    newIce.Read(newIce,{newIce,1,0})  --read params for ice floor
    ListRemove(map[this.x][this.y][this.z],obj)
    AddObject(newIce,this.x,this.y,this.z)   --add new ice to this location
    death.start(this,"sink",15) --RemoveFromGame(this)              --destroy the ice block
  end
end

--FINISH ENTERING FIRE
this.Interactions[Fire]=function(this,obj)
  
  if this.rule==2 then  --ice block turns to water in fire
    local Water="1dc832bf-01bb-48d4-a25d-397c70519a98"
    local newWater=library[Water] --access water element
    AddObject(newWater,this.x,this.y,this.z)   --add new water to this location
    death.start(this,"shrink",30) --RemoveFromGame(this)              --destroy the ice block
  end
end



