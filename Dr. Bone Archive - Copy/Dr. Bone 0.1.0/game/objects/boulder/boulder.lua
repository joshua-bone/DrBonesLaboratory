---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="5d262175-df1c-4e5b-9a9e-9e87ea83f05e"
this.name="Boulder"
this.author="Joshua Bone"
this.version="2008/06/24-08:19:10"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  --{{this, this.d}}  
  return{{{T,0}}}
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="T" --boulders occupy top
this.removes="T"
this.clone=Clone

this.init=function(this,x,y,z)

  this.a.push=true  --pushable attribute
  this.a.power=3    --can kill player & bot
  
  this.hats={{1,0,0},{0,1,0},{0,0,1}}
  this.thetax,this.thetay,this.thetaz=0,0,0
  
  this.MoveSpeed,this.MoveForce=0,2
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
  return {T,this.d}
end

this.Read=function(this,params)
  this.d=params[2]
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  --player and other boulders can enter for now, we will check further in StartEnter
  if obj.a.player
  or obj.guid==this.guid then 
    return speed, force 
  end
  return 0,0 --default is no entry
end

this.TestEnter2=function(this,obj,speed,force,newx,newy,newz)
  if this.a.rolling and force<=this.MoveForce then
    return 0,0  --must have greater force to affect a moving boulder
  end
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz) --the true direction of desired motion
  if math.abs(d)==1 then return 0,0 end
  local vector=vectors[d]
  local newx=this.x+vector.dx
  local newy=this.y+vector.dy
  local newspeed,newforce=TestMove(this,1/24,force,newx,newy,this.z) --test push in desired direction
  
  if newspeed~=0 then   --if push is successful
    this.d=d
    this:roll()
    StartMove(this,newspeed,newforce,newx,newy,newz)
    MoveToList(this,Pending)              --add to active list for move
  end
  
  return 0,0  --don't enter the square the boulder was on
end

---------------------------------------------------------------------------------------------------
--GAME LOGIC
---------------------------------------------------------------------------------------------------

this.logic=function(this)
  this.awake=nil
  if ContinueMove(this) then 
    if not this.a.rolling then
      this.a.rolling=true
    end
    MoveToList(this,Complete)
    return
  else
    if this.a.rolling then
      local vector=vectors[this.d]
      local newx=this.x+vector.dx
      local newy=this.y+vector.dy
      local speed,force=TestMove(this,1/24,2,newx,newy,this.z) --test roll in desired direction
      if speed~=0 then  --able to roll further
        this:roll()
        StartMove(this,speed,force,newx,newy,this.z)
        MoveToList(this,Complete)
        return
      end
    end
  end

  this.a.rolling=nil
  local here=map[this.x][this.y][this.z]
  local z
  for z=#here,1,-1 do
    local fcn=here[z].Hover
    if fcn then this.awake=true end
  end
  if this.awake then
    Hover(this,1/24,2)
    MoveToList(this,Complete)
  else
    MoveToList(this,{})
  end
end

---------------------------------------------------------------------------------------------------
--OTHER FUNCTIONS
---------------------------------------------------------------------------------------------------

this.roll=function(this)
  local thx,thy,thz=0,0,0
  if this.d==0 then thx=1
  elseif this.d==90 then thy=-1
  elseif this.d==180 then thx=-1
  elseif this.d==270 then thy=1
  end
  local i
  for i=1,3 do
    local v=Clone(this.hats[i])
    local w=this.hats[i]
    if thx~=0 then   --rotation matrix for 90deg rotations
      w[2]=v[3]*thx
      w[3]=v[2]*(-thx)
    elseif thy~=0 then
      w[1]=v[3]*thy
      w[3]=v[1]*(-thy)
    end
  end
  
  --determine rotation angles for rendering later
  local xh=Clone(this.hats[1])
  local yh=Clone(this.hats[2])
  local xh2=Clone(this.hats[1])
  local yh2=Clone(this.hats[2])
  thx,thy,thz=0,0,0
  
  --find angles required to get xhat' pointing along xhat
  if xh[3]==0 then --not pointing along z-axis
    while round(xh2[1])~=1 do
      thz=thz+90 if thz>270 then break end
      xh2[1]=-xh[2]
      xh2[2]=xh[1]
      yh2[1]=-yh[2]
      yh2[2]=yh[1]
      xh=Clone(xh2)
      yh=Clone(yh2)
    end
  else
    while round(xh2[1])~=1 do
      thy=thy+90 if thy>270 then break end
      xh2[1]=xh[3]
      xh2[3]=-xh[1]
      yh2[1]=yh[3]
      yh2[3]=-yh[1]
      xh=Clone(xh2)
      yh=Clone(yh2)
    end  
  end

  --find angle required to get yhat' pointing along yhat
  while round(yh2[2])~=1 do
    thx=thx+90 if thx>270 then break end
    yh2[2]=-yh[3]
    yh2[3]=yh[2]
    yh=Clone(yh2)
  end
  this.thetax=thx
  this.thetay=thy
  this.thetaz=thz
end

