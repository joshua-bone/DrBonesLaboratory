---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------
--colors: 1 red   2 green    3 yellow   4 blue    5 magenta    6 cyan     7 orange  8 brown

this.guid="fa94a1e9-436d-4611-8e74-8cd20625048f"
this.author="Joshua Bone"
this.version="2008/06/10-08:57:20"
this.name="Go-Kart"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return{{{T,0,4},F}} --{this, this.d,this.color}
end

--rotates direction in editor
this.EditorRotate=EditorRotate

--change color in editor
this.EditorShuffle=function(this,d)
  this.color = (this.color+d)%8
  if this.color==0 then this.color=8 end
end
---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------
this.transparent=4 --top transparency (1=floor, 2=bottom, 3=center, 4=top)
this.colors={"red","green","yellow","blue","magenta","cyan","orange","brown"}
this.clone=Clone

this.init=function(this,x,y,z)
  --ATTRIBUTES
    this.a.auto=true  --autonomous
    ListAppend(Globals["activetoggles"][this.color],this)

  --STATS
    this.a.power=2    --2nd level of power
    
  --SPEED, FORCE, LOCATION
    this.MoveSpeed,this.MoveForce=0,0
    this.x,this.y,this.z=x,y,z
    this.offset=0
    this.fromx,this.fromy,this.fromz=x,y,z
    MoveToList(this,Pending)      -- add object to active list
end

this.Read=function(this,params)
  this.d=params[2]
  this.color=params[3]
  this.occupies="T"  --tank occupies top
  this.removes="T"
end

this.Write=function(this,T)
  return {T,this.d,this.color}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  return 0,0
end

---------------------------------------------------------------------------------------------------
--GAME LOGIC
---------------------------------------------------------------------------------------------------
this.activeToggle=function(this)
  RotateObjectDirection(this,180,0)     --reverse this.d
end

this.logic=function(this)          -- game logic call per game frame
  if not ContinueMove(this) then   -- if we have reached the center
    TryMove(this,this.d,1/12,1) --try to move in facing direction
  end
  MoveToList(this,Complete) --and we are done
end
    









