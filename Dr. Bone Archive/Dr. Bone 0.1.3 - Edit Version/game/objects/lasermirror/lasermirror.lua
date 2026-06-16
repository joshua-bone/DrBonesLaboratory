---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="2cdd1b18-c464-471d-979c-c31e6464e232"
this.name="Laser Mirror"
this.author="Joshua Bone"
this.version="2008/05/26-16:15:30"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  --{{this, this.rule, this.d}}   (two-sided mirror, one-sided mirror)
  return{{{T,1,0}},{{T,2,0}}}
end

--rotate direction in editor
this.EditorRotate=EditorRotate

--toggle between 1 and 2 sided mirror in editor
this.EditorShuffle=function(this)
  this.rule=3-this.rule
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.clone=Clone
this.occupies="T" --occupies top
this.removes="T"  --removes top

this.init=function(this,x,y,z)
  this.a.push=true
  this.a.reqFinishEnt=true  --lasers have to FinishEnter
  --one-sided mirrors have 50 hit points before being destroyed by laser
  if this.rule==2 then this.a.HP=50 end
  this.MoveSpeed,this.MoveForce=0,0
  this.x,this.y,this.z=x,y,z
  this:stop()
  MoveToList(this,Pending)
end

this.delete=function(this)

  --element referenced in this function
  local laser="0b2de6b9-8290-431e-9aad-fc474ae8d302"
  
  --check this location for lasers; recursively delete them and their offspring
  local here=map[this.x][this.y][this.z]
  local w
  for w=#here,1,-1 do
    if here[w].guid==laser then 
      RemoveFromGame(here[w])
    end
  end
end

this.Read=function(this,params)
  this.rule=params[2]
  this.d=params[3]
end

this.Write=function(this,T)
  return {T,this.rule,this.d}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter2=function(this,obj,speed,force,newx,newy,newz)

  --element referenced in this function
  local laser="0b2de6b9-8290-431e-9aad-fc474ae8d302"
  
  --laser can always enter
  if obj.guid==laser then 
    return speed,force 
  end
  
  --everything else except player can NOT enter
  if not obj.a.player then 
    return 0,0 
  end   
  
  --try to move in direction of push
  local d=GetDirection(obj.x,obj.y,obj.z,this.x,this.y,this.z)
  if math.abs(d)==1 then return 0,0 end --can't enter if traveling down or up
  local vector=vectors[d]
  local newx=this.x+vector.dx
  local newy=this.y+vector.dy
  
  local newspeed=TestMove(this,1/12,1,newx,newy,this.z)
  
  if newspeed~=0 then --if move was successful
    if this.a.HP then this.a.HP=50 end  --reset hit points
	  MoveToList(this,Pending)  --add to active list for duration of move
    StartMove(this,newspeed,1,newx,newy,this.z)  --start the move
    return speed,force  --allow entry
    
  else  --if move was unsuccessful
    return 0,0  --deny entry
  end
end  

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.rules={{N=270,E=0,S=90,W=180},{N=270,W=180}}

this.FinishEnter=function(this,obj)

  --element referenced in this function
  local laser="0b2de6b9-8290-431e-9aad-fc474ae8d302"
  
  --if object is a laser beam (something is wrong if it isn't)
  if obj.guid==laser then
  
    --get direction of laser beam relative to this rotation
    local d=GetRelativeDirection(this.d,obj.d)
    --get reflected direction according to this rule
    d=this.rules[this.rule][dirs[d]]
    
    --if there is a valid reflection
    if d then 
      --then give the laser beam the new reflected direction
      obj.d=GetTrueDirection(this.d,d)
      
    else --if there is no valid reflection
      --if this has hit points remaining
      if this.a.HP and this.a.HP>0 then 
        RemoveFromGame(obj)   --then delete the object
        this.a.HP=this.a.HP-1 --and subtract one hit point
        
      else  --if this has no hit points left
        if obj.parent.type==4 then 
          --then delete parent laser beam and all offspring
          RemoveFromGame(obj.parent)
        end
        --delete this mirror
        DistanceSound(obj.sound,5,this.x,this.y,this.z)
  	    death.start(this,"explode",30) --removeFromGame(this)
      end    
    end
  end
end   



this.stop=function(this)
  this.offset=0
  this.MoveSpeed=0
  this.fromx,this.fromy,this.fromz=this.x,this.y,this.z
end
  
---------------------------------------------------------------------------------------------------
--GAME LOGIC
---------------------------------------------------------------------------------------------------

--standard logic for pushblocks, keeps this off the active list when not moving
this.logic=BlockLogic

