---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="88f59a96-c802-43fe-81c8-780ad2fccf91"
this.version="2008/04/20-22:08:00"
this.author="Chuck Sommerville"
this.name="Robot"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return{
  --{{this, this.rule, this.d}, floor}  
  {{T,1,0},F},  --(Left Hand Rule Bot aka spider)
  {{T,2,0},F},  --(Right Hand Rule Bot aka centipede)
  {{T,3,0},F},  --(Hit Left Bot aka glider)
  {{T,4,0},F},  --(Hit Right Bot aka fireball)
  {{T,5,0},F},  --(Reverse Bot aka rubber ball)
  {{T,6,0},F},  --(Random Mover aka blob)
  {{T,7,0},F},  --(Hit Random aka walker)
  {{T,8,0},F},  --(Pursuer aka teeth)
  {{T,9,0},F},  --(Fast Pursuer aka wolf spider)
  }
end

--rotates direction in editor
this.EditorRotate=EditorRotate

--rotates bot type
this.EditorShuffle=function(this,dir)
  this.rule=this.rule+dir
  if this.rule>#this.rules then this.rule=1
  elseif this.rule<1 then this.rule=#this.rules
  end
end


---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="T"      --occupies top
this.removes="T"       --removes top
this.clone=Clone       -- allow individual instances
this.transparent=4 --top transparency

this.init=function(this,x,y,z)

  --elements referenced in this function
  local boot="e0159bb2-2559-44df-b9d0-5d836c6f0a14"
  
--ATTRIBUTES
  this.a.auto=true
  if this.rule==3 then  
    this.i[boot]={0,0,1,0} --hl bots (stag beetles) have flipper
  elseif this.rule==4 then
    this.i[boot]={0,1,0,0}  --hr bots (yellowjackets) have fire boot
  elseif this.rule==7 then
    this.a.flies=true  --hit random bots (houseflies) don't fall
  elseif this.rule==9 then
    this.i[boot]={0,0,1,0}
  end 

--STATS
  this.a.power=2
  
--SPEED,  FORCE,  LOCATION
  this.MoveSpeed,this.MoveForce=0,0
  this.x,this.y,this.z=x,y,z
  this.offset=0
  this.fromx,this.fromy,this.fromz=x,y,z
  MoveToList(this,Pending)      -- add object to active list
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

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)

  --elements referenced in this function
  local laser="0b2de6b9-8290-431e-9aad-fc474ae8d302"
  local boulder="5d262175-df1c-4e5b-9a9e-9e87ea83f05e"
  
  if (obj.guid==laser)  --laser beams can enter
  or (obj.guid==boulder)  --so can boulders if they have enough force
  then
    return speed, force
  end
  
  if obj.a.player then  --player can enter
	  return speed,force 
  else 
	  return 0,0  --nothing else can enter
  end
end

this.StartEnter=function(this,obj,speed,force,newx,newy,newz)
  if this.a.power>obj.a.power then  --compare power
    death.start(obj,"explode",30, "Oops! Watch out for bugs!") -- remove object if less powerful
    return 0,0
  else
    death.start(this,"explode",30) -- remove this if more powerful
    return speed,force
  end
end

---------------------------------------------------------------------------------------------------
--GAME LOGIC
---------------------------------------------------------------------------------------------------

this.rules={
{1,{90,270,270,270}}, --lhr (tarantula)
{1,{270,90,90,90}},   --rhr (paramecium)
{1,{0,90,180,270}},   --hl  (wasp)
{1,{0,270,180,90}},   --hr  (fireball)
{1,{0,180}},          --reverse (bouncy ball)
{1/2,{'R','R','R','R'}},  --random move (cockroach)
{1,{0,'R','R','R'}},  --random hit (housefly)
{1/2,{'F'}},            --pursue (wolf spider)
{1,{'F'}},            --fast pursue
}

function GetDirToPlayer(obj)
  local x,y=gamestate.camera.focus.x,gamestate.camera.focus.y
  local majorD,minorD
  local dx=obj.x-x
  local dy=obj.y-y
  if dx==0 and dy==0 then return end
  if dx==0 then
    majorD=(-dy/math.abs(dy))*90+90
    majorD=GetRelativeDirection(obj.d,majorD)
    minorD=-1
  elseif dy==0 then
    majorD=(-dx/math.abs(dx))*90+180
    majorD=GetRelativeDirection(obj.d,majorD)
    minorD=-1
  else
    if math.abs(dx)>math.abs(dy) then
      majorD=(-dx/math.abs(dx))*90+180
      minorD=(-dy/math.abs(dy))*90+90
    elseif math.abs(dy)>math.abs(dx) then
      minorD=(-dx/math.abs(dx))*90+180
      majorD=(-dy/math.abs(dy))*90+90
    else --player along the diagonal
      local n=math.random(2)
      local d1=({dy,dx})[n]
      local d2=({dy,dx})[3-n]
      majorD=(-d1/math.abs(d1)+n)*90
      minorD=(-d2/math.abs(d2)+(3-n))*90
    end
    majorD=GetRelativeDirection(obj.d,majorD)
    minorD=GetRelativeDirection(obj.d,minorD)
  end
  return majorD, minorD   
end

function DoRule(obj,rule)
  local returnVal=false
  local r,d
  local speed=rule[1]*monsterspeed
  d=obj.d
  local newD,newD2
  for r=1,#rule[2] do
    if rule[2][r]=='R' then
      newD=(math.random(4)-1)*90
    elseif rule[2][r]=='F' then
      newD,newD2=GetDirToPlayer(obj)
    else
      newD=rule[2][r]
    end
    if not newD then return end
    RotateObjectDirection(obj,newD,0) --rotate object according to rule
    if (TryMove(obj,obj.d,speed,1))>0 then  --and try to move
      d=obj.d --if move succeeds, save the direction 
      returnVal=true
      break
    else
      if newD2 then --wolf spider
        if newD2>=0 then
          obj.d=d
          RotateObjectDirection(obj,newD2,0)
          if (TryMove(obj,obj.d,speed,1))>0 then
            d=obj.d
            returnVal=true
            break
          else
            RotateObjectDirection(obj,-newD2,0)
            RotateObjectDirection(obj,-newD,0)
            d=GetTrueDirection(obj.d,newD)
          end
        else
          RotateObjectDirection(obj,-newD,0)
          d=GetTrueDirection(obj.d,newD)
        end
      end
    end
  end
  obj.d=d --set bot in direction of move
  return returnVal
end

this.logic=function(this,event)          -- game logic call per game frame
  if not ContinueMove(this) then         -- if we have reached the center
    if not DoRule(this,this.rules[this.rule]) then   --try to move according to rule
      Hover(this,1/12,1)
    end
  end
  MoveToList(this,Complete)              --and we are done
end