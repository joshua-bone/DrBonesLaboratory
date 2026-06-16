---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="0b2de6b9-8290-431e-9aad-fc474ae8d302"
this.version="2008/05/23-22:00:00"
this.author="Joshua Bone"
this.name="Laser"

--[[  VALUES FOR this.rule
1 button
2 turret OFF
3 turret ON
4 beam
]]--

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------
this.colors={"red","green","yellow","blue","magenta","cyan","orange","brown","white"}

--build parts list
this.examples=function(T,F)
  --{turret OFF},{turret ON} (all facing north)
  --{{this,this.rule,this.d,this.color}}
  return {{{T,1,0,1}},{{T,2,0,1}}}
end

--rotate direction in editor
this.EditorRotate=EditorRotate

--change colors in editor
this.EditorShuffle=function(this,dir)
  this.color=(this.color+dir)%8
  if this.color==0 then this.color=8 end
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.sound=LoadSound(WD.."game/sounds/bomb.wav")
this.clone=Clone

this.init=function(this,x,y,z,parent)

  --element referenced in this function
  local mirror="2cdd1b18-c464-471d-979c-c31e6464e232"
  
  this.x,this.y,this.z=x,y,z --all rules know their location
  
  --laser beam init
  if parent then
    this.rule=3             --params for laser beam
    this.color=parent.color
    this.parent=parent      --the child beam has a pointer to its parent
    this.parent.child=this  --the parent beam has a pointer to its child
    this.d=this.parent.d    --default direction same as parent's direction
    
    local here=map[x][y][z] 	--check here for elements that affect lasers
    local w
    for w=#here,1,-1 do  

      --if we need to FinishEnter
      if here[w].a.reqFinishEnt then              --if a laser mirror
        this.parent.active=true                 --parent never sleeps  
        here[w].FinishEnter(here[w],this)       --call FinishEnter to reflect in proper direction
        
      --ANOTHER LASER BEAM
      elseif here[w].guid==this.guid --if a laser
      and here[w].d==this.d     --pointing in the same direction
      --and if the laser is also pointing in the same direction as its parent (i.e., it is not on a mirror)
      and here[w].d==here[w].parent.d then
        
          --then tag this laser beam for immediate removal from active list
          this.active=false 
        
      --ELEVATORS, etc
      --if on an element which changes its entry and exit conditions (i.e. elevator)
      
      elseif here[w].a.changeAccess then
      
        --then this laser beam and its parent do not sleep
        this.active=true		
        this.parent.active=true
      end
    end
  end 
   
  --turret init
  if this.rule<3 then 
    this.active=true       --turrets are always active
  end
  
  --game logic needs to be called for turrets and lasers 
  MoveToList(this,Pending) 
end

--recursively deletes this and all offspring
this.delete=function(this)

  --if this has offspring
  if this.child then
    --remove child's pointer to this so it doesn't move this back to Pending
    this.child.parent=nil 
    --recursively delete all offspring
    RemoveFromGame(this.child)
  end
  
  --if this has a parent (only the first laser to be deleted will have one at this point, see above code)
  if this.parent then
    --remove parent's pointer to this
    this.parent.child=nil
    --if parent is a laser beam, wake it up so it can try to propagate
    if this.parent.rule==3 then
      MoveToList(this.parent,Pending)
    end
  end
end

this.Read=function(this,params)
  this.rule=params[2]
  this.d=params[3]
  this.color=params[4]
  
  -- turrets and beam occupy top, center, bottom
  this.occupies,this.removes="TCB","TCB"
end

this.Write=function(this,T)
  return {T,this.rule,this.d,this.color}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  if this.rule<3 then
    local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz)
    if math.abs(d)==1 then return 0,0 end --can't enter from above or below
  end
end
  

