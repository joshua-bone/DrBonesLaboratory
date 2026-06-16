---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="bc1d2021-e430-45fc-a80e-20ac9eb2e2c7"
this.author="Joshua Bone"
this.version="2008/06/10-08:57:20"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return{{{T,1}},{{T,3}}} --{{this, this.rule}}   (trap, trap button)
end

this.EditorShuffle=function(this)
  this.rule=4-this.rule
end

this.EditorRotate=this.EditorShuffle

this.connect=function(this,conn,x,y,z)
  --remove the connector from the previous map location
  local obj=conn.lastconn --the last connector instance place on the map
  if obj then
    ListRemove(map[obj.x][obj.y][obj.z],obj)
  end

  --if the previous connection was an element of this type and opposite rule
  if conn.last and conn.last.guid==this.guid and conn.last.rule==4-this.rule then
    if this.connection then this.connection.connection=nil end --break the connection
    this.connection=conn.last
    conn.last.connection=this
    conn.last=nil
  else
    conn.last=this
    local newobj=conn.clone(conn)--create a new instance
    newobj.x,newobj.y,newobj.z=x,y,z --save its location
    conn.lastconn=newobj --give the parent object memory of its child
    ListAppend(map[x][y][z],newobj) --and add it to the map
  end
end

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="B"
this.removes="B"
this.clone=Clone

this.Read=function(this,params)
  this.rule=params[2]
  if params[3] then this.searchloc=params[3] end
  this.name=({"Trap","Trap","Trap Button"})[this.rule]
end

this.Write=function(this,T)
  local conn=this.connection
  local searchloc=nil
  if conn then searchloc={conn.x,conn.y,conn.z} end
  return {T,this.rule,searchloc}
end


this.init=function(this,x,y,z)
  this.x,this.y,this.z=x,y,z
  local w
  local l=this.searchloc
  if l then --if we are connected
    local there=map[l[1]][l[2]][l[3]]
    for w=#there,1,-1 do
      if there[w].guid==this.guid and there[w].rule==4-this.rule then
        this.connection=there[w]
        break
      end
    end
  end
  if this.rule==3 then
    this.transparent=2 --bottom transparency
  end
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestExit=function(this,obj,speed,force,newx,newy,newz)
  if this.rule==1 then
    return 0,0  --can't exit shut trap
  end
  return speed, force
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------


this.FinishEnter=function(this,obj)

  if this.rule==3 and this.connection then --if this is a trap button, and has a connected trap
    this.connection.rule=2   --open next trap
    local stuck=this.connection.i.stuckHere 
    if stuck then --if something is stuck at the next trap
      --then try to make it move in its previous direction of motion
      local d=stuck.d
      local vector=vectors[d]
      local newx=stuck.x+vector.dx
      local newy=stuck.y+vector.dy
      local speed=TestMove(stuck,1/12,1,newx,newy,stuck.z)
      if speed~=0 then 
        StartMove(stuck,speed,1,newx,newy,stuck.z)
      end
    end
  else  --if this is a trap
    --then store a pointer to the entering object
    this.i.stuckHere=obj
  end
end


this.FinishExit=function(this,obj)
  if this.rule==3 and this.connection then  --if this is a connected trap button
    this.connection.rule=1    --shut the next trap
  else  --otherwise
    this.i.stuckHere=nil  --there is no longer anything stuck here
  end
end

