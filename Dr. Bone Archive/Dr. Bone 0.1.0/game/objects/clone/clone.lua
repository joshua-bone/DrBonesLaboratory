---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="58a0b859-1ce7-4853-a3d5-1f6bb8b373a8"
this.author="Joshua Bone"
this.version="2008/06/21-07:51:20"

---------------------------------------------------------------------------------------------------
--EDITOR 
---------------------------------------------------------------------------------------------------

this.examples=function(T,F)
  return{{{T,1,0}},{{T,2},F}} --{{this, this.rule, [this.d]}}   (clone machine, clone button)
end

this.EditorRotate=EditorRotate

this.EditorShuffle=function(this)
	this.rule=3-this.rule
end

this.connect=function(this,conn,x,y,z)
  --remove the connector from the previous map location
  local obj=conn.lastconn --the last connector instance place on the map
  if obj then
    ListRemove(map[obj.x][obj.y][obj.z],obj)
  end

  --if the previous connection was an element of this type and opposite rule
  if conn.last and conn.last.guid==this.guid and conn.last.rule==3-this.rule then
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

this.clone=Clone
this.occupies="B"
this.removes="B"
this.sound=LoadSound(WD.."game/sounds/button.wav")

this.init=function(this,x,y,z)
  this.x,this.y,this.z=x,y,z
  local w
  local l=this.searchloc
  if l then --if we are connected
    local there=map[l[1]][l[2]][l[3]]
    for w=#there,1,-1 do
      if there[w].guid==this.guid and there[w].rule==3-this.rule then
        this.connection=there[w]
        break
      end
    end
  end
  
  if this.rule==1 then  --clone machine
    local here=map[x][y][z]
    for w=#here,1,-1 do
      if here[w][a] then
        if here[w].a.player or here[w].a.push or here[w].a.auto then
          this.cloneObject=here[w]  --a pointer to the object to be cloned       
          if here[w].d then this.d=here[w].d end  --face the direction of object
        end
      end
    end
  else
    this.transparent=2 --bottom transparency
  end
end

this.Read=function(this,params)
  this.d=0
  this.rule=params[2]
  if params[3] then this.d=params[3] end
  if params[4] then this.searchloc=params[4] end
  this.name=({"Clone Machine","Clone Button"})[this.rule]
end

this.Write=function(this,T)
  local conn=this.connection
  local searchloc=nil
  if conn then searchloc={conn.x,conn.y,conn.z} end
  return {T,this.rule,this.d,searchloc}
end

---------------------------------------------------------------------------------------------------
--CONDITIONS FOR ENTRY & EXIT
---------------------------------------------------------------------------------------------------

this.TestExit=function(this,obj,speed,force,newx,newy,newz)
  if this.rule==1 then
    if obj.a.beingCloned then
      return speed, force
    end
    return 0,0
  end
  return speed, force
end

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  if this.rule==1 then
    if obj.a.player then
      return 0,0
    end
  end
  return speed,force
end

---------------------------------------------------------------------------------------------------
--ENTRY & EXIT COMPLETION
---------------------------------------------------------------------------------------------------

this.FinishEnter=function(this,obj)

  if this.rule==2 then --if this is a clone button
    --if this has a connected machine, and there is something to be cloned
    if this.connection then
      local orig=this.connection.cloneObject
      if orig then  
        local newClone=Clone(orig)
        newClone.a={}
        newClone.i=recursiveClone(orig.i)
        newClone.a.beingCloned=true
        newClone.init(newClone,orig.x,orig.y,orig.z)
        ListAppend(map[orig.x][orig.y][orig.z],newClone)
        if orig.a.cargo then
          local newCargo=Clone(orig.a.cargo)
          newCargo.init(newCargo,orig.x,orig.y,orig.z)
          newCargo.a.beingCloned=true
          ListAppend(map[orig.x][orig.y][orig.z],newCargo)
          newClone.a.cargo=newCargo
        end
        local vector=vectors[this.connection.d]
        local newx=orig.x+vector.dx
        local newy=orig.y+vector.dy
        local newz=orig.z
        local speed=TestMove(newClone,1/12,1,newx,newy,newz)
        if speed~=0 then
          if newClone.a.cargo then
            local cspeed=TestMove(newClone.a.cargo,1/12,1,newx,newy,newz)
            if cspeed~=0 then
              StartMove(newClone.a.cargo,1/12,1,newx,newy,newz)
              MoveToList(newClone.a.cargo,Pending)
            else
              local cg=newClone.a.cargo
              if cg.guid=="d2982f8c-6935-4129-9744-dcddfd11a6ba" then --floppy disk
                Globals[cg.guid]=Globals[cg.guid]-1
                cg:showpiecesleft()
              end
              RemoveFromGame(newClone.a.cargo)
              newClone.a.cargo=nil
            end
          end
          StartMove(newClone,speed,1,newx,newy,newz)
          MoveToList(newClone,Complete)
          PlaySound(this.sound)
        else
          local nc=newClone
          if nc.guid=="d2982f8c-6935-4129-9744-dcddfd11a6ba" then --floppy disk
            Globals[nc.guid]=Globals[nc.guid]-1
            nc:showpiecesleft()
          end
          RemoveFromGame(newClone)
        end
      end
    end
  else  --if this is a machine
    if obj.guid=="d2982f8c-6935-4129-9744-dcddfd11a6ba" then --floppy disk
      Globals[obj.guid]=Globals[obj.guid]-1
      obj:showpiecesleft()
    end
    this.d=obj.d
    this.cloneObject=obj
  end
end

this.FinishExit=function(this,obj)
  obj.a.beingCloned=nil
end

