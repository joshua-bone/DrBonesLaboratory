---------------------------------------------------------------------------------------------------
--BASIC INFORMATION (guid, version, author, name)
---------------------------------------------------------------------------------------------------

this.guid="d1073414-77be-46bc-92e0-78f68d7f0412"
this.version="2008/04/23-21:03:00"
this.name="Teleport"

---------------------------------------------------------------------------------------------------
--LOADING & INITIALIZING
---------------------------------------------------------------------------------------------------

this.occupies="F"
this.removes="F"
this.clone=Clone

-- scan for next teleport and link to it
this.init=function(this,x,y,z)
  if gamestate~=Parts then
    this.x,this.y,this.z=x,y,z
    local max=#map*#map[1]*#map[1][1]
    while true do
      x=x-1           -- scan in reverse reading order as per CC rules
      if x<1 then
        x=#map
        y=y-1
        if y<1 then 
          y=#map[1]
          z=z-1
          if z<1 then
            z=#map[1][1]
          end
        end
      end
      -- look for teleport at new location
      local w
      local here=map[x][y][z]
      if here then
        for w=#here,1,-1 do
          if here[w].guid==this.guid then   -- if a teleport was found
            this.next=here[w]               -- save the link
            return                          -- and we are done
          end
        end
      end
    end
  end
end

this.TestEnter=function(this,obj,speed,force,newx,newy,newz)
  local d=GetDirection(obj.x,obj.y,obj.z,newx,newy,newz)
  if math.abs(d)==1 then return 0,0 end --can't enter from above or below
  return speed,force
end

-- when an object finishes entering, it should continue to the next teleport, or slide across
this.FinishEnter=function(this,obj)
  local d = GetDirection(obj.fromx,obj.fromy,obj.fromz,obj.x,obj.y,obj.z)
  local vector = vectors[d]
  local next=this.next        -- link to next teleport
  while true do
    ListRemove(map[obj.x][obj.y][obj.z],obj) -- teleport
    obj.x,obj.y,obj.z=next.x,next.y,next.z
    ListAppend(map[next.x][next.y][next.z],obj)
    if next==this then        -- if we got back to original
      TryMove(obj,obj.d,obj.MoveSpeed,obj.MoveForce)   -- finish move
      return                  -- and we are done
    end
    -- see if we can move
    local x,y,z=next.x,next.y,next.z           -- map location of destination
    local newx=x+vector.dx    -- cell just outside destination
    local newy=y+vector.dy
    local speed = TestMove(obj,obj.MoveSpeed,obj.MoveForce,newx,newy,next.z) -- check exit
    if speed~=0 then
      TryMove(obj,obj.d,obj.MoveSpeed,obj.MoveForce)   -- finish move
      return
    end
    next=next.next            -- otherwise, move on to next teleport
  end
end