this.TestEnter2=function(this,obj,speed,force,newx,newy,newz)

  --TURRETS
  if this.rule<3 then
  
    --if less than 10 ticks have passed since something has tried to enter this turret
    if this.lasttick and (tick-this.lasttick)<10 then 
      return 0,0  --then deny access
    end
    
    if obj.a.push or obj.guid==this.guid then return 0,0 end --blocks and lasers can't change laser direction, but anything else can
    
    --recursively deletes all offspring
    if this.child then RemoveFromGame(this.child) end
    
    --the true direction of the entering object
    local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz)
    --the relative direction with respect to this rotation
    local rel_d=GetRelativeDirection(this.d,d)
    --keep track of when this occured
    this.lasttick=tick

    if rel_d==0 then      --if pushing from behind
      this.rule=3-this.rule --then turn the turret ON or OFF      
    else  --if pushing from the front or from either side
      this.d=d  --rotate the turret to point in the true direction of the object
    end
    
    return 0,0 
  end
  
  --LASER BEAM
  if this.rule==3 and obj.a.push then --if this is a laser beam, and object is pushable
    --then remove this beam and all its offspring
    RemoveFromGame(this)  
  end
  
  --allow entry for laser beam
  return speed,force
end

this.StartExit=function(this,obj,speed,force)

  --element referenced in this function
  local mirror="2cdd1b18-c464-471d-979c-c31e6464e232"
  
  --if object type is mirror, then delete this and all offspring so player doesn't die when pushing
  if obj.guid==mirror then RemoveFromGame(this) end
  return speed,force  
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

--will toggle between turret OFF and turret ON
this.toggle={{1,2,3},{2,1,3}}

this.FinishEnter=function(this,obj)
  --if this is a beam, then remove the entering object
  if this.rule==3 then
    if not obj.a.push then
      DistanceSound(this.sound,5,this.x,this.y,this.z)
      death.start(obj,"explode",30) --RemoveFromGame(obj)
    end
  end
end

---------------------------------------------------------------------------------------------------
--GAME LOGIC
---------------------------------------------------------------------------------------------------
this.getCurrent=function(this,rule,color)
  local toggle="be4c179f-9c1c-494a-8af6-fd305f8f7013" --toggle button
  return this.toggle[Globals[toggle][color]][rule]
end

this.logic=function(this) --logic call per game frame

  --if this is tagged for removal from game logic calls, then remove it (avoids infinite loops)
  if this.active==false then
    MoveToList(this,{}) 
    return 
  end 
  
  --the current state based on the global toggle state
  local current=this:getCurrent(this.rule,this.color)
  
  --if this is a turret OFF and has offspring, then delete them all
  if current==1 and this.child then RemoveFromGame(this.child) end
  
  --if this is a turret ON or a laser beam
  if (current==2 or current==3) then
    --then try to propagate in current direction
    local vector=vectors[this.d]
    local newx=(this.x+vector.dx)
    local newy=(this.y+vector.dy)
    local newz=this.z
    local NewLaser=Clone(library[this.guid])			--create a new laser instance
    NewLaser.x,NewLaser.y,NewLaser.z,NewLaser.d=this.x,this.y,this.z,this.d  
    NewLaser.a,NewLaser.i={},{}
    NewLaser.a.power=3
    
    local speed=TestMove(NewLaser,1/12,1,newx,newy,newz)        --test for propagation
    
    if speed==0 then					--if can't propagate
      RemoveFromGame(NewLaser)				--remove new instance
      if this.child then RemoveFromGame(this.child) end	--if already propagated then delete all children
      MoveToList(this,Complete)				--end logic call; try again next tick
      return
      
    else					--if can propagate
      if not this.child then			--and haven't propagated
        NewLaser.init(NewLaser,newx,newy,newz,this)	--initialize new instance
        ListAppend(map[newx][newy][newz],NewLaser)	--add it to the map
      end
    end
  end
  
  if this.child and not this.active then       --if propagated and not required to stay active,
    MoveToList(this,{})    	       --then go to sleep for game efficiency				
  else MoveToList(this,Complete)	       --otherwise stay awake			
  end
end
  


  
  